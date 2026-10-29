class AppConfig {
  static const apiMode = String.fromEnvironment(
    'API_MODE',
    defaultValue: 'mock',
  );
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.invalid/api/v1',
  );
  static bool get isMock => apiMode == 'mock';
}
