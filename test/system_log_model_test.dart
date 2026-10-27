import 'package:flutter_test/flutter_test.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';

void main() {
  group('SystemLogModel JSON Serialization', () {
    test('deserializes sample warning log from user correctly', () {
      final jsonSample = {
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
      };

      final log = SystemLogModel.fromJson(jsonSample);

      expect(log.id, '6adbc0b37d24d65cc1b8fd4c');
      expect(log.traceId, '0HNPH7QURQKLD:00000001');
      expect(log.level, 'Warning');
      expect(log.environment, 'Development');
      expect(log.clientIp, '::1');
      expect(log.userId, 'Anonimo');
      expect(log.timestamp?.year, 2026);
      expect(log.timestamp?.month, 10);
      expect(log.timestamp?.day, 23);

      expect(log.request, isNotNull);
      expect(log.request?.method, 'GET');
      expect(log.request?.path, '/v1/swagger.json');
      expect(log.request?.queryString, isNull);
      expect(log.request?.payload, isNull);

      expect(log.response, isNotNull);
      expect(log.response?.statusCode, 401);
      expect(log.response?.elapsedMilliseconds, 49);

      expect(log.exception, isNull);
      expect(log.displayMessage, contains('/v1/swagger.json'));
      expect(log.displayMessage, contains('401'));
    });

    test('deserializes log with full exception details', () {
      final jsonWithException = {
        "id": "err-12345",
        "traceId": "TRACE-ERR-999",
        "timestamp": "2026-10-26T12:00:00.000Z",
        "level": "Error",
        "environment": "Production",
        "clientIp": "192.168.1.50",
        "userId": "admin@farmadi.com",
        "request": {
          "method": "POST",
          "path": "/api/Products",
          "queryString": "active=true",
          "payload": "{\"name\":\"Aspirina\"}",
        },
        "response": {
          "statusCode": 500,
          "elapsedMilliseconds": 182,
        },
        "exception": {
          "message": "Fallo de conexión a la base de datos SQL.",
          "stackTrace": "at FarmaDi.Data.SqlDbContext...",
          "source": "Microsoft.EntityFrameworkCore",
        },
      };

      final log = SystemLogModel.fromJson(jsonWithException);

      expect(log.level, 'Error');
      expect(log.exception, isNotNull);
      expect(log.exception?.message, 'Fallo de conexión a la base de datos SQL.');
      expect(log.exception?.source, 'Microsoft.EntityFrameworkCore');
      expect(log.displayMessage, 'Fallo de conexión a la base de datos SQL.');
    });

    test('deserializes PagedLogResponse with meta', () {
      final pagedJson = {
        "data": [
          {
            "id": "log-1",
            "level": "Information",
            "request": {"method": "GET", "path": "/api/Home"},
            "response": {"statusCode": 200, "elapsedMilliseconds": 15},
          },
          {
            "id": "log-2",
            "level": "Error",
            "request": {"method": "POST", "path": "/api/Auth/login"},
            "response": {"statusCode": 401, "elapsedMilliseconds": 22},
          }
        ],
        "meta": {
          "totalItems": 150,
          "totalPages": 15,
          "currentPage": 1,
          "pageSize": 10,
        }
      };

      final paged = PagedLogResponse.fromJson(pagedJson);

      expect(paged.data.length, 2);
      expect(paged.data[0].id, 'log-1');
      expect(paged.data[1].id, 'log-2');
      expect(paged.meta, isNotNull);
      expect(paged.meta?.totalItems, 150);
      expect(paged.meta?.totalPages, 15);
      expect(paged.meta?.currentPage, 1);
      expect(paged.meta?.pageSize, 10);
    });
  });
}
