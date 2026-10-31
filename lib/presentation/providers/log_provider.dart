import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/services/log_service.dart';

enum LogProviderStatus { initial, loading, success, error }

/// Provider responsable de gestionar el estado de los logs del sistema,
/// controlar las operaciones asíncronas y proveer los datos a la interfaz.
class LogProvider extends ChangeNotifier {
  LogProvider({required this.logService});

  final LogService logService;

  LogProviderStatus _status = LogProviderStatus.initial;
  LogCategory _selectedCategory = LogCategory.today;
  List<SystemLogModel> _logs = [];
  String? _errorMessage;

  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  /// Token de secuencia para evitar condiciones de carrera si el usuario
  /// cambia rápidamente de categoría antes de que termine una petición anterior.
  int _currentRequestId = 0;

  // Getters
  LogProviderStatus get status => _status;
  LogCategory get selectedCategory => _selectedCategory;
  List<SystemLogModel> get logs => List.unmodifiable(_logs);
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == LogProviderStatus.loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isEmpty => _status == LogProviderStatus.success && _logs.isEmpty;

  /// Consulta inicial o recarga de logs según la categoría seleccionada
  Future<void> fetchLogs({
    LogCategory? category,
    bool refresh = false,
  }) async {
    final targetCategory = category ?? _selectedCategory;

    // Si ya estamos cargando y no es refresco explícito, evitar duplicar
    if (!refresh && _status == LogProviderStatus.loading && targetCategory == _selectedCategory) {
      return;
    }

    _selectedCategory = targetCategory;
    _currentPage = 1;
    _hasMore = true;
    _status = LogProviderStatus.loading;
    _errorMessage = null;

    final requestId = ++_currentRequestId;
    notifyListeners();

    try {
      final response = await logService.fetchLogsByCategory(
        _selectedCategory,
        page: 1,
        limit: _pageSize,
      );

      // Si se emitió una petición posterior, descartar este resultado
      if (requestId != _currentRequestId) return;

      _logs = response.data;

      // Determinar si hay más páginas por consultar
      if (response.meta?.totalPages != null && response.meta?.currentPage != null) {
        _hasMore = response.meta!.currentPage! < response.meta!.totalPages!;
      } else {
        _hasMore = response.data.length >= _pageSize;
      }

      _status = LogProviderStatus.success;
      notifyListeners();
    } on AppException catch (e) {
      if (requestId != _currentRequestId) return;
      _errorMessage = e.message;
      _status = LogProviderStatus.error;
      notifyListeners();
    } catch (_) {
      if (requestId != _currentRequestId) return;
      _errorMessage = 'No se pudieron obtener los logs del servidor.';
      _status = LogProviderStatus.error;
      notifyListeners();
    }
  }

  /// Carga la siguiente página de resultados (paginación continua)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _status == LogProviderStatus.loading) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final requestId = _currentRequestId;

    try {
      final response = await logService.fetchLogsByCategory(
        _selectedCategory,
        page: nextPage,
        limit: _pageSize,
      );

      // Validar que seguimos en la misma consulta
      if (requestId != _currentRequestId) return;

      if (response.data.isEmpty) {
        _hasMore = false;
      } else {
        // Evitar duplicados por id si vienen repetidos
        final existingIds = _logs.map((e) => e.id).whereType<String>().toSet();
        final newItems = response.data.where(
          (item) => item.id == null || !existingIds.contains(item.id),
        );

        _logs.addAll(newItems);
        _currentPage = nextPage;

        if (response.meta?.totalPages != null) {
          _hasMore = nextPage < response.meta!.totalPages!;
        } else {
          _hasMore = response.data.length >= _pageSize;
        }
      }
    } catch (_) {
      // Si falla la paginación no borramos los datos actuales, simplemente detenemos la carga adicional
    } finally {
      if (requestId == _currentRequestId) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  /// Cambia la categoría y realiza inmediatamente la petición correspondiente
  void setCategory(LogCategory category) {
    if (_selectedCategory == category && _status == LogProviderStatus.success) {
      return;
    }
    fetchLogs(category: category);
  }

  /// Limpia los recursos si es necesario
  @override
  void dispose() {
    _logs = [];
    super.dispose();
  }
}
