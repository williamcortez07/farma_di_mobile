import 'package:flutter/foundation.dart';

import '../../data/models/sales/category_share_model.dart';
import '../../data/models/sales/gross_margin_model.dart';
import '../../data/models/sales/sales_variation_model.dart';
import '../../services/sales_metrics_service.dart';

/// Estado de carga genérico para los KPIs de ventas.
enum SalesKpiStatus { idle, loading, success, error }

/// Controller de métricas de ventas.
///
/// Extiende [ChangeNotifier] para integrarse con [ListenableBuilder] /
/// [AnimatedBuilder] en la capa de presentación sin necesidad de un gestor
/// de estado externo.  Cuando en el futuro se adopte Riverpod, BLoC u otro
/// paquete, solo hay que envolver o reemplazar este controller sin tocar los
/// widgets hoja.
class SalesMetricsController extends ChangeNotifier {
  SalesMetricsController({SalesMetricsService? service})
      : _service = service ?? SalesMetricsService();

  final SalesMetricsService _service;

  // ---------------------------------------------------------------------------
  // Estado – KPI 1: Ventas por periodo
  // ---------------------------------------------------------------------------
  SalesKpiStatus _variationsStatus = SalesKpiStatus.idle;
  List<SalesVariationModel> _salesVariations = [];
  String? _variationsError;

  SalesKpiStatus get variationsStatus => _variationsStatus;
  List<SalesVariationModel> get salesVariations =>
      List.unmodifiable(_salesVariations);
  String? get variationsError => _variationsError;

  // ---------------------------------------------------------------------------
  // Estado – KPI 2: Margen bruto
  // ---------------------------------------------------------------------------
  SalesKpiStatus _marginsStatus = SalesKpiStatus.idle;
  List<GrossMarginModel> _grossMargins = [];
  String? _marginsError;

  SalesKpiStatus get marginsStatus => _marginsStatus;
  List<GrossMarginModel> get grossMargins => List.unmodifiable(_grossMargins);
  String? get marginsError => _marginsError;

  // ---------------------------------------------------------------------------
  // Estado – KPI 3: Participación por categoría
  // ---------------------------------------------------------------------------
  SalesKpiStatus _sharesStatus = SalesKpiStatus.idle;
  List<CategoryShareModel> _categoryShares = [];
  String? _sharesError;

  SalesKpiStatus get sharesStatus => _sharesStatus;
  List<CategoryShareModel> get categoryShares =>
      List.unmodifiable(_categoryShares);
  String? get sharesError => _sharesError;

  // ---------------------------------------------------------------------------
  // Estado global
  // ---------------------------------------------------------------------------
  bool get isLoading =>
      _variationsStatus == SalesKpiStatus.loading ||
      _marginsStatus == SalesKpiStatus.loading ||
      _sharesStatus == SalesKpiStatus.loading;

  // ---------------------------------------------------------------------------
  // Carga de datos
  // ---------------------------------------------------------------------------

  /// Carga los 3 KPIs en paralelo.
  ///
  /// Diseñado para ser llamado en [initState] o en el primer build del
  /// widget de métricas.  Cada KPI falla de forma independiente para no
  /// bloquear los demás en caso de error parcial.
  Future<void> loadAll() async {
    await Future.wait([
      _loadVariations(),
      _loadMargins(),
      _loadShares(),
    ]);
  }

  Future<void> _loadVariations() async {
    _variationsStatus = SalesKpiStatus.loading;
    _variationsError = null;
    notifyListeners();

    try {
      _salesVariations = await _service.fetchSalesVariations();
      _variationsStatus = SalesKpiStatus.success;
    } catch (e) {
      _variationsError = e.toString();
      _variationsStatus = SalesKpiStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadMargins() async {
    _marginsStatus = SalesKpiStatus.loading;
    _marginsError = null;
    notifyListeners();

    try {
      _grossMargins = await _service.fetchGrossMargins(topN: 8);
      _marginsStatus = SalesKpiStatus.success;
    } catch (e) {
      _marginsError = e.toString();
      _marginsStatus = SalesKpiStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadShares() async {
    _sharesStatus = SalesKpiStatus.loading;
    _sharesError = null;
    notifyListeners();

    try {
      _categoryShares = await _service.fetchCategoryShares(topN: 8);
      _sharesStatus = SalesKpiStatus.success;
    } catch (e) {
      _sharesError = e.toString();
      _sharesStatus = SalesKpiStatus.error;
    }
    notifyListeners();
  }

  /// Refresca todos los KPIs (útil para pull-to-refresh).
  Future<void> refresh() => loadAll();
}
