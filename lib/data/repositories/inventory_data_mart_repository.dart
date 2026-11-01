import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/inventory/expiring_batch_model.dart';
import '../models/inventory/inventory_availability_model.dart';
import '../models/inventory/inventory_data_mart_response.dart';
import '../models/inventory/product_turnover_model.dart';

/// Repositorio del DataMart de Inventario.
///
/// Misma arquitectura que [SalesDataMartRepository]: interfaz idéntica a la
/// de un repositorio conectado a una API REST. Para migrar al backend real
/// basta reemplazar [_loadRawJson] sin tocar ninguna otra capa.
abstract interface class IInventoryDataMartRepository {
  Future<InventoryDataMartResponse> getInventoryDataMart();
  Future<List<ProductTurnoverModel>> getProductTurnovers();
  Future<List<ExpiringBatchModel>> getExpiringBatches();
  Future<InventoryAvailabilityModel> getAvailability();
}

class InventoryDataMartRepository implements IInventoryDataMartRepository {
  static const String _kDataMartPath =
      'assets/data_marts/DataMartInventory.json';

  InventoryDataMartResponse? _cache;

  @override
  Future<InventoryDataMartResponse> getInventoryDataMart() async {
    _cache ??= await _loadAndParse();
    return _cache!;
  }

  @override
  Future<List<ProductTurnoverModel>> getProductTurnovers() async {
    final r = await getInventoryDataMart();
    return r.productTurnovers;
  }

  @override
  Future<List<ExpiringBatchModel>> getExpiringBatches() async {
    final r = await getInventoryDataMart();
    return r.expiringBatches;
  }

  @override
  Future<InventoryAvailabilityModel> getAvailability() async {
    final r = await getInventoryDataMart();
    return r.availability;
  }

  Future<InventoryDataMartResponse> _loadAndParse() async {
    try {
      final raw = await _loadRawJson(_kDataMartPath);
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return InventoryDataMartResponse.fromJson(json);
    } catch (e) {
      throw Exception(
        'InventoryDataMartRepository: error al cargar "$_kDataMartPath" – $e',
      );
    }
  }

  /// Punto de reemplazo para conectar con la API real:
  /// ```dart
  /// final res = await http.get(Uri.parse('$baseUrl/OperationalMetrics/inventory?daysToExpire=90'));
  /// return res.body;
  ///
  /// ```
  Future<String> _loadRawJson(String assetPath) =>
      rootBundle.loadString(assetPath);
}
