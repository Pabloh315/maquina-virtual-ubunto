import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movil/app/app_routes.dart';
import 'package:movil/app/autocare_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Recorrido Android y capturas de AutoCare', (tester) async {
    await tester.pumpWidget(const AutoCareApp(useMock: true));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01_acceso');
    await tester.tap(find.text('Usar cuenta de demostración'));
    final login = find.widgetWithText(FilledButton, 'Iniciar sesión');
    await tester.ensureVisible(login);
    await tester.tap(login);
    // Esperar las consultas asíncronas del transporte simulado en el dispositivo.
    await tester.pumpAndSettle();
    expect(find.text('Resumen de tu vehículo'), findsOneWidget);
    // El árbol puede estar actualizado antes de que Android presente el frame.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02_inicio');
    for (final tab in ['Vehículos', 'Talleres', 'Historial']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await binding.takeScreenshot('03_historial');
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    for (final route in [
      AppRoutes.vehicle,
      AppRoutes.maintenance,
      AppRoutes.register,
      AppRoutes.alerts,
      AppRoutes.workshop,
      AppRoutes.booking,
      AppRoutes.appointments,
    ]) {
      navigator.pushNamed(
        route,
        arguments: route == AppRoutes.workshop ? 't1' : null,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
      navigator.pop();
      await tester.pumpAndSettle();
    }
  });
}
