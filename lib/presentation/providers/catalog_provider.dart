import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/brand_model.dart';
import 'package:farma_di_mobile/data/models/category_model.dart';
import 'package:farma_di_mobile/data/models/catalog_view_model.dart';
import 'package:farma_di_mobile/services/catalog_service.dart';

enum CatalogStatus { initial, loading, success, error }

/// Provider de estado para la pantalla de Catálogos (siguiendo la arquitectura limpia).
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._service);

  final CatalogService _service;

  // Estado de Productos
  CatalogStatus productsStatus = CatalogStatus.initial;
  List<CatalogProductViewModel> products = [];
  String? productsError;

  // Estado de Categorías
  CatalogStatus categoriesStatus = CatalogStatus.initial;
  List<CategoryModel> categories = [];
  String? categoriesError;

  // Estado de Marcas
  CatalogStatus brandsStatus = CatalogStatus.initial;
  List<BrandModel> brands = [];
  String? brandsError;

  // Filtros de Productos
  String searchText = '';
  String selectedStockFilter = 'Todos';

  void setSearchText(String text) {
    searchText = text;
    notifyListeners();
  }

  void setSelectedStockFilter(String filter) {
    selectedStockFilter = filter;
    notifyListeners();
  }

  List<CatalogProductViewModel> get filteredProducts {
    return products.where((p) {
      final query = searchText.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          p.tradeName.toLowerCase().contains(query) ||
          p.genericName.toLowerCase().contains(query) ||
          p.brandName.toLowerCase().contains(query) ||
          p.categoryName.toLowerCase().contains(query);

      final matchesFilter = selectedStockFilter == 'Todos' ||
          p.stockStatus == selectedStockFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get inStockCount =>
      products.where((p) => p.stockStatus == 'En stock').length;
  int get lowStockCount =>
      products.where((p) => p.stockStatus == 'Stock bajo').length;
  int get outOfStockCount =>
      products.where((p) => p.stockStatus == 'Agotado').length;

  int getProductCountByCategory(String categoryName) {
    return products
        .where((p) =>
            p.categoryName.trim().toLowerCase() ==
            categoryName.trim().toLowerCase())
        .length;
  }

  Future<void> fetchProducts() async {
    productsStatus = CatalogStatus.loading;
    productsError = null;
    notifyListeners();

    try {
      products = await _service.loadCatalogProducts();
      productsStatus = CatalogStatus.success;
    } on AppException catch (e) {
      productsError = e.message;
      productsStatus = CatalogStatus.error;
    } catch (e) {
      productsError = 'No se pudieron cargar los productos: $e';
      productsStatus = CatalogStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    categoriesStatus = CatalogStatus.loading;
    categoriesError = null;
    notifyListeners();

    try {
      categories = await _service.loadCategories();
      categoriesStatus = CatalogStatus.success;
    } on AppException catch (e) {
      categoriesError = e.message;
      categoriesStatus = CatalogStatus.error;
    } catch (e) {
      categoriesError = 'No se pudieron cargar las categorías: $e';
      categoriesStatus = CatalogStatus.error;
    }
    notifyListeners();
  }

  Future<void> fetchBrands() async {
    brandsStatus = CatalogStatus.loading;
    brandsError = null;
    notifyListeners();

    try {
      brands = await _service.loadBrands();
      brandsStatus = CatalogStatus.success;
    } on AppException catch (e) {
      brandsError = e.message;
      brandsStatus = CatalogStatus.error;
    } catch (e) {
      brandsError = 'No se pudieron cargar las marcas: $e';
      brandsStatus = CatalogStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchProducts(),
      fetchCategories(),
      fetchBrands(),
    ]);
  }
}
