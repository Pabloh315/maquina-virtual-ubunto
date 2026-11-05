import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:movil/core/api/api_client.dart';
import 'package:movil/core/api/api_exception.dart';
import 'package:movil/core/api/http_api_transport.dart';
import 'package:movil/data/repositories/real_api_repository.dart';
import 'package:movil/features/integration/real_api_controller.dart';
import 'support/real_api_fixtures.dart';

void main() {
  late HttpServer server;
  late RealApiRepository repository;
  Future<void> start(
    FutureOr<void> Function(HttpRequest) handler, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      try {
        await handler(request);
      } on HttpException {
        /* El cliente puede haber abortado una solicitud de prueba. */
      } on SocketException {
        /* Conexión cerrada en la prueba de timeout. */
      }
    });
    repository = RealApiRepository(
      ApiClient(
        HttpApiTransport(
          Uri.parse('http://127.0.0.1:${server.port}/api'),
          allowLocalHttp: true,
          timeout: timeout,
        ),
      ),
    );
    addTearDown(() async {
      repository.close();
      await server.close(force: true);
    });
  }

  Future<void> json(
    HttpRequest request,
    Object body, {
    int status = 200,
  }) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    await request.response.close();
  }

  test(
    'HTTP real conserva la base /api, las relaciones Laravel y todas las páginas',
    () async {
      final paths = <String>[];
      await start((r) async {
        paths.add(r.uri.toString());
        if (r.uri.path == '/api/health') {
          await json(r, {'status': 'ok', 'service': 'autocare'});
        } else if (r.uri.path == '/api/database') {
          await json(r, {
            'status': 'ok',
            'database': 'reachable',
            'driver': 'pgsql',
          });
        } else if (r.uri.path == '/api/v1/vehicles') {
          final page = int.parse(r.uri.queryParameters['page']!);
          await json(
            r,
            vehiclePage([laravelVehicle(page)], page: page, last: 2),
          );
        } else {
          await json(r, {'data': laravelVehicle(2)});
        }
      });
      expect(await repository.health(), 'autocare');
      expect(await repository.database(), 'pgsql');
      final vehicles = await repository.vehicles();
      expect(vehicles.map((v) => v.id), ['1', '2']);
      expect(vehicles.first.brand, 'Toyota');
      expect(vehicles.first.categoryId, '2');
      expect(vehicles.first.odometerKm, 12500);
      expect((await repository.vehicle('2')).plate, 'REAL-2');
      expect(
        paths,
        containsAll([
          '/api/health',
          '/api/database',
          '/api/v1/vehicles?page=1',
          '/api/v1/vehicles?page=2',
          '/api/v1/vehicles/2',
        ]),
      );
    },
  );

  test('POST envía JSON y decodifica la respuesta 201 de Laravel', () async {
    Map<String, dynamic>? received;
    await start((r) async {
      expect(r.method, 'POST');
      expect(r.uri.path, '/api/v1/vehicles');
      expect(r.headers.contentType?.mimeType, 'application/json');
      received =
          jsonDecode(await utf8.decoder.bind(r).join()) as Map<String, dynamic>;
      await json(r, {'data': laravelVehicle(9)}, status: 201);
    });
    expect(
      (await repository.createVehicle({
        'owner_id': 4,
        'license_plate': 'REAL-9',
      })).id,
      '9',
    );
    expect(received, {'owner_id': 4, 'license_plate': 'REAL-9'});
  });

  test('422 preserva los errores por campo del servidor', () async {
    await start(
      (r) => json(r, {
        'message': 'La placa ya está registrada.',
        'errors': {
          'license_plate': ['La placa ya está registrada.'],
        },
      }, status: 422),
    );
    await expectLater(
      repository.createVehicle({}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', 'VALIDATION_ERROR')
            .having((e) => e.details['license_plate'], 'field', [
              'La placa ya está registrada.',
            ]),
      ),
    );
  });

  for (final status in [401, 403, 404, 429, 500, 503]) {
    test('HTTP $status muestra un mensaje seguro', () async {
      await start(
        (r) => json(r, {'message': 'SQL password interno'}, status: status),
      );
      await expectLater(
        repository.health(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.status, 'status', status)
              .having(
                (e) => e.message.contains('SQL'),
                'safe message',
                isFalse,
              ),
        ),
      );
    });
  }

  test('Respuesta no JSON produce un error de formato controlado', () async {
    await start((r) async {
      r.response.write('<html>error</html>');
      await r.response.close();
    });
    await expectLater(
      repository.health(),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'INVALID_RESPONSE'),
      ),
    );
  });

  test('Redirecciones no se siguen a otros servidores', () async {
    await start((r) async {
      r.response.headers.set('location', 'http://127.0.0.1:1/otro');
      await json(r, {}, status: 302);
    });
    await expectLater(
      repository.health(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          'UNEXPECTED_REDIRECT',
        ),
      ),
    );
  });

  test('Timeout cancela la espera y devuelve un error controlado', () async {
    await start((r) async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await json(r, {});
    }, timeout: const Duration(milliseconds: 40));
    await expectLater(
      repository.health(),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'TIMEOUT')),
    );
  });

  test('Servidor apagado devuelve NETWORK_ERROR', () async {
    final listener = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = listener.port;
    await listener.close(force: true);
    final transport = HttpApiTransport(
      Uri.parse('http://127.0.0.1:$port/api'),
      allowLocalHttp: true,
    );
    addTearDown(transport.close);
    await expectLater(
      transport.request('GET', '/health'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'NETWORK_ERROR'),
      ),
    );
  });

  test('HTTP externo y URLs inseguras se rechazan, sin desactivar TLS', () {
    for (final url in [
      'http://ejemplo.test/api',
      'https://api.example.invalid/api',
      'https://user:password@example.test/api',
    ]) {
      expect(
        () => HttpApiTransport(Uri.parse(url), allowLocalHttp: true),
        throwsArgumentError,
      );
    }
  });

  test('Contrato de vehículo incompleto se rechaza', () async {
    await start(
      (r) => json(r, {
        'data': {'id': 1},
      }),
    );
    await expectLater(
      repository.vehicle('1'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'INVALID_RESPONSE'),
      ),
    );
  });

  test(
    'La comprobación técnica solo consulta los endpoints disponibles',
    () async {
      final transport = FixtureTransport();
      final controller = RealApiController(
        RealApiRepository(ApiClient(transport)),
      );
      addTearDown(controller.dispose);
      await controller.connect();
      expect(controller.driver, 'pgsql');
      expect(controller.vehicles.single.id, '1');
      expect(controller.busy, isFalse);
      expect(transport.calls, [
        'GET /health',
        'GET /database',
        'GET /v1/vehicles',
      ]);
    },
  );
}
