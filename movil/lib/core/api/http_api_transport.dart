import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_exception.dart';
import 'api_transport.dart';

/// Adaptador nativo preparado para EDT 3.4. La app usa el mock por defecto.
class HttpApiTransport implements ApiTransport {
  HttpApiTransport(this.baseUrl) {
    if (baseUrl.scheme != 'https' || baseUrl.host.endsWith('.invalid')) {
      throw ArgumentError('Configura una URL HTTPS operativa para la API.');
    }
  }

  final Uri baseUrl;
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = baseUrl.replace(
        path: '${baseUrl.path.replaceFirst(RegExp(r'/$'), '')}$path',
        queryParameters: query.isEmpty ? null : query,
      );
      return await (() async {
        final request = await _client.openUrl(method, uri);
        headers.forEach(request.headers.set);
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        final response = await request.close();
        final text = await response.transform(utf8.decoder).join();
        Map<String, dynamic> json;
        try {
          json = text.isEmpty
              ? <String, dynamic>{'data': null}
              : jsonDecode(text) as Map<String, dynamic>;
        } on FormatException {
          throw const ApiException(
            502,
            'INVALID_RESPONSE',
            'El servidor devolvió una respuesta no válida.',
          );
        } on TypeError {
          throw const ApiException(
            502,
            'INVALID_RESPONSE',
            'El servidor devolvió una respuesta no válida.',
          );
        }
        if (response.statusCode >= 400) {
          throw ApiException.fromJson(response.statusCode, json);
        }
        return json;
      })().timeout(const Duration(seconds: 20));
    } on SocketException {
      throw const ApiException(
        0,
        'NETWORK_ERROR',
        'No se pudo conectar. Comprueba tu conexión e inténtalo de nuevo.',
      );
    } on TimeoutException {
      throw const ApiException(0, 'TIMEOUT', 'La solicitud tardó demasiado.');
    } on HandshakeException {
      throw const ApiException(
        0,
        'TLS_ERROR',
        'No se pudo establecer una conexión segura.',
      );
    }
  }

  @override
  void close() => _client.close(force: true);
}
