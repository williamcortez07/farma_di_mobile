import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/sales/category_share_model.dart';
import '../models/sales/gross_margin_model.dart';
import '../models/sales/sales_data_mart_response.dart';
import '../models/sales/sales_variation_model.dart';

/// Repositorio del DataMart de Ventas.
///
/// Abstrae el origen de los datos detrás de una interfaz idéntica a la que
/// tendría un repositorio conectado a una API REST, de modo que en el futuro
/// basta sustituir la implementación [_loadRawJson] sin tocar el resto de la
/// arquitectura. se decidió hacerlo con un data set procedente de un endpoit real y funcional que toma datos de un cubo multidimencional. por motivos de que no se pudo desplegar el cubo se deció hacerlo con un data set con los mismos datos que devuelve el endpoit
///
/// El JSON se carga desde [_kDataMartPath] (asset incluido en pubspec.yaml).
abstract interface class ISalesDataMartRepository {
  /// Obtiene la respuesta completa del data mart de ventas.
  Future<SalesDataMartResponse> getSalesDataMart();

  /// KPI 1 – Variación de ventas por periodo (%).
  Future<List<SalesVariationModel>> getSalesVariations();

  /// KPI 2 – Margen bruto por producto (%).
  Future<List<GrossMarginModel>> getGrossMargins();

  /// KPI 3 – Participación de ventas por categoría (%).
  Future<List<CategoryShareModel>> getCategoryShares();
}

class SalesDataMartRepository implements ISalesDataMartRepository {
  /// Ruta del asset que contiene el DataMart de Ventas.
  static const String _kDataMartPath = 'assets/data_marts/DataMartSales.json';

  // Cache en memoria para no releer el asset en cada consulta.
  SalesDataMartResponse? _cache;

  // Métodos públicos

  @override
  Future<SalesDataMartResponse> getSalesDataMart() async {
    _cache ??= await _loadAndParse();
    return _cache!;
  }

  @override
  Future<List<SalesVariationModel>> getSalesVariations() async {
    final response = await getSalesDataMart();
    return response.salesVariations;
  }

  @override
  Future<List<GrossMarginModel>> getGrossMargins() async {
    final response = await getSalesDataMart();
    return response.grossMargins;
  }

  @override
  Future<List<CategoryShareModel>> getCategoryShares() async {
    final response = await getSalesDataMart();
    return response.categoryShares;
  }

  // Implementación interna
  //Carga el JSON desde los assets de Flutter y lo deserializa.

  //Simula el contrato de una petición HTTP: lanza una [Exception] si el
  // asset no existe o el JSON está malformado, igual que lo haría un error
  // de red o un 5xx del servidor.
  Future<SalesDataMartResponse> _loadAndParse() async {
    try {
      final raw = await _loadRawJson(_kDataMartPath);
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return SalesDataMartResponse.fromJson(json);
    } catch (e) {
      throw Exception(
        'SalesDataMartRepository: error al cargar "$_kDataMartPath" – $e',
      );
    }
  }

  // Punto de reemplazo para la fuente de datos.
  //
  /// Hoy devuelve el contenido del asset; mañana puede hacer una llamada HTTP:
  /// ```dart
  /// final response = await http.get(Uri.parse('$baseUrl/data-marts/sales'));
  /// return response.body;
  /// ```
  Future<String> _loadRawJson(String assetPath) async {
    return rootBundle.loadString(assetPath);
  }
}
