import 'package:flutter/foundation.dart';

import '../../data/models/inventory/expiring_batch_model.dart';
import '../../data/models/inventory/inventory_availability_model.dart';
import '../../data/models/inventory/product_turnover_model.dart';
import '../../services/inventory_metrics_service.dart';

enum InventoryKpiStatus { idle, loading, success, error }

class InventoryMetricsController extends ChangeNotifier {
  InventoryMetricsController({InventoryMetricsService? service})
    : _service = service ?? InventoryMetricsService();

  final InventoryMetricsService _service;
  bool _isDisposed = false;

  InventoryKpiStatus _turnoverStatus = InventoryKpiStatus.idle;
  List<ProductTurnoverModel> _turnovers = [];
  String? _turnoverError;

  InventoryKpiStatus get turnoverStatus => _turnoverStatus;
  List<ProductTurnoverModel> get turnovers => List.unmodifiable(_turnovers);
  String? get turnoverError => _turnoverError;

  InventoryKpiStatus _expiringStatus = InventoryKpiStatus.idle;
  List<ExpiringBatchModel> _expiringBatches = [];
  double _overallExpiringPercentage = 0.0;
  String? _expiringError;

  InventoryKpiStatus get expiringStatus => _expiringStatus;
  List<ExpiringBatchModel> get expiringBatches =>
      List.unmodifiable(_expiringBatches);
  double get overallExpiringPercentage => _overallExpiringPercentage;
  String? get expiringError => _expiringError;

  InventoryKpiStatus _availabilityStatus = InventoryKpiStatus.idle;
  InventoryAvailabilityModel? _availability;
  String? _availabilityError;

  InventoryKpiStatus get availabilityStatus => _availabilityStatus;
  InventoryAvailabilityModel? get availability => _availability;
  String? get availabilityError => _availabilityError;

  bool get isLoading =>
      _turnoverStatus == InventoryKpiStatus.loading ||
      _expiringStatus == InventoryKpiStatus.loading ||
      _availabilityStatus == InventoryKpiStatus.loading;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await Future.wait([_loadTurnovers(), _loadExpiring(), _loadAvailability()]);
  }

  Future<void> _loadTurnovers() async {
    _turnoverStatus = InventoryKpiStatus.loading;
    _turnoverError = null;
    notifyListeners();
    try {
      _turnovers = await _service.fetchActiveTurnovers(topN: 10);
      _turnoverStatus = InventoryKpiStatus.success;
    } catch (e) {
      _turnoverError = e.toString();
      _turnoverStatus = InventoryKpiStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadExpiring() async {
    _expiringStatus = InventoryKpiStatus.loading;
    _expiringError = null;
    notifyListeners();
    try {
      final mart = await _service.fetchFullDataMart();
      _expiringBatches = await _service.fetchExpiringBatches();
      if (mart.overallExpiringPercentage > 0) {
        _overallExpiringPercentage = mart.overallExpiringPercentage;
      } else if (_expiringBatches.isNotEmpty && mart.totalInventoryItems > 0) {
        _overallExpiringPercentage =
            (_expiringBatches.length / mart.totalInventoryItems) * 100;
      } else {
        _overallExpiringPercentage = 0.0;
      }
      _expiringStatus = InventoryKpiStatus.success;
    } catch (e) {
      _expiringError = e.toString();
      _expiringStatus = InventoryKpiStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadAvailability() async {
    _availabilityStatus = InventoryKpiStatus.loading;
    _availabilityError = null;
    notifyListeners();
    try {
      _availability = await _service.fetchAvailability();
      _availabilityStatus = InventoryKpiStatus.success;
    } catch (e) {
      _availabilityError = e.toString();
      _availabilityStatus = InventoryKpiStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadAll();
}
