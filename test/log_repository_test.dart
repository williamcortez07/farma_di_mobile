import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(
      envString: 'BASE_API_URL=https://api.test\nENVIRONMENT=Test',
    );
  });

  tearDown(() {
    dotenv.clean();
  });

  final sampleResponse = jsonEncode({
    "data": [
      {
        "id": "6adbc0b37d24d65cc1b8fd4c",
        "traceId": "0HNPH7QURQKLD:00000001",
        "timestamp": "2026-10-23T20:16:51.196Z",
        "level": "Warning",
        "environment": "Development",
        "clientIp": "::1",
        "userId": "Anonimo",
        "request": {
          "method": "GET",
          "path": "/v1/swagger.json",
          "queryString": null,
          "payload": null,
        },
        "response": {
          "statusCode": 401,
          "elapsedMilliseconds": 49,
        },
        "exception": null,
      }
    ],
    "meta": {
      "totalItems": 1,
      "totalPages": 1,
      "currentPage": 1,
      "pageSize": 10,
    }
  });

  test('getLogs sends GET to /api/Logs with bearer token and query params', () async {
    late Uri capturedUri;
    late Map<String, String> capturedHeaders;

    final mockClient = MockClient((request) async {
      capturedUri = request.url;
      capturedHeaders = request.headers;
      return http.Response(
        sampleResponse,
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final apiClient = ApiClient(
      tokenProvider: () async => 'jwt-test-token',
      client: mockClient,
    );
    final repo = LogRepository(apiClient);

    final result = await repo.getLogs(
      page: 2,
      limit: 15,
      level: 'Warning',
      startDate: DateTime.parse('2026-10-01T00:00:00Z'),
      endDate: DateTime.parse('2026-10-25T23:59:59Z'),
    );

    expect(capturedUri.path, '/api/Logs');
    expect(capturedUri.queryParameters['page'], '2');
    expect(capturedUri.queryParameters['limit'], '15');
    expect(capturedUri.queryParameters['level'], 'Warning');
    expect(capturedUri.queryParameters['startDate'], isNotNull);
    expect(capturedUri.queryParameters['endDate'], isNotNull);
    expect(capturedHeaders['authorization'], 'Bearer jwt-test-token');

    expect(result.data.length, 1);
    expect(result.data.first.id, '6adbc0b37d24d65cc1b8fd4c');
    expect(result.data.first.level, 'Warning');
    expect(result.data.first.response?.statusCode, 401);
  });

  test('getLogsByLevel sends GET to /api/Logs/level/{level}', () async {
    late Uri capturedUri;

    final mockClient = MockClient((request) async {
      capturedUri = request.url;
      return http.Response(
        sampleResponse,
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final apiClient = ApiClient(client: mockClient);
    final repo = LogRepository(apiClient);

    await repo.getLogsByLevel('error', page: 1, limit: 10);

    expect(capturedUri.path, '/api/Logs/level/Error');
    expect(capturedUri.queryParameters['page'], '1');
    expect(capturedUri.queryParameters['limit'], '10');
  });

  test('getInformationLogs, getWarningLogs, getErrorLogs hit dedicated endpoints', () async {
    final pathsCalled = <String>[];

    final mockClient = MockClient((request) async {
      pathsCalled.add(request.url.path);
      return http.Response(
        sampleResponse,
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final apiClient = ApiClient(client: mockClient);
    final repo = LogRepository(apiClient);

    await repo.getInformationLogs();
    await repo.getWarningLogs();
    await repo.getErrorLogs();
    await repo.getTodayLogs();

    expect(pathsCalled, [
      ApiConstants.logsInformation,
      ApiConstants.logsWarning,
      ApiConstants.logsError,
      ApiConstants.logsToday,
    ]);
  });
}
