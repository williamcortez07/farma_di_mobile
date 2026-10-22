import 'dart:convert';

import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client = http.Client();

  Future <dynamic> get () async {}
  Future <dynamic> post () async {}
  Future <dynamic> put () async {}
  Future <dynamic> delete () async {}


  Future <dynamic> _send (String method, String path, Map<String, String> query, Object? body) async {
    final baseUrl = ApiConstants.instance.baseUrl;
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = {'Content-Type': 'application/json'};
    if(body != null) {
      headers['Content-Type'] = 'application/json';
    }

    final request = http.Request(method, uri).. headers.addAll(headers);
    if (body != null){
      request.body = jsonEncode(body);

    }

    final http.Response response;
    try {
     final stream = await _client.send(request).timeout(ApiConstants.timeoutduration);
     response = await http.Response.fromStream(stream);
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
    return response;
  }
}
