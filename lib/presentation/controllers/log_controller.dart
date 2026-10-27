import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';

enum LogStatus { initial, loading, success, error }

class LogController extends ChangeNotifier {
  LogController(this._repository);

  final LogRepository _repository;

  LogStatus status = LogStatus.initial;
  String? errorMessage;

  List<SystemLogModel> _allLogs = [];
  List<SystemLogModel> _filteredLogs = [];

  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  int _errorCount = 0;
  int _warningCount = 0;
  int _infoCount = 0;

  List<SystemLogModel> get logs => _filteredLogs;
  List<SystemLogModel> get allLogs => _allLogs;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  int get errorCount => _errorCount;
  int get warningCount => _warningCount;
  int get infoCount => _infoCount;

  int getCountForFilter(String filter) {
    switch (filter.toUpperCase()) {
      case 'ERROR':
        return _errorCount;
      case 'WARN':
      case 'WARNING':
        return _warningCount;
      case 'INFO':
      case 'INFORMATION':
        return _infoCount;
      default:
        return _allLogs.length;
    }
  }

  Future<void> fetchLogs({String? level, bool refresh = false}) async {
    if (!refresh && status == LogStatus.loading) return;

    status = LogStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getLogs(
        page: 1,
        limit: 100,
        level: level,
      );

      _allLogs = response.data;
      _calculateCounts();
      _applyFilters();

      status = LogStatus.success;
      notifyListeners();
    } on AppException catch (e) {
      errorMessage = e.message;
      status = LogStatus.error;
      notifyListeners();
    } catch (_) {
      errorMessage = 'Error inesperado al cargar los logs del sistema.';
      status = LogStatus.error;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _calculateCounts() {
    int errors = 0;
    int warnings = 0;
    int infos = 0;

    for (final log in _allLogs) {
      final lvl = (log.level ?? '').toUpperCase();
      if (lvl.contains('ERROR')) {
        errors++;
      } else if (lvl.contains('WARN')) {
        warnings++;
      } else if (lvl.contains('INFO')) {
        infos++;
      }
    }

    _errorCount = errors;
    _warningCount = warnings;
    _infoCount = infos;
  }

  void _applyFilters() {
    _filteredLogs = _allLogs.where((log) {
      // 1. Filtro por severidad
      if (_selectedFilter != 'ALL') {
        final lvl = (log.level ?? '').toUpperCase();
        if (_selectedFilter == 'ERROR' && !lvl.contains('ERROR')) {
          return false;
        }
        if (_selectedFilter == 'WARN' && !lvl.contains('WARN')) {
          return false;
        }
        if (_selectedFilter == 'INFO' && !lvl.contains('INFO')) {
          return false;
        }
      }

      // 2. Filtro por texto de búsqueda
      if (_searchQuery.isNotEmpty) {
        final idMatch = (log.id ?? '').toLowerCase().contains(_searchQuery);
        final traceMatch = (log.traceId ?? '').toLowerCase().contains(_searchQuery);
        final userMatch = (log.userId ?? '').toLowerCase().contains(_searchQuery);
        final ipMatch = (log.clientIp ?? '').toLowerCase().contains(_searchQuery);
        final methodMatch = (log.request?.method ?? '').toLowerCase().contains(_searchQuery);
        final pathMatch = (log.request?.path ?? '').toLowerCase().contains(_searchQuery);
        final msgMatch = log.displayMessage.toLowerCase().contains(_searchQuery);
        final excMatch = (log.exception?.message ?? '').toLowerCase().contains(_searchQuery);
        final codeMatch = (log.response?.statusCode?.toString() ?? '').contains(_searchQuery);

        return idMatch ||
            traceMatch ||
            userMatch ||
            ipMatch ||
            methodMatch ||
            pathMatch ||
            msgMatch ||
            excMatch ||
            codeMatch;
      }

      return true;
    }).toList();
  }
}
