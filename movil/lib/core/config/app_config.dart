import 'package:flutter/foundation.dart';

class AppConfig {
  static const apiMode = String.fromEnvironment(
    'API_MODE',
    defaultValue: 'http',
  );
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
  static bool get isMock => apiMode == 'mock';
  static const allowLocalHttp = bool.fromEnvironment(
    'API_ALLOW_LOCAL_HTTP',
    defaultValue: !kReleaseMode,
  );
}
