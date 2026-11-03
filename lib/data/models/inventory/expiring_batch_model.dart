/// Modelo de lote próximo a vencer.
///
/// Mapea el nodo [expiringBatches] del DataMartInventory.
class ExpiringBatchModel {
  final String batchNumber;
  final String productName;
  final DateTime expirationDate;
  final int daysUntilExpiration;
  final int availableQuantity;
  final int batchInitialQuantity;
  final double nearExpirationPercentage;
  final String status;

  const ExpiringBatchModel({
    required this.batchNumber,
    required this.productName,
    required this.expirationDate,
    required this.daysUntilExpiration,
    required this.availableQuantity,
    required this.batchInitialQuantity,
    required this.nearExpirationPercentage,
    required this.status,
  });

  factory ExpiringBatchModel.fromJson(Map<String, dynamic> json) {
    return ExpiringBatchModel(
      batchNumber: json['batchNumber'] as String,
      productName: json['productName'] as String,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      daysUntilExpiration: (json['daysUntilExpiration'] as num).toInt(),
      availableQuantity: (json['availableQuantity'] as num).toInt(),
      batchInitialQuantity: (json['batchInitialQuantity'] as num).toInt(),
      nearExpirationPercentage: (json['nearExpirationPercentage'] as num)
          .toDouble(),
      status: json['status'] as String,
    );
  }

  bool get isCritical => daysUntilExpiration <= 7;
}
