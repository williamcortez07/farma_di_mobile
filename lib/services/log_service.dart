import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';

/// Categorías soportadas para la visualización y filtrado de logs
enum LogCategory {
  today('Hoy'),
  information('Information'),
  warning('Warning'),
  error('Error');

  final String label;
  const LogCategory(this.label);

  static LogCategory fromString(String value) {
    final upper = value.trim().toUpperCase();
    if (upper == 'ERROR') return LogCategory.error;
    if (upper == 'WARN' || upper == 'WARNING') return LogCategory.warning;
    if (upper == 'INFO' || upper == 'INFORMATION') return LogCategory.information;
    return LogCategory.today;
  }
}

/// Capa de servicios: responsable de la lógica de negocio y de coordinar
/// las operaciones relacionadas con los Logs del sistema.
class LogService {
  LogService(this._repository);

  final LogRepository _repository;

  /// Consulta los logs correspondientes a una categoría específica con paginación
  Future<PagedLogResponse> fetchLogsByCategory(
    LogCategory category, {
    int page = 1,
    int limit = 10,
  }) async {
    final validPage = page < 1 ? 1 : page;
    final validLimit = limit < 1 ? 10 : (limit > 100 ? 100 : limit);

    switch (category) {
      case LogCategory.today:
        return _repository.getTodayLogs(page: validPage, limit: validLimit);
      case LogCategory.information:
        return _repository.getLogsByLevel('Information', page: validPage, limit: validLimit);
      case LogCategory.warning:
        return _repository.getLogsByLevel('Warning', page: validPage, limit: validLimit);
      case LogCategory.error:
        return _repository.getLogsByLevel('Error', page: validPage, limit: validLimit);
    }
  }

  /// Consulta inicial de logs del día actual
  Future<PagedLogResponse> fetchTodayLogs({
    int page = 1,
    int limit = 10,
  }) =>
      fetchLogsByCategory(LogCategory.today, page: page, limit: limit);

  /// Consulta de logs por nivel específico (Information, Warning, Error)
  Future<PagedLogResponse> fetchLogsByLevel(
    String level, {
    int page = 1,
    int limit = 10,
  }) {
    final category = LogCategory.fromString(level);
    return fetchLogsByCategory(category, page: page, limit: limit);
  }

  /// Calcula el total de registros por severidad en una lista dada
  Map<String, int> computeCounts(List<SystemLogModel> logs) {
    int errors = 0;
    int warnings = 0;
    int infos = 0;

    for (final log in logs) {
      final lvl = log.normalizedLevel;
      if (lvl == 'Error') {
        errors++;
      } else if (lvl == 'Warning') {
        warnings++;
      } else {
        infos++;
      }
    }

    return {
      'total': logs.length,
      'Error': errors,
      'Warning': warnings,
      'Information': infos,
    };
  }
}
