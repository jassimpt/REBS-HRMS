enum ApiFailure { unavailable, timeout, server, invalidResponse }

class ApiException implements Exception {
  const ApiException(this.failure, {this.statusCode});

  final ApiFailure failure;
  final int? statusCode;
}
