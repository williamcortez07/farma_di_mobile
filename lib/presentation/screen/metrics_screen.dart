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
import '../widgets/metrics/sales_variation_chart.dart';
import '../widgets/metrics/status_badge.dart';
import '../widgets/metrics/stock_availability_panel.dart';

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
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Métricas',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        ListenableBuilder(
          listenable: Listenable.merge([_salesCtrl, _inventoryCtrl, _tabCtrl]),
          builder: (context, _) {
            if (!_isCurrentTabLoading) return const SizedBox.shrink();
            return const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.chartBlue,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor =
        isDark ? const Color(0xFF1E293B) : AppColors.trackBackground;
    final indicatorColor =
        isDark ? AppColors.chartBlue : AppColors.primaryDark;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: indicatorColor,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? const Color(0xFF94A3B8) : AppColors.mutedText,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ============================================================================
// Tab de Ventas (KPIs 1–3 de DataMartSales)
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
          color: AppColors.chartBlue,
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
    final avgMargin = c.grossMargins.isNotEmpty
        ? c.grossMargins
                .map((e) => e.grossMarginPercentage)
                .reduce((a, b) => a + b) /
            c.grossMargins.length
        : 0.0;

    return MetricsSectionCard(
      title: 'Margen bruto de ventas',
      subtitle: 'Por producto – ingresos vs. costo',
      trailing: c.marginsStatus == SalesKpiStatus.success &&
              c.grossMargins.isNotEmpty
          ? StatusBadge(
              text: '${avgMargin.toStringAsFixed(2)} %',
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
}

// ============================================================================
// Tab de Inventario (KPIs 4–5 + Disponibilidad de DataMartInventory)
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
          color: AppColors.chartBlue,
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
      subtitle: 'Índice por producto (top activos)',
      trailing:
          topProduct != null &&
              controller.turnoverStatus == InventoryKpiStatus.success
          ? StatusBadge(
              text: 'Top ${data.length}',
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
          overallExpiringPercentage: controller.overallExpiringPercentage,
        ),
      ),
    );
  }
}
