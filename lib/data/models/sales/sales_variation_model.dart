/// Modelo que representa la variación de ventas entre periodos.
///
/// Mapea el nodo [salesVariations] del DataMartSales.
/// El campo [variationPercentage] puede ser null para el primer periodo
class SalesVariationModel {
  final String period;
  final double currentSales;
  final double? previousSales;
  final double? variationPercentage;

  const SalesVariationModel({
    required this.period,
    required this.currentSales,
    this.previousSales,
    this.variationPercentage,
  });

  factory SalesVariationModel.fromJson(Map<String, dynamic> json) {
    return SalesVariationModel(
      period: json['period'] as String,
      currentSales: (json['currentSales'] as num).toDouble(),
      previousSales: json['previousSales'] != null
          ? (json['previousSales'] as num).toDouble()
          : null,
      variationPercentage: json['variationPercentage'] != null
          ? (json['variationPercentage'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'currentSales': currentSales,
    'previousSales': previousSales,
    'variationPercentage': variationPercentage,
  };
}
