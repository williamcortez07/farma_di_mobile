import 'package:flutter/material.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';
import 'package:farma_di_mobile/presentation/providers/log_provider.dart';
import 'package:farma_di_mobile/services/log_service.dart';

enum LogStatus { initial, loading, success, error }

/// Controlador de presentación para el módulo de Logs.
/// Coordina las interacciones de la interfaz de usuario con el provider
/// sin asumir responsabilidades de acceso a datos ni llamadas HTTP.
class LogController extends ChangeNotifier {
  LogController([dynamic source]) : _logProvider = _resolveProvider(source) {
    _logProvider.addListener(_onProviderUpdated);
  }

  static LogProvider _resolveProvider(dynamic source) {
    if (source is LogProvider) {
      return source;
    }
    if (source is LogRepository) {
      return LogProvider(logService: LogService(source));
    }
    if (source is LogService) {
      return LogProvider(logService: source);
    }
    if (getIt.isRegistered<LogProvider>()) {
      return getIt<LogProvider>();
    }
    if (getIt.isRegistered<LogService>()) {
      return LogProvider(logService: getIt<LogService>());
    }
    if (getIt.isRegistered<LogRepository>()) {
      return LogProvider(logService: LogService(getIt<LogRepository>()));
    }
    throw StateError('No se pudo resolver LogProvider para LogController');
  }

  final LogProvider _logProvider;

  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  ScrollController? _scrollController;

  // Getters de estado delegados al provider
  LogProvider get provider => _logProvider;
  LogCategory get selectedCategory => _logProvider.selectedCategory;
  bool get isLoading => _logProvider.isLoading;
  bool get isLoadingMore => _logProvider.isLoadingMore;
  String? get errorMessage => _logProvider.errorMessage;
  bool get hasMore => _logProvider.hasMore;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  LogStatus get status {
    switch (_logProvider.status) {
      case LogProviderStatus.initial:
        return LogStatus.initial;
      case LogProviderStatus.loading:
        return LogStatus.loading;
      case LogProviderStatus.success:
        return LogStatus.success;
      case LogProviderStatus.error:
        return LogStatus.error;
    }
  }

  /// Retorna los logs listados aplicando filtros locales y de búsqueda
  List<SystemLogModel> get visibleLogs {
    var list = _logProvider.logs;

    if (_selectedFilter != 'ALL') {
      list = list.where((log) {
        final lvl = log.normalizedLevel.toUpperCase();
        if (_selectedFilter == 'ERROR') return lvl.contains('ERROR');
        if (_selectedFilter == 'WARN' || _selectedFilter == 'WARNING') return lvl.contains('WARN');
        if (_selectedFilter == 'INFO' || _selectedFilter == 'INFORMATION') return lvl.contains('INFO');
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((log) {
        final idMatch = (log.id ?? '').toLowerCase().contains(q);
        final traceMatch = (log.traceId ?? '').toLowerCase().contains(q);
        final userMatch = (log.userId ?? '').toLowerCase().contains(q);
        final ipMatch = (log.clientIp ?? '').toLowerCase().contains(q);
        final methodMatch = (log.request?.method ?? '').toLowerCase().contains(q);
        final pathMatch = (log.request?.path ?? '').toLowerCase().contains(q);
        final msgMatch = log.displayMessage.toLowerCase().contains(q);
        final excMatch = (log.exception?.message ?? '').toLowerCase().contains(q);
        final codeMatch = (log.response?.statusCode?.toString() ?? '').contains(q);

        return idMatch ||
            traceMatch ||
            userMatch ||
            ipMatch ||
            methodMatch ||
            pathMatch ||
            msgMatch ||
            excMatch ||
            codeMatch;
      }).toList();
    }

    return list;
  }

  // Compatibilidad con vistas y tests existentes
  List<SystemLogModel> get logs => visibleLogs;
  List<SystemLogModel> get allLogs => _logProvider.logs;

  int get errorCount => _countByLevel('Error');
  int get warningCount => _countByLevel('Warning');
  int get infoCount => _countByLevel('Information');

  int _countByLevel(String level) {
    return _logProvider.logs.where((l) => l.normalizedLevel == level).length;
  }

  /// Inicializa la carga de logs (por defecto los del día actual)
  Future<void> init({LogCategory category = LogCategory.today}) {
    return _logProvider.fetchLogs(category: category);
  }

  /// Consulta de logs
  Future<void> fetchLogs({String? level, bool refresh = false}) {
    if (level != null && level.isNotEmpty && level.toUpperCase() != 'ALL') {
      _selectedFilter = level.toUpperCase();
      final category = LogCategory.fromString(level);
      return _logProvider.fetchLogs(category: category, refresh: refresh);
    }
    _selectedFilter = 'ALL';
    return _logProvider.fetchLogs(category: LogCategory.today, refresh: refresh);
  }

  /// Refresca la lista actual
  Future<void> refresh() {
    return _logProvider.fetchLogs(refresh: true);
  }

  /// Carga la siguiente página
  Future<void> loadMore() {
    return _logProvider.loadMore();
  }

  /// Selecciona una categoría e invoca la petición correspondiente
  void selectCategory(LogCategory category) {
    switch (category) {
      case LogCategory.today:
        _selectedFilter = 'ALL';
        break;
      case LogCategory.error:
        _selectedFilter = 'ERROR';
        break;
      case LogCategory.warning:
        _selectedFilter = 'WARN';
        break;
      case LogCategory.information:
        _selectedFilter = 'INFO';
        break;
    }
    _logProvider.setCategory(category);
    notifyListeners();
  }

  /// Compatibilidad para setFilter por string
  void setFilter(String filter) {
    _selectedFilter = filter.toUpperCase();
    final cat = LogCategory.fromString(filter);
    _logProvider.setCategory(cat);
    notifyListeners();
  }

  /// Actualiza el término de búsqueda
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  /// Limpia el campo de búsqueda
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Adjunta un ScrollController para disparar paginación infinita al llegar al final
  void attachScrollController(ScrollController controller) {
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller;
    _scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      _logProvider.loadMore();
    }
  }

  void _onProviderUpdated() {
    notifyListeners();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _logProvider.removeListener(_onProviderUpdated);
    super.dispose();
  }
}
