import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';

class _FakeLogRepository extends LogRepository {
  _FakeLogRepository(this._response, {this.shouldThrow = false})
      : super(ApiClient(client: MockClient((_) async => http.Response('{}', 200))));

  final PagedLogResponse _response;
  final bool shouldThrow;

  @override
  Future<PagedLogResponse> getLogs({
    int page = 1,
    int limit = 20,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldThrow) {
      throw const NetworkException('Fallo de red simulado');
    }
    return _response;
  }
}

void main() {
  final sampleLogs = [
    SystemLogModel(
      id: 'L-1',
      level: 'Information',
      userId: 'user1',
      clientIp: '10.0.0.1',
      request: const LogRequestModel(method: 'GET', path: '/api/Home'),
      response: const LogResponseModel(statusCode: 200, elapsedMilliseconds: 10),
    ),
    SystemLogModel(
      id: 'L-2',
      level: 'Warning',
      userId: 'Anonimo',
      clientIp: '10.0.0.2',
      request: const LogRequestModel(method: 'GET', path: '/v1/swagger.json'),
      response: const LogResponseModel(statusCode: 401, elapsedMilliseconds: 49),
    ),
    SystemLogModel(
      id: 'L-3',
      level: 'Error',
      userId: 'admin',
      clientIp: '10.0.0.3',
      request: const LogRequestModel(method: 'POST', path: '/api/Products'),
      response: const LogResponseModel(statusCode: 500, elapsedMilliseconds: 120),
      exception: const LogExceptionModel(message: 'Error de servidor SQL'),
    ),
  ];

  test('LogController fetchLogs calculates counts and sets status to success', () async {
    final repo = _FakeLogRepository(PagedLogResponse(data: sampleLogs));
    final controller = LogController(repo);

    expect(controller.status, LogStatus.initial);

    await controller.fetchLogs();

    expect(controller.status, LogStatus.success);
    expect(controller.logs.length, 3);
    expect(controller.errorCount, 1);
    expect(controller.warningCount, 1);
    expect(controller.infoCount, 1);
  });

  test('LogController filters logs by level correctly', () async {
    final repo = _FakeLogRepository(PagedLogResponse(data: sampleLogs));
    final controller = LogController(repo);
    await controller.fetchLogs();

    controller.setFilter('ERROR');
    expect(controller.logs.length, 1);
    expect(controller.logs.first.id, 'L-3');

    controller.setFilter('WARN');
    expect(controller.logs.length, 1);
    expect(controller.logs.first.id, 'L-2');

    controller.setFilter('INFO');
    expect(controller.logs.length, 1);
    expect(controller.logs.first.id, 'L-1');

    controller.setFilter('ALL');
    expect(controller.logs.length, 3);
  });

  test('LogController searches logs by query correctly', () async {
    final repo = _FakeLogRepository(PagedLogResponse(data: sampleLogs));
    final controller = LogController(repo);
    await controller.fetchLogs();

    controller.setSearchQuery('swagger');
    expect(controller.logs.length, 1);
    expect(controller.logs.first.id, 'L-2');

    controller.setSearchQuery('10.0.0.3');
    expect(controller.logs.length, 1);
    expect(controller.logs.first.id, 'L-3');

    controller.setSearchQuery('servidor');
    expect(controller.logs.length, 1);
    expect(controller.logs.first.id, 'L-3');

    controller.setSearchQuery('inexistente');
    expect(controller.logs.isEmpty, true);
  });

  test('LogController handles error when repository fails', () async {
    final repo = _FakeLogRepository(
      const PagedLogResponse(data: []),
      shouldThrow: true,
    );
    final controller = LogController(repo);

    await controller.fetchLogs();

    expect(controller.status, LogStatus.error);
    expect(controller.errorMessage, 'Fallo de red simulado');
  });
}
