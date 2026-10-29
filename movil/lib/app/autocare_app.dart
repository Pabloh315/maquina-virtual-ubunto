import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/api/api_client.dart';
import '../core/api/http_api_transport.dart';
import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../data/mock/mock_api_transport.dart';
import '../data/repositories/autocare_repository.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/home_screen.dart';
import '../features/vehicles/vehicle_screens.dart';
import '../features/maintenance/maintenance_screens.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/workshops/workshop_screens.dart';
import '../features/appointments/appointment_screens.dart';
import '../features/history/history_screen.dart';
import '../shared/widgets.dart';
import 'app_controller.dart';
import 'app_routes.dart';
import 'app_scope.dart';

class AutoCareApp extends StatefulWidget {
  const AutoCareApp({super.key, this.repository});
  final AutoCareRepository? repository;
  @override
  State<AutoCareApp> createState() => _AutoCareAppState();
}

class _AutoCareAppState extends State<AutoCareApp> {
  late final AppController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AppController(
      widget.repository ??
          AutoCareRepository(
            ApiClient(
              AppConfig.isMock
                  ? MockApiTransport()
                  : HttpApiTransport(Uri.parse(AppConfig.baseUrl)),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Route<void> _route(RouteSettings settings) {
    final name = !_controller.signedIn ? AppRoutes.login : settings.name;
    final page = switch (name) {
      AppRoutes.login => const LoginScreen(),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.vehicles => const VehiclesScreen(),
      AppRoutes.vehicle => const VehicleScreen(),
      AppRoutes.maintenance => const MaintenanceScreen(),
      AppRoutes.register => const RegisterServiceScreen(),
      AppRoutes.alerts => const AlertsScreen(),
      AppRoutes.workshops => const WorkshopsScreen(),
      AppRoutes.workshop => WorkshopScreen(
        id: settings.arguments as String? ?? '',
      ),
      AppRoutes.booking => BookingScreen(
        workshopId: settings.arguments as String?,
      ),
      AppRoutes.appointments => const AppointmentsScreen(),
      AppRoutes.history => const HistoryScreen(),
      _ => const AppPage(
        title: 'Página no disponible',
        subtitle: 'Usa la barra inferior para continuar',
        children: [Notice('No se encontró esta pantalla.')],
      ),
    };
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) => AppScope(
    controller: _controller,
    child: MaterialApp(
      title: 'AutoCare',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('es', 'BO'),
      supportedLocales: const [Locale('es', 'BO')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      onGenerateRoute: _route,
    ),
  );
}
