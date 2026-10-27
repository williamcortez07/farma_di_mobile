class InventoryModel {
  final int inventoryId;
  final int productId;
  final String productGenericName;
  final double salePrice;
  final double purchasePrice;
  final int criticalStock;

  const InventoryModel({
    required this.inventoryId,
    required this.productId,
    required this.productGenericName,
    required this.salePrice,
    required this.purchasePrice,
    required this.criticalStock,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: (json['inventoryId'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productGenericName: (json['productGenericname'] as String?) ?? '',
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      criticalStock: (json['criticalStock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryId,
      'productId': productId,
      'productGenericname': productGenericName,
      'salePrice': salePrice,
      'purchasePrice': purchasePrice,
      'criticalStock': criticalStock,
    };
  }
}
