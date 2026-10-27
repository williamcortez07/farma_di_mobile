import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';
import 'package:farma_di_mobile/presentation/screen/logs_screen.dart';

class _MockLogRepository extends LogRepository {
  _MockLogRepository(this._logs)
      : super(ApiClient(client: MockClient((_) async => http.Response('{}', 200))));

  final List<SystemLogModel> _logs;

  @override
  Future<PagedLogResponse> getLogs({
    int page = 1,
    int limit = 20,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return PagedLogResponse(data: _logs);
  }
}

void main() {
  setUp(() async {
    dotenv.loadFromString(
      envString: 'BASE_API_URL=https://api.test\nENVIRONMENT=Test',
    );

    final getIt = GetIt.instance;
    await getIt.reset();

    final fakeLogs = [
      SystemLogModel(
        id: '6adbc0b37d24d65cc1b8fd4c',
        traceId: '0HNPH7QURQKLD:00000001',
        timestamp: DateTime.parse('2026-10-23T20:16:51.196Z'),
        level: 'Warning',
        environment: 'Development',
        clientIp: '::1',
        userId: 'Anonimo',
        request: const LogRequestModel(
          method: 'GET',
          path: '/v1/swagger.json',
        ),
        response: const LogResponseModel(
          statusCode: 401,
          elapsedMilliseconds: 49,
        ),
      ),
    ];

    getIt.registerLazySingleton<LogRepository>(() => _MockLogRepository(fakeLogs));
    getIt.registerFactory<LogController>(() => LogController(getIt<LogRepository>()));
  });

  tearDown(() async {
    await GetIt.instance.reset();
    dotenv.clean();
  });

  testWidgets('LogsScreen renders header, search bar, filters and log card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LogsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Logs del sistema'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('ERROR'), findsOneWidget);
    expect(find.text('INFO'), findsOneWidget);

    // Verify log card rendered with data
    expect(find.byType(LogCard), findsOneWidget);
    expect(find.text('WARN'), findsNWidgets(2)); // chip and card badge
    expect(find.textContaining('401'), findsWidgets);
  });
}
