import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farma_di_mobile/data/repositories/sales_data_mart_repository.dart';
import 'package:farma_di_mobile/data/repositories/inventory_data_mart_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/sales_metrics_controller.dart';
import 'package:farma_di_mobile/presentation/controllers/inventory_metrics_controller.dart';
import 'package:farma_di_mobile/presentation/screen/metrics_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataMart Repositories', () {
    test('SalesDataMartRepository loads and parses DataMartSales.json', () async {
      final repo = SalesDataMartRepository();
      final data = await repo.getSalesDataMart();

      expect(data.salesVariations, isNotEmpty);
      expect(data.grossMargins, isNotEmpty);
      expect(data.categoryShares, isNotEmpty);
      expect(data.totalOverallRevenue, greaterThan(0));
    });

    test('InventoryDataMartRepository loads and parses DataMartInventory.json', () async {
      final repo = InventoryDataMartRepository();
      final data = await repo.getInventoryDataMart();

      expect(data.productTurnovers, isNotEmpty);
      expect(data.expiringBatches, isNotEmpty);
      expect(data.availability.totalProducts, greaterThan(0));
      expect(data.availability.inStockProducts, greaterThan(0));
    });
  });

  group('Metrics Controllers', () {
    test('SalesMetricsController loads all sales KPIs successfully', () async {
      final controller = SalesMetricsController();
      await controller.loadAll();

      expect(controller.variationsStatus, SalesKpiStatus.success);
      expect(controller.marginsStatus, SalesKpiStatus.success);
      expect(controller.sharesStatus, SalesKpiStatus.success);
      expect(controller.salesVariations, isNotEmpty);
      expect(controller.grossMargins, isNotEmpty);
      expect(controller.categoryShares, isNotEmpty);
    });

    test('InventoryMetricsController loads all inventory KPIs successfully', () async {
      final controller = InventoryMetricsController();
      await controller.loadAll();

      expect(controller.turnoverStatus, InventoryKpiStatus.success);
      expect(controller.expiringStatus, InventoryKpiStatus.success);
      expect(controller.availabilityStatus, InventoryKpiStatus.success);
      expect(controller.turnovers, isNotEmpty);
      expect(controller.expiringBatches, isNotEmpty);
      expect(controller.availability, isNotNull);
    });
  });

  testWidgets('MetricsScreen renders both tabs without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MetricsScreen(),
      ),
    );

    // Initial render shows header and tabs
    expect(find.text('Métricas'), findsOneWidget);
    expect(find.text('Ventas'), findsOneWidget);
    expect(find.text('Inventario'), findsOneWidget);

    // Pump a few frames to resolve futures
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Verify Sales tab content
    expect(find.text('Ventas por periodo'), findsOneWidget);
    expect(find.text('Margen bruto de ventas'), findsOneWidget);
    expect(find.text('Participación por categoría'), findsOneWidget);

    // Switch to Inventario tab
    await tester.tap(find.text('Inventario'));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Verify Inventario tab content
    expect(find.text('Disponibilidad de stock'), findsOneWidget);
    expect(find.text('Rotación de inventario'), findsOneWidget);
    expect(find.text('Próximos a vencer'), findsOneWidget);
  });
}
