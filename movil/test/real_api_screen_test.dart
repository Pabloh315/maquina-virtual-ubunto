import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movil/app/autocare_app.dart';
import 'package:movil/core/api/api_client.dart';
import 'package:movil/data/repositories/real_api_repository.dart';
import 'support/real_api_fixtures.dart';

void main() {
  testWidgets('La versión real no solicita login y muestra datos Laravel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      AutoCareApp(
        useMock: false,
        realRepository: RealApiRepository(ApiClient(FixtureTransport())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Conexión y vehículos'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
    await tester.tap(find.byKey(const Key('connect-real-api')));
    await tester.pumpAndSettle();
    expect(find.text('Conectada · pgsql'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('real-vehicle-1')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('real-vehicle-1')));
    await tester.pumpAndSettle();
    expect(find.text('Toyota Corolla Demo 2024'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
