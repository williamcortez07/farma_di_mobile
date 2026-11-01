import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_colors.dart';
import '../controllers/sales_metrics_controller.dart';
import '../widgets/metrics/sales_variation_chart.dart';
import '../widgets/metrics/gross_margin_chart.dart';
import '../widgets/metrics/category_share_chart.dart';

const double sectionSpacing = 16;

// no se estan mostrando datos mocs, ya que todos los datos que se renderizan aqui vienen de un data set que es un JSON que devilvió la api, que pasó, la api en local si se puedo conectar al cubo porque era un entorno local pero la api desplegada no tiene acceso a mi maquina local donde corre el cubo, por lo tanto se ejecuto el endpoit correspondiente a cada kpi se descargó el json y se pasó como un data set, para poder conectarse al endpoit solo se cambiaria en el repositorio

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  late final SalesMetricsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SalesMetricsController();
    // Dispara la carga de los 3 KPIs en paralelo al montar el widget.
    _controller.loadAll();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: _controller.refresh,
              color: AppColors.chartBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: sectionSpacing),
                    _buildFilters(),
                    const SizedBox(height: sectionSpacing),

                    //KPI 1: Ventas por periodo
                    _buildKpi1SalesVariation(),
                    const SizedBox(height: sectionSpacing),

                    // KPI 2: Margen bruto
                    _buildKpi2GrossMargin(),
                    const SizedBox(height: sectionSpacing),

                    // KPI 3: Participación por categoría
                    _buildKpi3CategoryShare(),
                    const SizedBox(height: sectionSpacing),
                    _buildSpendingSection(),
                    const SizedBox(height: sectionSpacing),
                    SupplierShareCard(suppliers: _suppliers),
                    const SizedBox(height: sectionSpacing),
                    _buildProfitabilitySection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpi1SalesVariation() {
    final status = _controller.variationsStatus;
    final data = _controller.salesVariations;

    // Badge dinámico: variación del último periodo con referencia.
    Widget? badge;
    if (status == SalesKpiStatus.success && data.length >= 2) {
      final last = data.last;
      if (last.variationPercentage != null) {
        final pct = last.variationPercentage!;
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
      child: _buildKpiBody(
        status: status,
        error: _controller.variationsError,
        onRetry: _controller.refresh,
        child: SalesVariationChart(data: data),
      ),
    );
  }

  Widget _buildKpi2GrossMargin() {
    final status = _controller.marginsStatus;
    final data = _controller.grossMargins;

    Widget? badge;
    if (status == SalesKpiStatus.success && data.isNotEmpty) {
      badge = const StatusBadge(
        text: '4.76 %',
        backgroundColor: AppColors.infoBackground,
        textColor: AppColors.chartBlue,
      );
    }

    return MetricsSectionCard(
      title: 'Margen bruto de ventas',
      subtitle: 'Por producto – ingresos vs. costo',
      trailing: badge,
      child: _buildKpiBody(
        status: status,
        error: _controller.marginsError,
        onRetry: _controller.refresh,
        child: GrossMarginChart(data: data),
      ),
    );
  }

  Widget _buildKpi3CategoryShare() {
    final status = _controller.sharesStatus;
    final data = _controller.categoryShares;

    Widget? badge;
    if (status == SalesKpiStatus.success && data.isNotEmpty) {
      badge = StatusBadge(
        text: 'Top ${data.length}',
        backgroundColor: AppColors.positiveBackground,
        textColor: AppColors.positiveGreen,
      );
    }

    return MetricsSectionCard(
      title: 'Participación por categoría',
      subtitle: 'Distribución de ingresos (% del total)',
      trailing: badge,
      child: _buildKpiBody(
        status: status,
        error: _controller.sharesError,
        onRetry: _controller.refresh,
        child: CategoryShareChart(data: data),
      ),
    );
  }

  Widget _buildKpiBody({
    required SalesKpiStatus status,
    required String? error,
    required VoidCallback onRetry,
    required Widget child,
  }) {
    switch (status) {
      case SalesKpiStatus.idle:
      case SalesKpiStatus.loading:
        return const _KpiSkeleton();
      case SalesKpiStatus.error:
        return _KpiError(
          message: error ?? 'Error desconocido',
          onRetry: onRetry,
        );
      case SalesKpiStatus.success:
        return child;
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Métricas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        if (_controller.isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.chartBlue,
            ),
          ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Últimos 3 periodos',
            isSelected: true,
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Categorías (Todas)', isSelected: false),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Ventas', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    IconData? icon,
  }) {
    final Color contentColor = isSelected
        ? Colors.white
        : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryDark : AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: contentColor),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(fontSize: 12, color: contentColor)),
        ],
      ),
    );
  }

  Widget _buildSpendingSection() {
    return const MetricsSectionCard(
      title: 'Gasto en compras',
      subtitle: 'Total semestral acumulado',
      trailing: Text(
        'C\$ 536k',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
      child: SpendingLineChart(),
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


class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.chartBlue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Cargando datos del data mart…',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiError extends StatelessWidget {
  const _KpiError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Reintentar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}


class SupplierShareCard extends StatelessWidget {
  final List<SupplierShare> suppliers;

  const SupplierShareCard({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    return MetricsSectionCard(
      title: 'Participación por proveedor',
      subtitle: 'Distribución de volumen',
      trailing: const Icon(
        Icons.pie_chart_outline,
        size: 18,
        color: AppColors.mutedText,
      ),
      child: Column(
        children: [
          _buildSegmentedBar(),
          const SizedBox(height: 14),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildSegmentedBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (final supplier in suppliers)
              Expanded(
                flex: (supplier.percentage * 10).round(),
                child: ColoredBox(color: supplier.color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suppliers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 26,
        crossAxisSpacing: 24,
      ),
      itemBuilder: (context, index) => _buildLegendItem(suppliers[index]),
    );
  }

  Widget _buildLegendItem(SupplierShare supplier) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: supplier.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            supplier.name,
            style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
          ),
        ),
        Text(
          '${supplier.percentage.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class MetricSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Widget badge;

  const MetricSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              badge,
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class MetricsSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const MetricsSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingWidget != null) trailingWidget,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class ProgressBarRow extends StatelessWidget {
  final String title;
  final String valueText;
  final double progress;
  final Color barColor;
  final String? footerStartText;
  final String? footerEndText;

  const ProgressBarRow({
    super.key,
    required this.title,
    required this.valueText,
    required this.progress,
    required this.barColor,
    this.footerStartText,
    this.footerEndText,
  });

  @override
  Widget build(BuildContext context) {
    final hasFooter = footerStartText != null || footerEndText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              valueText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: barColor,
            backgroundColor: AppColors.trackBackground,
          ),
        ),
        if (hasFooter) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                footerStartText ?? '',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.positiveGreen,
                ),
              ),
              Text(
                footerEndText ?? '',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class SpendingLineChart extends StatelessWidget {
  const SpendingLineChart({super.key});
  static const List<FlSpot> _spendingSpots = [
    FlSpot(0, 96),
    FlSpot(1, 82),
    FlSpot(2, 100),
    FlSpot(3, 116),
    FlSpot(4, 142),
  ];
  static const List<String> _monthLabels = [
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep (C\$142k)',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 4,
          minY: 60,
          maxY: 160,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: _buildSpacerAxis(),
            rightTitles: _buildSpacerAxis(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: _buildMonthLabel,
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _spendingSpots,
              isCurved: true,
              color: AppColors.chartBlue,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x333B8FD9), Color(0x003B8FD9)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AxisTitles _buildSpacerAxis() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        getTitlesWidget: (value, meta) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMonthLabel(double value, TitleMeta meta) {
    final int monthIndex = value.toInt();
    final bool isLastMonth = monthIndex == _monthLabels.length - 1;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _monthLabels[monthIndex],
        style: TextStyle(
          fontSize: 11,
          fontWeight: isLastMonth ? FontWeight.w700 : FontWeight.w400,
          color: isLastMonth ? AppColors.primaryDark : AppColors.mutedText,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SupplierShare {
  final String name;
  final double percentage;
  final Color color;

  const SupplierShare({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

class AppDecorations {
  const AppDecorations._();

  static const BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );
}
