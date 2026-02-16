class ApiRequestException implements Exception {
  const ApiRequestException({
    required this.code,
    this.statusCode,
    this.message,
  });

  final String code;
  final int? statusCode;
  final String? message;

  @override
  String toString() => 'ApiRequestException(code: $code, statusCode: $statusCode, message: $message)';
}
