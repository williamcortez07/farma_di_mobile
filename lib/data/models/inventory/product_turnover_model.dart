/// Modelo de rotación de inventario por producto.
///
/// Mapea el nodo [productTurnovers] del DataMartInventory.
/// [turnoverRatio] = dispatchedQuantity / batchInitialQuantity.
/// Un ratio de 2 indica que el producto rotó el doble de su lote inicial.
class ProductTurnoverModel {
  final String productName;
  final int availableQuantity;
  final int batchInitialQuantity;
  final int dispatchedQuantity;
  final double turnoverRatio;

  const ProductTurnoverModel({
    required this.productName,
    required this.availableQuantity,
    required this.batchInitialQuantity,
    required this.dispatchedQuantity,
    required this.turnoverRatio,
  });

  factory ProductTurnoverModel.fromJson(Map<String, dynamic> json) {
    return ProductTurnoverModel(
      productName: json['productName'] as String,
      availableQuantity: (json['availableQuantity'] as num).toInt(),
      batchInitialQuantity: (json['batchInitialQuantity'] as num).toInt(),
      dispatchedQuantity: (json['dispatchedQuantity'] as num).toInt(),
      turnoverRatio: (json['turnoverRatio'] as num).toDouble(),
    );
  }
}
