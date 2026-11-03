import 'package:farma_di_mobile/data/models/brand_model.dart';
import 'package:farma_di_mobile/data/models/category_model.dart';
import 'package:farma_di_mobile/data/models/catalog_view_model.dart';
import 'package:farma_di_mobile/data/models/inventory_model.dart';
import 'package:farma_di_mobile/data/models/product_model.dart';
import 'package:farma_di_mobile/data/models/stock_model.dart';
import 'package:farma_di_mobile/data/repositories/catalog_repository.dart';

class CatalogService {
  CatalogService(this._repository);

  final CatalogRepository _repository;

  Future<List<CatalogProductViewModel>> loadCatalogProducts() async {
    final results = await Future.wait([
      _repository.getProducts(),
      _repository.getInventory().catchError((_) => <InventoryModel>[]),
      _repository.getStock().catchError((_) => <StockModel>[]),
    ]);

    final products = results[0] as List<ProductModel>;
    final inventories = results[1] as List<InventoryModel>;
    final stocks = results[2] as List<StockModel>;

    // Mapear inventario por productId
    final inventoryMap = <int, InventoryModel>{};
    for (final inv in inventories) {
      inventoryMap[inv.productId] = inv;
    }

    // Calcular stock total disponible por productId
    final stockMap = <int, int>{};
    for (final stock in stocks) {
      stockMap[stock.productId] =
          (stockMap[stock.productId] ?? 0) + stock.availableQuantity;
    }

    return products.map((product) {
      final inv = inventoryMap[product.productId];
      final totalQty = stockMap[product.productId] ?? 0;
      final criticalStock = inv?.criticalStock ?? 15;

      final stockStatus = _resolveStockStatus(totalQty, criticalStock);
      final barcodeLabel = product.concentrationValue.isNotEmpty
          ? '${product.presentationName} (${product.concentrationValue})'
          : (product.presentationName.isNotEmpty
              ? product.presentationName
              : 'Ref #${product.productId}');

      return CatalogProductViewModel(
        productId: product.productId,
        tradeName: product.tradeName.isNotEmpty
            ? product.tradeName
            : product.genericName,
        genericName: product.genericName,
        brandName: product.brandName.isNotEmpty
            ? product.brandName
            : 'Genérico',
        categoryName: product.categoryName.isNotEmpty
            ? product.categoryName
            : 'Sin categoría',
        presentationName: product.presentationName,
        barcode: barcodeLabel,
        unitPrice: inv?.salePrice ?? 0.0,
        totalQuantity: totalQty,
        stockStatus: stockStatus,
      );
    }).toList();
  }

  Future<List<CategoryModel>> loadCategories() => _repository.getCategories();

  Future<List<BrandModel>> loadBrands() => _repository.getBrands();

  String _resolveStockStatus(int totalQuantity, int criticalStock) {
    if (totalQuantity <= 0) return 'Agotado';
    if (totalQuantity <= criticalStock) return 'Stock bajo';
    return 'En stock';
  }
}
