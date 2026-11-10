import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../core/api/api_client.dart';
import '../../core/api/http_api_transport.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/real_api_repository.dart';
import '../../shared/widgets.dart';
import 'real_api_screen.dart';

class RealApiApp extends StatefulWidget {
  const RealApiApp({super.key, this.repository});
  final RealApiRepository? repository;
  @override
  State<RealApiApp> createState() => _RealApiAppState();
}

class _RealApiAppState extends State<RealApiApp> {
  RealApiRepository? _repository;
  String? _configurationError;
  @override
  void initState() {
    super.initState();
    try {
      if (!['http', 'mock'].contains(AppConfig.apiMode)) {
        throw ArgumentError('API_MODE debe ser http o mock.');
      }
      _repository =
          widget.repository ??
          RealApiRepository(
            ApiClient(
              HttpApiTransport(
                Uri.parse(AppConfig.baseUrl),
                allowLocalHttp: AppConfig.allowLocalHttp,
              ),
            ),
          );
    } on ArgumentError catch (e) {
      _configurationError = e.message.toString();
    } on FormatException {
      _configurationError = 'La dirección API_BASE_URL no es válida.';
    }
  }

  @override
  void dispose() {
    _repository?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AutoCare · Integración real',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('es', 'BO'),
    supportedLocales: const [Locale('es', 'BO')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: _configurationError == null
        ? RealApiScreen(repository: _repository!, baseUrl: AppConfig.baseUrl)
        : AppPage(
            title: 'Revisar configuración',
            subtitle: 'AutoCare · API real',
            showNavigation: false,
            children: [Notice(_configurationError!, error: true)],
          ),
  );
}
