/// Un transporte devuelve el sobre JSON del contrato, o lanza ApiException.
abstract interface class ApiTransport {
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  });

  void close();
}
