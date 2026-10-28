import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/logout_button.dart';
import '../widgets/routes.dart';

import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MetricsApp());
}

class MetricsApp extends StatelessWidget {
  const MetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MetricsScreen(),
    );
  }
}

const double sectionSpacing = 16;

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});
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
  // por el momento solo tenemos 3 pero se podria implementar un top, ya sean 5 , o los mismos 3
  // una ida puede ser que sea personalizada si el usuario pide 3 devuelve 3, si quiere 5 devuelve 5
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: sectionSpacing),
              _buildFilters(),
              const SizedBox(height: sectionSpacing),
              _buildSummaryCards(),
              const SizedBox(height: sectionSpacing),
              _buildSpendingSection(),
              const SizedBox(height: sectionSpacing),
              const SupplierShareCard(suppliers: _suppliers),
              const SizedBox(height: sectionSpacing),
              _buildProfitabilitySection(),
              const SizedBox(height: sectionSpacing),
              _buildCategorySalesSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LUNES, 28 DE SEPTIEMBRE',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                color: AppColors.mutedText,
              ),
            ),
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
        LogoutButton(onPressed: () => _handleLogout(context)),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Últimos 6 meses',
            isSelected: true,
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Categorías (Todas)', isSelected: false),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Proveedor (Todos)', isSelected: false),
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

  Widget _buildSummaryCards() {
    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MetricSummaryCard(
                label: 'Part. proveedor',
                value: '32.5%',
                caption: 'Laboratorios Stein',
                badge: StatusBadge(
                  text: '+3.2%',
                  backgroundColor: AppColors.positiveBackground,
                  textColor: AppColors.positiveGreen,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricSummaryCard(
                label: 'Rotación stock',
                value: '4.7x',
                caption: 'Mediana semestral',
                badge: Icon(Icons.sync, size: 16, color: AppColors.chartBlue),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MetricSummaryCard(
                label: 'Gasto compras',
                value: 'C\$ 142k',
                caption: 'Alza moderada',
                badge: StatusBadge(
                  text: '+12.4%',
                  backgroundColor: AppColors.infoBackground,
                  textColor: AppColors.chartBlue,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MetricSummaryCard(
                label: 'Demanda',
                value: 'Alta',
                caption: 'Respiratorios',
                badge: StatusBadge(
                  text: 'Pico lluvias',
                  backgroundColor: AppColors.warningBackground,
                  textColor: AppColors.warningOrange,
                ),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildCategorySalesSection() {
    return const MetricsSectionCard(
      title: 'Ventas por categoría',
      subtitle: 'Ingresos brutos',
      trailing: Icon(Icons.bar_chart, size: 18, color: AppColors.mutedText),
      child: Column(
        children: [
          ProgressBarRow(
            title: 'Analgésicos',
            valueText: 'C\$ 145.2k (28%)',
            progress: 0.88,
            barColor: AppColors.primaryDark,
          ),
          SizedBox(height: 12),
          ProgressBarRow(
            title: 'Antibióticos',
            valueText: 'C\$ 112.4k (22%)',
            progress: 0.68,
            barColor: AppColors.chartBlue,
          ),
          SizedBox(height: 12),
          ProgressBarRow(
            title: 'Antigripales',
            valueText: 'C\$ 86.1k (17%)',
            progress: 0.52,
            barColor: AppColors.positiveGreen,
          ),
          SizedBox(height: 12),
          ProgressBarRow(
            title: 'Vitaminas',
            valueText: 'C\$ 62.3k (12%)',
            progress: 0.38,
            barColor: AppColors.neutralGray,
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
        // ClipRRect redondea las puntas de la barra,  porq x defecto es rectangular.
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
