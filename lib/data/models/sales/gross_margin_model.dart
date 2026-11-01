/// Modelo que representa el margen bruto de ventas por producto.
///
/// Mapea el nodo [grossMargins] del DataMartSales.
class GrossMarginModel {
  final String productName;
  final double totalRevenue;
  final double totalCost;
  final double grossMargin;
  final double grossMarginPercentage;

  const GrossMarginModel({
    required this.productName,
    required this.totalRevenue,
    required this.totalCost,
    required this.grossMargin,
    required this.grossMarginPercentage,
  });

  factory GrossMarginModel.fromJson(Map<String, dynamic> json) {
    return GrossMarginModel(
      productName: json['productName'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      grossMargin: (json['grossMargin'] as num).toDouble(),
      grossMarginPercentage: (json['grossMarginPercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'totalRevenue': totalRevenue,
    'totalCost': totalCost,
    'grossMargin': grossMargin,
    'grossMarginPercentage': grossMarginPercentage,
  };
}
