import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movil/app/autocare_app.dart';
import 'package:movil/core/api/api_client.dart';
import 'package:movil/core/api/api_exception.dart';
import 'package:movil/core/api/http_api_transport.dart';
import 'package:movil/core/config/app_config.dart';
import 'package:movil/data/repositories/real_api_repository.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android consume Laravel y persiste un vehículo real en PostgreSQL',
    (tester) async {
      final requests = <Map<String, Object>>[];
      final repository = RealApiRepository(
        ApiClient(
          HttpApiTransport(
            Uri.parse(AppConfig.baseUrl),
            allowLocalHttp: AppConfig.allowLocalHttp,
            onResponse: (method, path, status) => requests.add({
              'method': method,
              'path': path,
              'status': status,
            }),
          ),
        ),
      );
      await tester.pumpWidget(
        AutoCareApp(useMock: false, realRepository: repository),
      );
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();

      Future<void> capture(String name) async {
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        await binding.takeScreenshot(name);
      }

      Future<void> reveal(Finder finder) => tester.scrollUntilVisible(
        finder,
        260,
        scrollable: find.byType(Scrollable).first,
      );
      Future<void> enter(String field, String value) async {
        final finder = find.byKey(ValueKey('field-$field'));
        await reveal(finder);
        await tester.enterText(finder, value);
        FocusManager.instance.primaryFocus?.unfocus();
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const Key('connect-real-api')));
      await tester.pumpAndSettle();
      expect(find.text('Conectada · pgsql'), findsOneWidget);
      await capture('01_conexion_real');

      final existing = await repository.vehicles();
      expect(
        existing,
        isNotEmpty,
        reason: 'Ejecutar primero el seeder demo del backend.',
      );
      final create = find.byKey(const Key('create-real-vehicle'));
      await reveal(create);
      await tester.tap(create);
      await tester.pumpAndSettle();
      await enter('license_plate', existing.first.plate);
      await enter('year', '2024');
      await enter('current_mileage', '12600');
      final save = find.byKey(const Key('save-real-vehicle'));
      await reveal(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.textContaining('La placa ya está registrada.'), findsWidgets);
      await capture('02_validacion_422');

      final plate = 'EDT19-${DateTime.now().millisecondsSinceEpoch}';
      await enter('license_plate', plate);
      await reveal(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      final stored = (await repository.vehicles()).singleWhere(
        (v) => v.plate == plate,
      );
      expect(stored.odometerKm, 12600);
      final card = find.byKey(ValueKey('real-vehicle-${stored.id}'));
      await reveal(card);
      await capture('03_vehiculo_guardado');
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(
        find.text('Consulta real · Registro #${stored.id}'),
        findsOneWidget,
      );
      await capture('04_detalle_postgresql');
      expect((await repository.vehicle(stored.id)).plate, plate);
      await expectLater(
        repository.vehicle('999999999'),
        throwsA(isA<ApiException>().having((e) => e.status, 'HTTP', 404)),
      );
      expect(
        requests.any((r) => r['method'] == 'POST' && r['status'] == 201),
        isTrue,
      );
      expect(requests.any((r) => r['status'] == 422), isTrue);
      expect(requests.any((r) => r['status'] == 404), isTrue);
      expect(tester.takeException(), isNull);
      binding.reportData = {
        ...?binding.reportData,
        'api_base_url': AppConfig.baseUrl,
        'api_mode': 'http',
        'database_driver': 'pgsql',
        'created_vehicle': {
          'id': stored.id,
          'plate': stored.plate,
          'odometer_km': stored.odometerKm,
        },
        'requests': requests,
        'result': 'passed',
      };
    },
  );
}
