import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/brand_model.dart';
import 'package:farma_di_mobile/data/models/category_model.dart';
import 'package:farma_di_mobile/data/models/inventory_model.dart';
import 'package:farma_di_mobile/data/models/product_model.dart';
import 'package:farma_di_mobile/data/models/stock_model.dart';

class CatalogRepository {
  CatalogRepository(this._api);

  final ApiClient _api;

  List<T> _extractList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json == null) return [];
    if (json is List) {
      return json
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    }
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
    }
    return [];
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final json = await _api.get(ApiConstants.products);
      return _extractList(json, ProductModel.fromJson);
    } on TypeError {
      throw const ParsingException('Error al procesar la lista de productos.');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final json = await _api.get(ApiConstants.categories);
      return _extractList(json, CategoryModel.fromJson);
    } on TypeError {
      throw const ParsingException('Error al procesar la lista de categorías.');
    }
  }

  Future<List<BrandModel>> getBrands() async {
    try {
      final json = await _api.get(ApiConstants.brands);
      return _extractList(json, BrandModel.fromJson);
    } on TypeError {
      throw const ParsingException('Error al procesar la lista de marcas.');
    }
  }

  Future<List<InventoryModel>> getInventory() async {
    try {
      final json = await _api.get(ApiConstants.inventory);
      return _extractList(json, InventoryModel.fromJson);
    } on TypeError {
      throw const ParsingException('Error al procesar el inventario.');
    }
  }

  Future<List<StockModel>> getStock() async {
    try {
      final json = await _api.get(ApiConstants.stock);
      return _extractList(json, StockModel.fromJson);
    } on TypeError {
      throw const ParsingException('Error al procesar el stock.');
    }
  }
}
