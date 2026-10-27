class CatalogProductViewModel {
  final int productId;
  final String tradeName;
  final String genericName;
  final String brandName;
  final String categoryName;
  final String presentationName;
  final String barcode;
  final double unitPrice;
  final int totalQuantity;
  final String stockStatus;

  const CatalogProductViewModel({
    required this.productId,
    required this.tradeName,
    required this.genericName,
    required this.brandName,
    required this.categoryName,
    required this.presentationName,
    required this.barcode,
    required this.unitPrice,
    required this.totalQuantity,
    required this.stockStatus,
  });
}
