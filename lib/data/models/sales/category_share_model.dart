/// Modelo que representa la participación de ventas por categoría.
///
/// Mapea el nodo [categoryShares] del DataMartSales.
class CategoryShareModel {
  final String categoryName;
  final double totalRevenue;
  final int totalQuantity;
  final double sharePercentage;

  const CategoryShareModel({
    required this.categoryName,
    required this.totalRevenue,
    required this.totalQuantity,
    required this.sharePercentage,
  });

  factory CategoryShareModel.fromJson(Map<String, dynamic> json) {
    return CategoryShareModel(
      categoryName: json['categoryName'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      sharePercentage: (json['sharePercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryName': categoryName,
    'totalRevenue': totalRevenue,
    'totalQuantity': totalQuantity,
    'sharePercentage': sharePercentage,
  };
}
