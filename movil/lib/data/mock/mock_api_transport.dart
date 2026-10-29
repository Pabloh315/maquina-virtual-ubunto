import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/api/api_exception.dart';
import '../../core/api/api_transport.dart';

class MockApiTransport implements ApiTransport {
  MockApiTransport({this.latency = const Duration(milliseconds: 300)})
    : _data = rootBundle
          .loadString('assets/mock/api.json')
          .then((text) => jsonDecode(text) as Map<String, dynamic>);

  final Duration latency;
  final Future<Map<String, dynamic>> _data;
  final Map<String, Map<String, dynamic>> _idempotency = {};
  bool _authenticated = false;
  int _sequence = 100;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  }) async {
    await Future<void>.delayed(latency);
    final data = await _data;
    final input = body ?? <String, dynamic>{};
    if (method == 'POST' && path == '/auth/login') {
      if (input['email'] != 'demo@ejemplo.test' ||
          input['password'] != 'clave_demo') {
        throw const ApiException(
          401,
          'UNAUTHORIZED',
          'Correo o contraseña incorrectos. Usa la cuenta de demostración.',
        );
      }
      _authenticated = true;
      return {
        'data': {
          'access_token': 'TOKEN_DEMO_LOCAL',
          'expires_in': 900,
          'user': data['user'],
        },
      };
    }
    if (!_authenticated ||
        headers['Authorization'] != 'Bearer TOKEN_DEMO_LOCAL') {
      throw const ApiException(401, 'UNAUTHORIZED', 'Vuelve a iniciar sesión.');
    }
    if (method == 'POST' && path == '/auth/logout') {
      _authenticated = false;
      return {'data': null};
    }
    if (method == 'GET' && path == '/me') return {'data': data['user']};
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final vehicles = (data['vehicles'] as List).cast<Map<String, dynamic>>();
    if (parts.firstOrNull == 'vehicles' &&
        parts.length >= 2 &&
        !vehicles.any((v) => v['id'] == parts[1])) {
      throw const ApiException(404, 'NOT_FOUND', 'El vehículo no existe.');
    }
    if (method == 'GET') {
      List<dynamic>? records;
      if (path == '/vehicles') records = vehicles;
      if (parts.length == 2 && parts[0] == 'vehicles') {
        return {'data': vehicles.firstWhere((v) => v['id'] == parts[1])};
      }
      if (parts.length == 3 &&
          parts[0] == 'vehicles' &&
          ['plans', 'history', 'backgrounds'].contains(parts[2])) {
        records = (data[parts[2]] as List)
            .where((r) => r['vehicle_id'] == parts[1])
            .toList();
      }
      if (path == '/alerts' || path == '/appointments') {
        records = (data[parts[0]] as List)
            .where(
              (r) =>
                  query['vehicle_id'] == null ||
                  r['vehicle_id'] == query['vehicle_id'],
            )
            .toList();
      }
      if (path == '/workshops') {
        records = (data['workshops'] as List)
            .where(
              (w) =>
                  query['service'] == null ||
                  (w['specialties'] as List).contains(query['service']),
            )
            .toList();
      }
      if (parts.length == 2 && parts[0] == 'workshops') {
        final matches = (data['workshops'] as List).where(
          (w) => w['id'] == parts[1],
        );
        if (matches.isNotEmpty) return {'data': matches.first};
      }
      if (records != null) {
        final page = int.tryParse(query['page'] ?? '1') ?? 1;
        final size = int.tryParse(query['page_size'] ?? '20') ?? 20;
        if (page < 1 || size < 1 || size > 100) {
          throw const ApiException(
            422,
            'VALIDATION_ERROR',
            'Paginación inválida.',
          );
        }
        return {
          'data': records.skip((page - 1) * size).take(size).toList(),
          'meta': {'page': page, 'page_size': size, 'total': records.length},
        };
      }
    }
    if (method == 'POST' && parts.length == 3 && parts[0] == 'vehicles') {
      final vehicle = vehicles.firstWhere((v) => v['id'] == parts[1]);
      if (parts[2] == 'odometer-readings') {
        final km = input['odometer_km'];
        if (km is! int || km < 0) {
          throw const ApiException(
            422,
            'VALIDATION_ERROR',
            'Introduce un kilometraje válido.',
          );
        }
        if (km < (vehicle['odometer_km'] as int)) {
          throw ApiException(
            409,
            'ODOMETER_REVIEW_REQUIRED',
            'La lectura es menor que la anterior; requiere revisión.',
            details: {'previous_km': vehicle['odometer_km']},
          );
        }
        vehicle['odometer_km'] = km;
        return {
          'data': {'id': 'km${_sequence++}', 'odometer_km': km},
        };
      }
      if (parts[2] == 'backgrounds') {
        if (input['service'] is! String || input['known'] is! bool) {
          throw const ApiException(
            422,
            'VALIDATION_ERROR',
            'Completa el antecedente.',
          );
        }
        final entry = {
          ...input,
          'id': 'b${_sequence++}',
          'vehicle_id': parts[1],
        };
        (data['backgrounds'] as List).add(entry);
        // Un antecedente nunca altera historial confirmado ni intervalos.
        return {'data': entry};
      }
    }
    if (method == 'POST' && path == '/appointments') {
      final key = headers['Idempotency-Key'];
      if (key == null || key.isEmpty) {
        throw const ApiException(
          422,
          'VALIDATION_ERROR',
          'Falta la clave de la reserva.',
        );
      }
      if (_idempotency.containsKey(key)) return _idempotency[key]!;
      final startsAt = DateTime.tryParse(input['starts_at'] as String? ?? '');
      final workshopMatches = (data['workshops'] as List).where(
        (w) => w['id'] == input['workshop_id'],
      );
      if (!vehicles.any((v) => v['id'] == input['vehicle_id']) ||
          workshopMatches.isEmpty ||
          startsAt == null ||
          !(workshopMatches.first['specialties'] as List).contains(
            input['service'],
          )) {
        throw const ApiException(
          422,
          'VALIDATION_ERROR',
          'Revisa los datos de la cita.',
        );
      }
      final appointments = data['appointments'] as List;
      if (appointments.any(
        (a) =>
            a['workshop_id'] == input['workshop_id'] &&
            DateTime.parse(
              a['starts_at'] as String,
            ).isAtSameMomentAs(startsAt) &&
            a['status'] == 'confirmed',
      )) {
        throw const ApiException(
          409,
          'SLOT_UNAVAILABLE',
          'Cupo no disponible. Elige otro horario.',
        );
      }
      final response = <String, dynamic>{
        'data': {...input, 'id': 'c${_sequence++}', 'status': 'confirmed'},
      };
      appointments.add(response['data']);
      _idempotency[key] = response;
      return response;
    }
    if (method == 'POST' &&
        parts.length == 3 &&
        parts[0] == 'appointments' &&
        parts[2] == 'cancel') {
      final matches = (data['appointments'] as List).where(
        (a) => a['id'] == parts[1],
      );
      if (matches.isEmpty) {
        throw const ApiException(404, 'NOT_FOUND', 'La cita no existe.');
      }
      final appointment = matches.first;
      if (appointment['status'] != 'confirmed') {
        throw const ApiException(
          409,
          'INVALID_TRANSITION',
          'Solo puedes cancelar citas confirmadas.',
        );
      }
      appointment['status'] = 'cancelled';
      return {'data': appointment};
    }
    throw const ApiException(
      404,
      'NOT_FOUND',
      'Recurso no disponible en esta demostración.',
    );
  }

  @override
  void close() {}
}
