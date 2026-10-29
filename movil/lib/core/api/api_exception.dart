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
    final error = json['error'] as Map<String, dynamic>? ?? {};
    return ApiException(
      status,
      error['code'] as String? ?? 'UNKNOWN_ERROR',
      error['message'] as String? ?? 'No se pudo completar la solicitud.',
      details: error['details'] as Map<String, dynamic>? ?? {},
      requestId: error['request_id'] as String?,
    );
  }

  @override
  String toString() => message;
}
