import 'package:flutter/material.dart';

import '../controllers/inventory_metrics_controller.dart';
import '../controllers/sales_metrics_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/metrics/category_share_chart.dart';
import '../widgets/metrics/expiring_batches_panel.dart';
import '../widgets/metrics/gross_margin_chart.dart';
import '../widgets/metrics/inventory_turnover_chart.dart';
import '../widgets/metrics/kpi_states.dart';
import '../widgets/metrics/metrics_section_card.dart';
import '../widgets/metrics/progress_bar_row.dart';
import '../widgets/metrics/sales_variation_chart.dart';
import '../widgets/metrics/spending_line_chart.dart';
import '../widgets/metrics/status_badge.dart';
import '../widgets/metrics/stock_availability_panel.dart';
import '../widgets/metrics/supplier_share_card.dart';

const double _kSpacing = 16.0;

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen>
    with SingleTickerProviderStateMixin {
  late final SalesMetricsController _salesCtrl;
  late final InventoryMetricsController _inventoryCtrl;
  late final TabController _tabCtrl;

  static const _tabs = ['Ventas', 'Inventario'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _salesCtrl = SalesMetricsController()..loadAll();
    _inventoryCtrl = InventoryMetricsController()..loadAll();

    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _salesCtrl.dispose();
    _inventoryCtrl.dispose();
    super.dispose();
  }

  bool get _isCurrentTabLoading =>
      _tabCtrl.index == 0 ? _salesCtrl.isLoading : _inventoryCtrl.isLoading;

  Future<void> _onRefresh() =>
      _tabCtrl.index == 0 ? _salesCtrl.refresh() : _inventoryCtrl.refresh();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 12),
            // ── Tab Bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabBar(),
            ),
            const SizedBox(height: _kSpacing),
            // ── Contenido de pestañas ────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _SalesTab(controller: _salesCtrl, onRefresh: _onRefresh),
                  _InventoryTab(
                    controller: _inventoryCtrl,
                    onRefresh: _onRefresh,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Métricas',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        if (_isCurrentTabLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colors.onPrimary,
        unselectedLabelColor: colors.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ============================================================================
// Tab de Ventas (KPIs 1–3 + Secciones analíticas)
// ============================================================================

class _SalesTab extends StatelessWidget {
  const _SalesTab({required this.controller, required this.onRefresh});

  final SalesMetricsController controller;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          color: Theme.of(context).colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI 1 – Ventas por periodo
                _kpiSalesVariation(controller),
                const SizedBox(height: _kSpacing),
                // KPI 2 – Margen bruto
                _kpiGrossMargin(controller),
                const SizedBox(height: _kSpacing),
                // KPI 3 – Participación por categoría
                _kpiCategoryShare(controller),
                const SizedBox(height: _kSpacing),
                // Gasto en compras
                _buildSpendingSection(context),
                const SizedBox(height: _kSpacing),
                // Proveedores
                const SupplierShareCard(suppliers: _suppliers),
                const SizedBox(height: _kSpacing),
                // Rentabilidad de productos
                _buildProfitabilitySection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kpiSalesVariation(SalesMetricsController c) {
    final data = c.salesVariations;

    Widget? badge;
    if (c.variationsStatus == SalesKpiStatus.success && data.length >= 2) {
      final pct = data.last.variationPercentage;
      if (pct != null) {
        badge = StatusBadge(
          text: '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%',
          backgroundColor: pct >= 0
              ? AppColors.positiveBackground
              : const Color(0xFFFFE0E0),
          textColor: pct >= 0 ? AppColors.positiveGreen : Colors.redAccent,
        );
      }
    }

    return MetricsSectionCard(
      title: 'Ventas por periodo',
      subtitle: 'Variación % respecto al periodo anterior',
      trailing: badge,
      child: buildKpiBody(
        status: c.variationsStatus,
        error: c.variationsError,
        onRetry: c.refresh,
        child: SalesVariationChart(data: data),
      ),
    );
  }

  Widget _kpiGrossMargin(SalesMetricsController c) {
    return MetricsSectionCard(
      title: 'Margen bruto de ventas',
      subtitle: 'Por producto – ingresos vs. costo',
      trailing: c.marginsStatus == SalesKpiStatus.success
          ? const StatusBadge(
              text: '4.76 %',
              backgroundColor: AppColors.infoBackground,
              textColor: AppColors.chartBlue,
            )
          : null,
      child: buildKpiBody(
        status: c.marginsStatus,
        error: c.marginsError,
        onRetry: c.refresh,
        child: GrossMarginChart(data: c.grossMargins),
      ),
    );
  }

  Widget _kpiCategoryShare(SalesMetricsController c) {
    final data = c.categoryShares;
    return MetricsSectionCard(
      title: 'Participación por categoría',
      subtitle: 'Distribución de ingresos (% del total)',
      trailing: c.sharesStatus == SalesKpiStatus.success
          ? StatusBadge(
              text: 'Top ${data.length}',
              backgroundColor: AppColors.positiveBackground,
              textColor: AppColors.positiveGreen,
            )
          : null,
      child: buildKpiBody(
        status: c.sharesStatus,
        error: c.sharesError,
        onRetry: c.refresh,
        child: CategoryShareChart(data: data),
      ),
    );
  }

  Widget _buildSpendingSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MetricsSectionCard(
      title: 'Gasto en compras',
      subtitle: 'Total semestral acumulado',
      trailing: Text(
        'C\$ 536k',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
      ),
      child: const SpendingLineChart(),
    );
  }

  Widget _buildProfitabilitySection() {
    return const MetricsSectionCard(
      title: 'Rentabilidad de productos',
      subtitle: 'Margen real de contribución',
      trailing: StatusBadge(
        text: 'Top 3',
        backgroundColor: AppColors.positiveBackground,
        textColor: AppColors.positiveGreen,
      ),
      child: Column(
        children: [
          ProgressBarRow(
            title: 'Panadol Forte 500mg',
            valueText: 'C\$ 35,420',
            progress: 0.85,
            barColor: AppColors.positiveGreen,
            footerStartText: 'Margen: 41.7%',
            footerEndText: '850 unidades',
          ),
          SizedBox(height: 14),
          ProgressBarRow(
            title: 'Ciprofloxacino 500mg',
            valueText: 'C\$ 27,300',
            progress: 0.65,
            barColor: AppColors.chartBlue,
            footerStartText: 'Margen: 48.2%',
            footerEndText: '420 unidades',
          ),
          SizedBox(height: 14),
          ProgressBarRow(
            title: 'Tenormin 50mg',
            valueText: 'C\$ 21,800',
            progress: 0.52,
            barColor: AppColors.chartBlue,
            footerStartText: 'Margen: 39.5%',
            footerEndText: '310 unidades',
          ),
        ],
      ),
    );
  }

  static const List<SupplierShare> _suppliers = [
    SupplierShare(
      name: 'Stein',
      percentage: 32.5,
      color: AppColors.primaryDark,
    ),
    SupplierShare(name: 'Ramos', percentage: 24.4, color: AppColors.chartBlue),
    SupplierShare(
      name: 'Calox',
      percentage: 18.3,
      color: AppColors.positiveGreen,
    ),
    SupplierShare(
      name: 'Otros',
      percentage: 24.8,
      color: AppColors.neutralGray,
    ),
  ];
}

// ============================================================================
// Tab de Inventario (KPIs 4–5 + Disponibilidad)
// ============================================================================

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.controller, required this.onRefresh});

  final InventoryMetricsController controller;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          color: Theme.of(context).colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disponibilidad
                _kpiAvailability(),
                const SizedBox(height: _kSpacing),
                // KPI 4 – Rotación
                _kpiTurnover(),
                const SizedBox(height: _kSpacing),
                // KPI 5 – Próximos a vencer
                _kpiExpiring(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kpiAvailability() {
    final avail = controller.availability;
    return MetricsSectionCard(
      title: 'Disponibilidad de stock',
      subtitle: 'Estado actual del inventario activo',
      trailing:
          controller.availabilityStatus == InventoryKpiStatus.success &&
              avail != null
          ? StatusBadge(
              text: '${avail.availabilityRatePercentage.toStringAsFixed(0)}%',
              backgroundColor: avail.availabilityRatePercentage >= 90
                  ? AppColors.positiveBackground
                  : AppColors.warningBackground,
              textColor: avail.availabilityRatePercentage >= 90
                  ? AppColors.positiveGreen
                  : AppColors.warningOrange,
            )
          : null,
      child: buildKpiBody(
        status: controller.availabilityStatus,
        error: controller.availabilityError,
        onRetry: controller.refresh,
        child: avail != null
            ? StockAvailabilityPanel(data: avail)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _kpiTurnover() {
    final data = controller.turnovers;
    final topProduct = data.isNotEmpty ? data.first : null;

    return MetricsSectionCard(
      title: 'Rotación de inventario',
      subtitle: 'Índice por producto (top 10 activos)',
      trailing:
          topProduct != null &&
              controller.turnoverStatus == InventoryKpiStatus.success
          ? const StatusBadge(
              text: 'Top 10',
              backgroundColor: AppColors.infoBackground,
              textColor: AppColors.chartBlue,
            )
          : null,
      child: buildKpiBody(
        status: controller.turnoverStatus,
        error: controller.turnoverError,
        onRetry: controller.refresh,
        child: InventoryTurnoverChart(data: data),
      ),
    );
  }

  Widget _kpiExpiring() {
    final batches = controller.expiringBatches;
    final hasCritical = batches.any((b) => b.isCritical);

    return MetricsSectionCard(
      title: 'Próximos a vencer',
      subtitle: 'Lotes con fecha límite próxima',
      trailing: controller.expiringStatus == InventoryKpiStatus.success
          ? StatusBadge(
              text: hasCritical ? '⚠ Urgente' : 'Sin alertas',
              backgroundColor: hasCritical
                  ? AppColors.warningBackground
                  : AppColors.positiveBackground,
              textColor: hasCritical
                  ? AppColors.warningOrange
                  : AppColors.positiveGreen,
            )
          : null,
      child: buildKpiBody(
        status: controller.expiringStatus,
        error: controller.expiringError,
        onRetry: controller.refresh,
        child: ExpiringBatchesPanel(
          batches: batches,
          overallExpiringPercentage: 0,
        ),
      ),
    );
  }
}
