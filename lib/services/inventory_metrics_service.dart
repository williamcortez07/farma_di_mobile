import '../data/models/inventory/expiring_batch_model.dart';
import '../data/models/inventory/inventory_availability_model.dart';
import '../data/models/inventory/inventory_data_mart_response.dart';
import '../data/models/inventory/product_turnover_model.dart';
import '../data/repositories/inventory_data_mart_repository.dart';

class InventoryMetricsService {
  InventoryMetricsService({IInventoryDataMartRepository? repository})
    : _repository = repository ?? InventoryDataMartRepository();

  final IInventoryDataMartRepository _repository;

  //KPi 1 rotacion por productos

  /// Devuelve solo productos con actividad real (batchInitialQuantity > 0),
  /// ordenados de mayor a menor rotación. Excluye los que nunca tuvieron stock.
  Future<List<ProductTurnoverModel>> fetchActiveTurnovers({
    int topN = 10,
  }) async {
    final all = await _repository.getProductTurnovers();
    final active = all.where((p) => p.batchInitialQuantity > 0).toList()
      ..sort((a, b) => b.turnoverRatio.compareTo(a.turnoverRatio));
    return active.take(topN).toList();
  }

  // KPI 2 – Inventario próximo a vencer (%)

  Future<List<ExpiringBatchModel>> fetchExpiringBatches() async {
    final batches = await _repository.getExpiringBatches();
    batches.sort(
      (a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration),
    );
    return batches;
  }

  // Info adicional – Disponibilidad de stock

  Future<InventoryAvailabilityModel> fetchAvailability() =>
      _repository.getAvailability();

  Future<InventoryDataMartResponse> fetchFullDataMart() =>
      _repository.getInventoryDataMart();
}
