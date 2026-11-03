import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/sales/sales_variation_model.dart';
import '../../theme/app_colors.dart';

/// KPI 1 – Ventas por periodo (%).
///
/// Muestra un [BarChart] con el monto de ventas por periodo y una etiqueta
/// de variación porcentual sobre cada barra (excepto el primer periodo que
/// no tiene referencia anterior).
class SalesVariationChart extends StatelessWidget {
  const SalesVariationChart({super.key, required this.data});

  final List<SalesVariationModel> data;

  static final _currencyFmt = NumberFormat.compactCurrency(
    locale: 'es_NI',
    symbol: 'C\$',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _EmptyState();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gridLineColor = theme.dividerColor.withValues(alpha: isDark ? 0.35 : 0.6);
    final tooltipBg = isDark ? const Color(0xFF334155) : AppColors.primaryDark;

    // Rango del eje Y con un 20% de margen superior para las etiquetas.
    final maxY =
        data.map((e) => e.currentSales).reduce((a, b) => a > b ? a : b) * 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leyenda de variación porcentual
        _buildVariationLegend(),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: gridLineColor, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => tooltipBg,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = data[group.x];
                    return BarTooltipItem(
                      '${item.period}\n${_currencyFmt.format(item.currentSales)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final item = data[index];
                      if (item.variationPercentage == null) {
                        return const SizedBox.shrink();
                      }
                      final pct = item.variationPercentage!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: pct >= 0
                                ? AppColors.positiveGreen
                                : Colors.redAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[index].period,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(data.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data[i].currentSales,
                      color: AppColors.chartBlue,
                      width: 36,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVariationLegend() {
    final withVariation = data
        .where((e) => e.variationPercentage != null)
        .toList();
    if (withVariation.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: withVariation.map((e) {
        final pct = e.variationPercentage!;
        final isPositive = pct >= 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: 14,
              color: isPositive ? AppColors.positiveGreen : Colors.redAccent,
            ),
            const SizedBox(width: 4),
            Text(
              '${e.period}: ${isPositive ? '+' : ''}${pct.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPositive ? AppColors.positiveGreen : Colors.redAccent,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          'Sin datos de variación',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
