class StockModel {
  final int stockId;
  final int batchId;
  final String batchNumber;
  final int productId;
  final int availableQuantity;

  const StockModel({
    required this.stockId,
    required this.batchId,
    required this.batchNumber,
    required this.productId,
    required this.availableQuantity,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      stockId: (json['stockId'] as num?)?.toInt() ?? 0,
      batchId: (json['bachtId'] as num?)?.toInt() ?? 0,
      batchNumber: (json['batchNumber'] as String?) ?? '',
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      availableQuantity: (json['availableQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockId': stockId,
      'bachtId': batchId,
      'batchNumber': batchNumber,
      'productId': productId,
      'availableQuantity': availableQuantity,
    };
  }
}
