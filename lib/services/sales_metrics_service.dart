import '../data/models/sales/category_share_model.dart';
import '../data/models/sales/gross_margin_model.dart';
import '../data/models/sales/sales_data_mart_response.dart';
import '../data/models/sales/sales_variation_model.dart';
import '../data/repositories/sales_data_mart_repository.dart';

class SalesMetricsService {
  SalesMetricsService({ISalesDataMartRepository? repository})
    : _repository = repository ?? SalesDataMartRepository();

  final ISalesDataMartRepository _repository;

  // primer KPi

  /// Devuelve las variaciones de ventas ordenadas cronológicamente.
  Future<List<SalesVariationModel>> fetchSalesVariations() async {
    final items = await _repository.getSalesVariations();
    // Orden cronológico ascendente
    items.sort((a, b) => a.period.compareTo(b.period));
    return items;
  }

  //kpi 2

  /// Devuelve los márgenes ordenados de mayor a menor rentabilidad.
  Future<List<GrossMarginModel>> fetchGrossMargins({int topN = 10}) async {
    final items = await _repository.getGrossMargins();
    items.sort((a, b) => b.grossMargin.compareTo(a.grossMargin));
    return items.take(topN).toList();
  }

  // kpi 3

  /// Devuelve la participación por categoría, mayor participación primero.
  Future<List<CategoryShareModel>> fetchCategoryShares({int topN = 8}) async {
    final items = await _repository.getCategoryShares();
    items.sort((a, b) => b.sharePercentage.compareTo(a.sharePercentage));
    return items.take(topN).toList();
  }

  Future<SalesDataMartResponse> fetchFullDataMart() =>
      _repository.getSalesDataMart();
}
