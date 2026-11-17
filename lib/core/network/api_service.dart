import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiService {
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final String _baseUrl;

  // Fetches a JSON object with optional query parameters.
  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) {
    return _request('GET', path, query: query);
  }

  // Sends a JSON payload without changing the caller's event identity.
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) {
    return _request('POST', path, body: body);
  }

  // Classifies HTTP, transport, timeout and malformed-response failures.
  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final client = http.Client();
    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(path: path, queryParameters: query);
      final headers = {
        HttpHeaders.acceptHeader: 'application/json',
        if (body != null) HttpHeaders.contentTypeHeader: 'application/json',
      };
      final response =
          await (method == 'GET'
                  ? client.get(uri, headers: headers)
                  : client.post(uri, headers: headers, body: jsonEncode(body)))
              .timeout(AppConfig.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String? code;
        try {
          final error = jsonDecode(response.body);
          if (error is Map<String, dynamic> && error['code'] is String) {
            code = error['code'] as String;
          }
        } on FormatException {
          code = null;
        }
        throw ApiException(
          ApiFailure.server,
          statusCode: response.statusCode,
          code: code,
        );
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
