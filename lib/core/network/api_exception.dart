enum ApiFailure { unavailable, timeout, server, invalidResponse }

class ApiException implements Exception {
  const ApiException(this.failure, {this.statusCode, this.code});

  final ApiFailure failure;
  final int? statusCode;
  final String? code;

  bool get isPermanentRejection =>
      statusCode != null &&
      statusCode! >= 400 &&
      statusCode! < 500 &&
      statusCode != 408 &&
      statusCode != 429;
}
