import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../models/models.dart';

class RealApiRepository {
  RealApiRepository(this.client);
  final ApiClient client;

  Future<String> health() async {
    final response = await client.request('GET', '/health');
    if (response['status'] != 'ok' || response['service'] is! String) {
      throw const ApiException(
        502,
        'INVALID_RESPONSE',
        'La respuesta de salud de la API no es válida.',
      );
    }
    return response['service'] as String;
  }

  Future<String> database() async {
    final response = await client.request('GET', '/database');
    if (response['status'] != 'ok' ||
        response['database'] != 'reachable' ||
        response['driver'] is! String) {
      throw const ApiException(
        503,
        'DATABASE_UNAVAILABLE',
        'La API no pudo confirmar la conexión a la base de datos.',
      );
    }
    return response['driver'] as String;
  }

  Vehicle _decode(dynamic data) {
    try {
      if (data is! Json || data['id'] == null || data['owner_id'] == null) {
        throw const FormatException('Faltan identificadores.');
      }
      return Vehicle.fromLaravel(data);
    } on TypeError {
      throw const ApiException(
        502,
        'INVALID_RESPONSE',
        'Los datos del vehículo no coinciden con el contrato de la API.',
      );
    } on FormatException {
      throw const ApiException(
        502,
        'INVALID_RESPONSE',
        'La respuesta del vehículo está incompleta.',
      );
    }
  }

  Future<List<Vehicle>> vehicles() async {
    final vehicles = <Vehicle>[];
    var page = 1;
    while (true) {
      final response = await client.request(
        'GET',
        '/v1/vehicles',
        query: {'page': '$page'},
      );
      if (response['data'] is! List || response['meta'] is! Json) {
        throw const ApiException(
          502,
          'INVALID_RESPONSE',
          'La lista de vehículos no tiene el formato esperado.',
        );
      }
      final records = response['data'] as List;
      final meta = response['meta'] as Json;
      if (meta['current_page'] != page ||
          meta['last_page'] is! int ||
          (meta['last_page'] as int) < page) {
        throw const ApiException(
          502,
          'INVALID_RESPONSE',
          'La paginación de la API no es válida.',
        );
      }
      vehicles.addAll(records.map(_decode));
      if (page >= (meta['last_page'] as int)) break;
      if (records.isEmpty || page >= 1000) {
        throw const ApiException(
          502,
          'INVALID_RESPONSE',
          'La paginación está incompleta o excede el límite de esta versión técnica.',
        );
      }
      page++;
    }
    return vehicles;
  }

  Future<Vehicle> vehicle(String id) async => _decode(
    (await client.request(
      'GET',
      '/v1/vehicles/${Uri.encodeComponent(id)}',
    ))['data'],
  );

  Future<Vehicle> createVehicle(Json body) async => _decode(
    (await client.request('POST', '/v1/vehicles', body: body))['data'],
  );

  void close() => client.close();
}
