class BrandModel {
  final int brandId;
  final String brandName;
  final String brandDescription;
  final bool isActive;

  const BrandModel({
    required this.brandId,
    required this.brandName,
    required this.brandDescription,
    required this.isActive,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      brandId: (json['brandId'] as num?)?.toInt() ?? 0,
      brandName: (json['brandName'] as String?) ?? '',
      brandDescription: (json['brandDescription'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandId': brandId,
      'brandName': brandName,
      'brandDescription': brandDescription,
      'isActive': isActive,
    };
  }
}
