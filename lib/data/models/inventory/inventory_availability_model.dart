/// Modelo de disponibilidad global del inventario.
///
/// Mapea el nodo [availability] del DataMartInventory.
class InventoryAvailabilityModel {
  final int totalProducts;
  final int inStockProducts;
  final int outOfStockProducts;
  final int criticalStockProducts;
  final double availabilityRatePercentage;

  const InventoryAvailabilityModel({
    required this.totalProducts,
    required this.inStockProducts,
    required this.outOfStockProducts,
    required this.criticalStockProducts,
    required this.availabilityRatePercentage,
  });

  factory InventoryAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return InventoryAvailabilityModel(
      totalProducts: (json['totalProducts'] as num).toInt(),
      inStockProducts: (json['inStockProducts'] as num).toInt(),
      outOfStockProducts: (json['outOfStockProducts'] as num).toInt(),
      criticalStockProducts: (json['criticalStockProducts'] as num).toInt(),
      availabilityRatePercentage: (json['availabilityRatePercentage'] as num)
          .toDouble(),
    );
  }
}
