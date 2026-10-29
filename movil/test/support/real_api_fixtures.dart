import 'package:movil/core/api/api_transport.dart';

Map<String, dynamic> laravelVehicle([int id = 1]) => {
  'id': id,
  'owner_id': 4,
  'license_plate': 'REAL-$id',
  'vin': null,
  'year': 2024,
  'color': 'Azul',
  'fuel_type': 'gasolina',
  'current_mileage': 12500,
  'is_active': true,
  'category': {'id': 2, 'name': 'Automóvil'},
  'model': {
    'id': 3,
    'name': 'Corolla Demo',
    'make': {'id': 5, 'name': 'Toyota'},
  },
};

Map<String, dynamic> vehiclePage(
  List<dynamic> vehicles, {
  int page = 1,
  int last = 1,
}) => {
  'data': vehicles,
  'meta': {
    'current_page': page,
    'last_page': last,
    'per_page': 15,
    'total': vehicles.length,
  },
};

class FixtureTransport implements ApiTransport {
  final List<String> calls = [];
  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  }) async {
    calls.add('$method $path');
    return switch (path) {
      '/health' => {'status': 'ok', 'service': 'mantenimiento-vehiculos-api'},
      '/database' => {
        'status': 'ok',
        'database': 'reachable',
        'driver': 'pgsql',
      },
      '/v1/vehicles' => vehiclePage([laravelVehicle()]),
      _ => {'data': laravelVehicle()},
    };
  }

  @override
  void close() {}
}
