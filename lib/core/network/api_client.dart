import 'dart:convert';
import 'dart:async';

import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient({this.tokenProvider, http.Client? client})
      : _client = client ?? http.Client();

  final Future<String?> Function()? tokenProvider;
  final http.Client _client;

  Future<dynamic> get(String path, { Map<String, String>? query }) async => _send('GET', path, query, null);
  Future<dynamic> post(String path, { Object? body }) async => _send('POST', path, null, body);
  Future<dynamic> put(String path, { Object? body }) async => _send('PUT', path, null, body);
  Future<dynamic> delete(String path) async => _send('DELETE', path, null, null);

  Future<dynamic> _send(String method, String path, Map<String, String>? query, Object? body) async {
    final baseUrl = ApiConstants.instance.baseUrl;
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = {'Content-Type': 'application/json'};
    final token = await tokenProvider?.call();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await _client.send(request)
        .timeout(ApiConstants.timeoutduration)
        .then(http.Response.fromStream);
    } on TimeoutException {
      throw const NetworkException('Request timed out. Please try again later.');
    } on http.ClientException {
      throw const NetworkException();
    }

    debugPrint('→ $method $uri');
    debugPrint('→ body: ${request.body}');
    debugPrint('← ${response.statusCode}: ${response.body}');

    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    if (response.statusCode == 404) {
      throw const NotFoundException();
    }

    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(_extractMessage(response), statusCode: response.statusCode);
    }

    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ParsingException();
    }
  }

  String _extractMessage(http.Response response){
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] is String) return data['message'] as String;
    } catch(_){}
    return 'Respuesta fallida del servidor con código de estado ${response.statusCode}.';
  }

  void dispose() => _client.close();
}
