import 'package:flutter_test/flutter_test.dart';
import 'package:movil/core/api/api_client.dart';
import 'package:movil/core/api/api_exception.dart';
import 'package:movil/data/mock/mock_api_transport.dart';
import 'package:movil/data/models/models.dart';
import 'package:movil/data/repositories/autocare_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AutoCareRepository repository;
  setUp(() {
    repository = AutoCareRepository(
      ApiClient(MockApiTransport(latency: Duration.zero)),
    );
  });
  tearDown(() => repository.close());
  Future<void> login() => repository.login('demo@ejemplo.test', 'clave_demo');

  test('Rechaza credenciales incorrectas y consultas sin sesión', () async {
    await expectLater(
      repository.vehicles(),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
    );
    await expectLater(
      repository.login('otro@ejemplo.test', 'incorrecta'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'UNAUTHORIZED'),
      ),
    );
    await login();
    await repository.logout();
    await expectLater(repository.vehicles(), throwsA(isA<ApiException>()));
  });

  test('Decodifica campos del contrato y filtra por ID opaco', () async {
    await login();
    final vehicles = await repository.vehicles();
    expect(vehicles.first.id, 'v1');
    expect(vehicles.first.odometerKm, 82400);
    expect((await repository.plans('v2')).single.vehicleId, 'v2');
    expect(await repository.history('v2'), isEmpty);
    expect((await repository.alerts('v2')).single.id, 'a3');
  });

  test('El sobre incluye meta y respeta las páginas', () async {
    await login();
    final response = await repository.client.request(
      'GET',
      '/vehicles',
      query: {'page': '2', 'page_size': '1'},
    );
    expect((response['data'] as List).single['id'], 'v2');
    expect(response['meta'], {'page': 2, 'page_size': 1, 'total': 2});
  });

  test(
    'Una lectura menor requiere revisión y conserva el kilometraje',
    () async {
      await login();
      await expectLater(
        repository.updateOdometer('v1', 82000),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'ODOMETER_REVIEW_REQUIRED')
              .having((e) => e.details['previous_km'], 'previous_km', 82400),
        ),
      );
      expect((await repository.vehicles()).first.odometerKm, 82400);
      await repository.updateOdometer('v1', 82500);
      expect((await repository.vehicles()).first.odometerKm, 82500);
    },
  );

  test(
    'Un antecedente desconocido no altera historial ni intervalos',
    () async {
      await login();
      final history = await repository.history('v1');
      final dueKm = (await repository.plans('v1')).first.nextDueKm;
      await repository.saveBackground(
        'v1',
        service: 'oil_change',
        known: false,
      );
      final backgrounds = await repository.client.request(
        'GET',
        '/vehicles/v1/backgrounds',
      );
      expect((backgrounds['data'] as List).single['known'], isFalse);
      expect((backgrounds['data'] as List).single['date'], isNull);
      expect((await repository.history('v1')).length, history.length);
      expect((await repository.plans('v1')).first.nextDueKm, dueKm);
    },
  );

  test(
    'Reserva idempotente, conflicto de cupo y liberación al cancelar',
    () async {
      await login();
      Future<void> book(String key) => repository.book(
        vehicleId: 'v1',
        workshopId: 't1',
        service: 'brakes',
        startsAt: '2026-11-15T09:00:00-04:00',
        key: key,
      );
      await book('reserva-1');
      await book('reserva-1');
      expect((await repository.appointments()).length, 3);
      await expectLater(
        book('reserva-2'),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'SLOT_UNAVAILABLE'),
        ),
      );
      final appointment = (await repository.appointments()).last;
      await repository.cancel(appointment.id);
      await book('reserva-2');
      expect(
        (await repository.appointments())
            .where((a) => a.status == 'confirmed')
            .length,
        2,
      );
    },
  );

  test('Un plan vence por el primero de los límites', () {
    final plan = MaintenancePlan.fromJson({
      'id': 'p1',
      'vehicle_id': 'v1',
      'service': 'oil_change',
      'source': 'manual_fabricante',
      'next_due_km': 83000,
      'next_due_date': '2026-11-01',
    });
    expect(plan.isDue(83000, DateTime(2026, 10, 1)), isTrue);
    expect(plan.isDue(82000, DateTime(2026, 11, 1)), isTrue);
    expect(plan.isDue(82000, DateTime(2026, 10, 1)), isFalse);
  });

  test(
    'El fixture conserva el intervalo del último servicio confirmado',
    () async {
      await login();
      final history = (await repository.history(
        'v1',
      )).firstWhere((h) => h.service == 'oil_change');
      final response = await repository.client.request(
        'GET',
        '/vehicles/v1/plans',
      );
      final plan = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['service'] == 'oil_change');
      expect(plan['last_confirmed_km'], history.odometerKm);
      expect(plan['last_confirmed_date'], '2026-07-12');
      expect(
        plan['next_due_km'],
        history.odometerKm + (plan['interval_km'] as int),
      );
      expect(plan['next_due_date'], '2027-01-12');
    },
  );
}
