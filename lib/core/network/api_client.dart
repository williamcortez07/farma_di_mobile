
import 'dart:convert';

import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<dynamic> get(String path) {
    return _send('GET', path);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
  }) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
  }) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> delete(String path) {
    return _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
  }) async {
    final baseUrl = ApiConstants.instance.baseUrl.trim();

    if (baseUrl.isEmpty) {
      throw Exception('La URL de la API no est├í configurada.');
    }

    final uri = Uri.parse(baseUrl).resolve(path);

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    final request = http.Request(method, uri)
      ..headers.addAll(headers);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    try {
      final streamed = await _client
          .send(request)
          .timeout(ApiConstants.timeoutduration);

      final response = await http.Response.fromStream(streamed);

      dynamic data;

      if (response.body.trim().isNotEmpty) {
        try {
          data = jsonDecode(response.body);
        } on FormatException {
          data = response.body;
        }
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        var message = 'Error HTTP ${response.statusCode}';

        if (data is Map) {
          message = (data['message'] ??
                  data['Message'] ??
                  data['title'] ??
                  data['detail'] ??
                  message)
              .toString();
        }

        throw Exception(message);
      }

      return data;
    } on http.ClientException catch (e) {
      throw Exception('Error de conexi├│n con la API: $e');
    } on FormatException catch (e) {
      throw Exception('Respuesta JSON inv├ílida: $e');
    }
  }
}
