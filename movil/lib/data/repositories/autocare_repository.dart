import '../../core/api/api_client.dart';
import '../models/models.dart';

class AutoCareRepository {
  AutoCareRepository(this.client);
  final ApiClient client;

  Future<String> login(String email, String password) async {
    final response = await client.request(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final data = response['data'] as Json;
    client.accessToken = data['access_token'] as String;
    return (data['user'] as Json)['name'] as String? ?? 'Conductor';
  }

  Future<void> logout() async {
    try {
      await client.request('POST', '/auth/logout');
    } finally {
      client.accessToken = null;
    }
  }

  Future<List<T>> _list<T>(
    String path,
    T Function(Json) decode, {
    Map<String, String> query = const {},
  }) async {
    // Consume todas las páginas para no truncar listas al conectar la API real.
    final result = <T>[];
    var page = 1;
    while (true) {
      final response = await client.request(
        'GET',
        path,
        query: {...query, 'page': '$page', 'page_size': '20'},
      );
      final records = response['data'] as List;
      result.addAll(records.map((r) => decode(r as Json)));
      final meta = response['meta'] as Json?;
      if (meta == null ||
          records.isEmpty ||
          result.length >= (meta['total'] as int)) {
        break;
      }
      page++;
    }
    return result;
  }

  Future<List<Vehicle>> vehicles() => _list('/vehicles', Vehicle.fromJson);
  Future<List<MaintenancePlan>> plans(String id) =>
      _list('/vehicles/$id/plans', MaintenancePlan.fromJson);
  Future<List<HistoryEntry>> history(String id) =>
      _list('/vehicles/$id/history', HistoryEntry.fromJson);
  Future<List<VehicleAlert>> alerts(String id) =>
      _list('/alerts', VehicleAlert.fromJson, query: {'vehicle_id': id});
  Future<List<Workshop>> workshops() => _list('/workshops', Workshop.fromJson);
  Future<List<Appointment>> appointments() =>
      _list('/appointments', Appointment.fromJson);

  Future<void> updateOdometer(String id, int km) async {
    await client.request(
      'POST',
      '/vehicles/$id/odometer-readings',
      body: {'odometer_km': km},
    );
  }

  Future<void> saveBackground(
    String id, {
    required String service,
    required bool known,
    String? date,
    String? notes,
  }) async {
    await client.request(
      'POST',
      '/vehicles/$id/backgrounds',
      body: {
        'service': service,
        'known': known,
        'date': known ? date : null,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  Future<void> book({
    required String vehicleId,
    required String workshopId,
    required String service,
    required String startsAt,
    required String key,
  }) async {
    await client.request(
      'POST',
      '/appointments',
      idempotencyKey: key,
      body: {
        'vehicle_id': vehicleId,
        'workshop_id': workshopId,
        'service': service,
        'starts_at': startsAt,
      },
    );
  }

  Future<void> cancel(String id) async {
    await client.request('POST', '/appointments/$id/cancel', body: {});
  }

  void close() => client.close();
}
