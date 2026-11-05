class ApiException implements Exception {
  const ApiException(
    this.status,
    this.code,
    this.message, {
    this.details = const {},
    this.requestId,
  });

  final int status;
  final String code;
  final String message;
  final Map<String, dynamic> details;
  final String? requestId;

  factory ApiException.fromJson(int status, Map<String, dynamic> json) {
    final error = json['error'] is Map<String, dynamic>
        ? json['error'] as Map<String, dynamic>
        : <String, dynamic>{};
    final code =
        error['code'] as String? ??
        switch (status) {
          401 => 'UNAUTHORIZED',
          403 => 'FORBIDDEN',
          404 => 'NOT_FOUND',
          422 => 'VALIDATION_ERROR',
          429 => 'RATE_LIMITED',
          _ => status >= 500 ? 'SERVER_ERROR' : 'HTTP_ERROR',
        };
    final safeMessage = switch (status) {
      401 => 'La API requiere iniciar sesión.',
      403 => 'No tienes acceso a esta operación.',
      404 => 'El recurso solicitado no está disponible.',
      429 => 'Demasiadas solicitudes. Espera un momento antes de reintentar.',
      _ =>
        status >= 500
            ? 'El servicio no está disponible. Inténtalo más tarde.'
            : null,
    };
    return ApiException(
      status,
      code,
      safeMessage ??
          error['message'] as String? ??
          json['message'] as String? ??
          'No se pudo completar la solicitud.',
      details:
          error['details'] as Map<String, dynamic>? ??
          json['errors'] as Map<String, dynamic>? ??
          {},
      requestId: error['request_id'] as String?,
    );
  }

  @override
  String toString() => message;
}
