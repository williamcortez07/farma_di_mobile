class ProductModel {
  final int productId;
  final String tradeName;
  final String genericName;
  final int categoryId;
  final String categoryName;
  final int presentationId;
  final String presentationName;
  final int concentrationId;
  final String porcentage;
  final String concentrationValue;
  final int supplierId;
  final String supplierName;
  final int brandId;
  final String brandName;
  final bool isActive;

  const ProductModel({
    required this.productId,
    required this.tradeName,
    required this.genericName,
    required this.categoryId,
    required this.categoryName,
    required this.presentationId,
    required this.presentationName,
    required this.concentrationId,
    required this.porcentage,
    required this.concentrationValue,
    required this.supplierId,
    required this.supplierName,
    required this.brandId,
    required this.brandName,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      tradeName: (json['tradeName'] as String?) ?? '',
      genericName: (json['genericName'] as String?) ?? '',
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: (json['categoryName'] as String?) ?? '',
      presentationId: (json['presentationId'] as num?)?.toInt() ?? 0,
      presentationName: (json['presentationName'] as String?) ?? '',
      concentrationId: (json['concentrationId'] as num?)?.toInt() ?? 0,
      porcentage: (json['porcentage'] as String?) ?? '',
      concentrationValue: (json['concentrationValue'] as String?) ?? '',
      supplierId: (json['supplierId'] as num?)?.toInt() ?? 0,
      supplierName: (json['supplierName'] as String?) ?? '',
      brandId: (json['brandId'] as num?)?.toInt() ?? 0,
      brandName: (json['brandName'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'tradeName': tradeName,
      'genericName': genericName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'presentationId': presentationId,
      'presentationName': presentationName,
      'concentrationId': concentrationId,
      'porcentage': porcentage,
      'concentrationValue': concentrationValue,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'brandId': brandId,
      'brandName': brandName,
      'isActive': isActive,
    };
  }
}
