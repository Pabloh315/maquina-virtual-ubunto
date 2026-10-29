import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_exception.dart';
import 'api_transport.dart';

/// Transporte nativo. HTTP solo se habilita expresamente para loopback local.
class HttpApiTransport implements ApiTransport {
  HttpApiTransport(
    this.baseUrl, {
    bool allowLocalHttp = false,
    this.timeout = const Duration(seconds: 15),
    HttpClient? client,
    this.onResponse,
  }) : _client = client ?? HttpClient() {
    final local = const [
      '10.0.2.2',
      '127.0.0.1',
      'localhost',
      '::1',
    ].contains(baseUrl.host);
    if (baseUrl.host.isEmpty ||
        baseUrl.host.endsWith('.invalid') ||
        baseUrl.userInfo.isNotEmpty ||
        baseUrl.hasQuery ||
        baseUrl.hasFragment ||
        (baseUrl.scheme != 'https' &&
            !(allowLocalHttp && local && baseUrl.scheme == 'http'))) {
      _client.close(force: true);
      throw ArgumentError(
        'Usa HTTPS o habilita HTTP local para el emulador/USB.',
      );
    }
    _client.connectionTimeout = timeout;
  }

  final Uri baseUrl;
  final Duration timeout;
  final HttpClient _client;
  final void Function(String method, String path, int status)? onResponse;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  }) async {
    HttpClientRequest? outgoing;
    try {
      if (!path.startsWith('/') ||
          path.contains('..') ||
          path.contains('?') ||
          path.contains('#')) {
        throw const ApiException(0, 'INVALID_PATH', 'Ruta de API inválida.');
      }
      final uri = baseUrl.replace(
        path: '${baseUrl.path.replaceFirst(RegExp(r'/$'), '')}$path',
        queryParameters: query.isEmpty ? null : query,
      );
      return await (() async {
        final request = await _client.openUrl(method, uri);
        outgoing = request;
        request.followRedirects = false;
        headers.forEach(request.headers.set);
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        final response = await request.close();
        onResponse?.call(method, uri.path, response.statusCode);
        final text = await response.transform(utf8.decoder).join();
        Map<String, dynamic> json;
        try {
          json = text.isEmpty
              ? <String, dynamic>{'data': null}
              : jsonDecode(text) as Map<String, dynamic>;
        } on FormatException {
          throw ApiException(
            response.statusCode >= 400 ? response.statusCode : 502,
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
        if (response.statusCode >= 300 && response.statusCode < 400) {
          throw const ApiException(
            502,
            'UNEXPECTED_REDIRECT',
            'La dirección de la API redirige a otra página. Revisa la configuración.',
          );
        }
        if (response.statusCode >= 400) {
          throw ApiException.fromJson(response.statusCode, json);
        }
        return json;
      })().timeout(timeout);
    } on TimeoutException {
      outgoing?.abort();
      throw const ApiException(
        0,
        'TIMEOUT',
        'La API tardó demasiado. Inténtalo de nuevo.',
      );
    } on HandshakeException {
      throw const ApiException(
        0,
        'TLS_ERROR',
        'No se pudo establecer una conexión segura.',
      );
    } on SocketException {
      throw const ApiException(
        0,
        'NETWORK_ERROR',
        'No se pudo conectar con la API. Comprueba el servidor y tu conexión.',
      );
    } on HttpException {
      throw const ApiException(
        0,
        'CONNECTION_CLOSED',
        'Se interrumpió la conexión con la API. Inténtalo de nuevo.',
      );
    }
  }

  @override
  void close() => _client.close(force: true);
}
