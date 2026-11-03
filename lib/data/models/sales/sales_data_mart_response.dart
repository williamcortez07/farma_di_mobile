import 'package:farma_di_mobile/data/models/sales/category_share_model.dart';
import 'package:farma_di_mobile/data/models/sales/gross_margin_model.dart';
import 'package:farma_di_mobile/data/models/sales/sales_variation_model.dart';

/// Respuesta agregada del DataMart de Ventas.
///
/// Contiene los tres conjuntos de datos que alimentan los KPIs de ventas:
/// - [salesVariations]  → KPI: Ventas por periodo (%)
/// - [grossMargins]     → KPI: Margen bruto de ventas (%)
/// - [categoryShares]   → KPI: Participación de ventas por categoría (%)
class SalesDataMartResponse {
  final List<SalesVariationModel> salesVariations;
  final List<GrossMarginModel> grossMargins;
  final List<CategoryShareModel> categoryShares;
  final double totalOverallRevenue;
  final int totalItemsSold;

  const SalesDataMartResponse({
    required this.salesVariations,
    required this.grossMargins,
    required this.categoryShares,
    required this.totalOverallRevenue,
    required this.totalItemsSold,
  });

  factory SalesDataMartResponse.fromJson(Map<String, dynamic> json) {
    return SalesDataMartResponse(
      salesVariations: (json['salesVariations'] as List<dynamic>)
          .map((e) => SalesVariationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      grossMargins: (json['grossMargins'] as List<dynamic>)
          .map((e) => GrossMarginModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryShares: (json['categoryShares'] as List<dynamic>)
          .map((e) => CategoryShareModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalOverallRevenue: (json['totalOverallRevenue'] as num).toDouble(),
      totalItemsSold: (json['totalItemsSold'] as num).toInt(),
    );
  }
}
