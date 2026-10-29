import 'api_transport.dart';

class ApiClient {
  ApiClient(this.transport);
  final ApiTransport transport;
  String? accessToken;

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) {
    return transport.request(
      method,
      path,
      headers: {
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        'Idempotency-Key': ?idempotencyKey,
      },
      query: query,
      body: body,
    );
  }

  void close() => transport.close();
}
