import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movil/app/app_routes.dart';
import 'package:movil/app/autocare_app.dart';
import 'package:movil/core/api/api_client.dart';
import 'package:movil/data/mock/mock_api_transport.dart';
import 'package:movil/data/repositories/autocare_repository.dart';

void main() {
  testWidgets('Acceso demo, cuatro pestañas y las doce pantallas sin errores', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      AutoCareApp(
        repository: AutoCareRepository(
          ApiClient(MockApiTransport(latency: Duration.zero)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido a AutoCare'), findsOneWidget);
    await tester.tap(find.text('Usar cuenta de demostración'));
    final login = find.widgetWithText(FilledButton, 'Iniciar sesión');
    await tester.ensureVisible(login);
    await tester.tap(login);
    await tester.pumpAndSettle();
    expect(find.text('Resumen de tu vehículo'), findsOneWidget);
    expect(find.text('Toyota Hilux 2020'), findsOneWidget);

    for (final tab in ['Vehículos', 'Talleres', 'Historial', 'Inicio']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
    }

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final screens = <String, String>{
      AppRoutes.vehicle: 'Toyota Hilux 2020',
      AppRoutes.maintenance: 'Seguimiento preventivo y correctivo',
      AppRoutes.register: 'Registra un antecedente de tu vehículo',
      AppRoutes.alerts: 'Mantén tu vehículo al día',
      AppRoutes.workshop: 'Servicios y atención',
      AppRoutes.booking: 'Selecciona servicio, día y horario',
      AppRoutes.appointments: 'Próximas y anteriores',
    };
    for (final entry in screens.entries) {
      navigator.pushNamed(
        entry.key,
        arguments: entry.key == AppRoutes.workshop ? 't1' : null,
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets);
      expect(tester.takeException(), isNull, reason: entry.key);
      navigator.pop();
      await tester.pumpAndSettle();
    }
  });
}
