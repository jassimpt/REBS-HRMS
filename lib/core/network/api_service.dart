import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiService {
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final String _baseUrl;

  // Fetches a JSON object and classifies transport and server failures.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final client = http.Client();
    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(path: path, queryParameters: query);
      final response = await client
          .get(uri, headers: {HttpHeaders.acceptHeader: 'application/json'})
          .timeout(AppConfig.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(ApiFailure.server, statusCode: response.statusCode);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException(ApiFailure.invalidResponse);
      }
      return decoded;
    } on TimeoutException {
      throw const ApiException(ApiFailure.timeout);
    } on SocketException {
      throw const ApiException(ApiFailure.unavailable);
    } on http.ClientException {
      throw const ApiException(ApiFailure.unavailable);
    } on FormatException {
      throw const ApiException(ApiFailure.invalidResponse);
    } finally {
      client.close();
    }
  }
}
