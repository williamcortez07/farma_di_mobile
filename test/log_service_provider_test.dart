import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';
import 'package:farma_di_mobile/presentation/providers/log_provider.dart';
import 'package:farma_di_mobile/services/log_service.dart';

class _MockLogRepository extends LogRepository {
  _MockLogRepository(this.handler)
      : super(ApiClient(client: MockClient((_) async => http.Response('{}', 200))));

  final Future<PagedLogResponse> Function(String endpoint, Map<String, dynamic> params) handler;

  @override
  Future<PagedLogResponse> getTodayLogs({int page = 1, int limit = 10}) {
    return handler('today', {'page': page, 'limit': limit});
  }

  @override
  Future<PagedLogResponse> getLogsByLevel(String level, {int page = 1, int limit = 10}) {
    return handler('level/$level', {'page': page, 'limit': limit});
  }
}

void main() {
  final sampleInfoLog = SystemLogModel(
    id: 'info-1',
    traceId: 'tr-1',
    timestamp: DateTime.now(),
    level: 'Information',
    userId: 'user1',
    request: const LogRequestModel(method: 'GET', path: '/api/Products'),
    response: const LogResponseModel(statusCode: 200, elapsedMilliseconds: 15),
  );

  final sampleErrorLog = SystemLogModel(
    id: 'err-1',
    traceId: 'tr-2',
    timestamp: DateTime.now(),
    level: 'Error',
    userId: 'user2',
    request: const LogRequestModel(method: 'POST', path: '/api/Orders'),
    response: const LogResponseModel(statusCode: 500, elapsedMilliseconds: 80),
    exception: const LogExceptionModel(message: 'Database timeout'),
  );

  group('LogService tests', () {
    test('routes categories to correct repository methods', () async {
      final calls = <String>[];
      final repo = _MockLogRepository((endpoint, params) async {
        calls.add('$endpoint:page=${params['page']}&limit=${params['limit']}');
        return const PagedLogResponse(data: []);
      });

      final service = LogService(repo);

      await service.fetchLogsByCategory(LogCategory.today, page: 1, limit: 10);
      expect(calls.last, 'today:page=1&limit=10');

      await service.fetchLogsByCategory(LogCategory.information, page: 2, limit: 15);
      expect(calls.last, 'level/Information:page=2&limit=15');

      await service.fetchLogsByCategory(LogCategory.warning, page: 1, limit: 10);
      expect(calls.last, 'level/Warning:page=1&limit=10');

      await service.fetchLogsByCategory(LogCategory.error, page: 3, limit: 20);
      expect(calls.last, 'level/Error:page=3&limit=20');
    });

    test('computes counts correctly', () {
      final service = LogService(
        _MockLogRepository((endpoint, params) async => const PagedLogResponse(data: [])),
      );

      final counts = service.computeCounts([sampleInfoLog, sampleErrorLog]);
      expect(counts['total'], 2);
      expect(counts['Information'], 1);
      expect(counts['Error'], 1);
      expect(counts['Warning'], 0);
    });
  });

  group('LogProvider tests', () {
    test('initializes with today logs and updates status to success', () async {
      final repo = _MockLogRepository((endpoint, params) async {
        return PagedLogResponse(data: [sampleInfoLog]);
      });

      final service = LogService(repo);
      final provider = LogProvider(logService: service);

      expect(provider.status, LogProviderStatus.initial);
      await provider.fetchLogs();

      expect(provider.status, LogProviderStatus.success);
      expect(provider.logs.length, 1);
      expect(provider.selectedCategory, LogCategory.today);
    });

    test('category change fetches corresponding category logs', () async {
      final repo = _MockLogRepository((endpoint, params) async {
        if (endpoint.contains('Error')) {
          return PagedLogResponse(data: [sampleErrorLog]);
        }
        return PagedLogResponse(data: [sampleInfoLog]);
      });

      final service = LogService(repo);
      final provider = LogProvider(logService: service);

      await provider.fetchLogs(category: LogCategory.error);

      expect(provider.selectedCategory, LogCategory.error);
      expect(provider.logs.first.id, 'err-1');
      expect(provider.logs.first.level, 'Error');
    });

    test('pagination loads next page and appends records', () async {
      final repo = _MockLogRepository((endpoint, params) async {
        final page = params['page'] as int;
        if (page == 1) {
          return PagedLogResponse(
            data: List.generate(
              10,
              (i) => SystemLogModel(id: 'item-$i', level: 'Information'),
            ),
            meta: const LogMetaModel(totalPages: 2, currentPage: 1),
          );
        } else {
          return PagedLogResponse(
            data: [
              SystemLogModel(id: 'item-10', level: 'Information'),
            ],
            meta: const LogMetaModel(totalPages: 2, currentPage: 2),
          );
        }
      });

      final service = LogService(repo);
      final provider = LogProvider(logService: service);

      await provider.fetchLogs();
      expect(provider.logs.length, 10);
      expect(provider.hasMore, true);

      await provider.loadMore();
      expect(provider.logs.length, 11);
      expect(provider.currentPage, 2);
      expect(provider.hasMore, false);
    });
  });
}
