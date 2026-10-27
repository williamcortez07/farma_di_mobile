import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';

class LogRepository {
  LogRepository(this._api);

  final ApiClient _api;

  /// Obtiene los logs registrados con paginación y filtros opcionales.
  Future<PagedLogResponse> getLogs({
    int page = 1,
    int limit = 20,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (level != null && level.isNotEmpty && level.toUpperCase() != 'ALL') {
      query['level'] = _normalizeLevel(level);
    }

    if (startDate != null) {
      query['startDate'] = startDate.toIso8601String();
    }

    if (endDate != null) {
      query['endDate'] = endDate.toIso8601String();
    }

    final response = await _api.get(ApiConstants.logs, query: query);
    return _parsePagedResponse(response);
  }

  /// Obtiene logs filtrados por severidad (Information, Warning, Error).
  Future<PagedLogResponse> getLogsByLevel(
    String level, {
    int page = 1,
    int limit = 20,
  }) async {
    final normalized = _normalizeLevel(level);
    final response = await _api.get(
      ApiConstants.logsByLevel(normalized),
      query: {'page': page.toString(), 'limit': limit.toString()},
    );
    return _parsePagedResponse(response);
  }

  /// Obtiene exclusivamente los logs de información.
  Future<PagedLogResponse> getInformationLogs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiConstants.logsInformation,
      query: {'page': page.toString(), 'limit': limit.toString()},
    );
    return _parsePagedResponse(response);
  }

  /// Obtiene exclusivamente los logs de advertencia.
  Future<PagedLogResponse> getWarningLogs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiConstants.logsWarning,
      query: {'page': page.toString(), 'limit': limit.toString()},
    );
    return _parsePagedResponse(response);
  }

  /// Obtiene exclusivamente los logs de error.
  Future<PagedLogResponse> getErrorLogs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiConstants.logsError,
      query: {'page': page.toString(), 'limit': limit.toString()},
    );
    return _parsePagedResponse(response);
  }

  /// Obtiene los logs registrados en el día en curso (UTC).
  Future<PagedLogResponse> getTodayLogs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiConstants.logsToday,
      query: {'page': page.toString(), 'limit': limit.toString()},
    );
    return _parsePagedResponse(response);
  }

  /// Obtiene los logs registrados dentro de un rango de fechas.
  Future<PagedLogResponse> getDateRangeLogs(
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiConstants.logsDateRange,
      query: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return _parsePagedResponse(response);
  }

  PagedLogResponse _parsePagedResponse(dynamic response) {
    if (response is! Map<String, dynamic>) {
      throw const ParsingException();
    }
    return PagedLogResponse.fromJson(response);
  }

  String _normalizeLevel(String level) {
    final upper = level.trim().toUpperCase();
    switch (upper) {
      case 'ERROR':
        return 'Error';
      case 'WARN':
      case 'WARNING':
        return 'Warning';
      case 'INFO':
      case 'INFORMATION':
        return 'Information';
      default:
        return level;
    }
  }
}
