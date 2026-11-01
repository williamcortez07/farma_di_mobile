import 'package:farma_di_mobile/data/models/inventory/expiring_batch_model.dart';
import 'package:farma_di_mobile/data/models/inventory/inventory_availability_model.dart';
import 'package:farma_di_mobile/data/models/inventory/product_turnover_model.dart';

/// Respuesta agregada del DataMart de Inventario.
///
/// Agrupa los tres conjuntos que alimentan los KPIs de inventario:
/// - [productTurnovers]       → KPI 1: Índice de rotación por producto
/// - [expiringBatches]        → KPI 2: Inventario próximo a vencer (%)
/// - [availability]           → Info adicional: disponibilidad de stock
class InventoryDataMartResponse {
  final List<ProductTurnoverModel> productTurnovers;
  final List<ExpiringBatchModel> expiringBatches;
  final InventoryAvailabilityModel availability;
  final double overallExpiringPercentage;
  final int totalInventoryItems;

  const InventoryDataMartResponse({
    required this.productTurnovers,
    required this.expiringBatches,
    required this.availability,
    required this.overallExpiringPercentage,
    required this.totalInventoryItems,
  });

  factory InventoryDataMartResponse.fromJson(Map<String, dynamic> json) {
    return InventoryDataMartResponse(
      productTurnovers: (json['productTurnovers'] as List<dynamic>)
          .map((e) => ProductTurnoverModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiringBatches: (json['expiringBatches'] as List<dynamic>)
          .map((e) => ExpiringBatchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      availability: InventoryAvailabilityModel.fromJson(
        json['availability'] as Map<String, dynamic>,
      ),
      overallExpiringPercentage: (json['overallExpiringPercentage'] as num)
          .toDouble(),
      totalInventoryItems: (json['totalInventoryItems'] as num).toInt(),
    );
  }
}
