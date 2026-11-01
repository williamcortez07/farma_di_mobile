import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/sales/gross_margin_model.dart';
import '../../theme/app_colors.dart';

/// KPI 2 – Margen bruto de ventas (%).
///
/// Muestra un [HorizontalBarChart] (barras horizontales) con el porcentaje
/// de margen bruto por producto.  Las barras se presentan de mayor a menor
/// margen según el ordenamiento aplicado en [SalesMetricsService].
class GrossMarginChart extends StatelessWidget {
  const GrossMarginChart({
    super.key,
    required this.data,
  });

  final List<GrossMarginModel> data;

  // Todos los productos comparten el mismo margen % en el data mart (4.76 %).
  // El chart muestra el margen absoluto (grossMargin) para diferenciarlos
  // visualmente, y el % se muestra como etiqueta.
  static const double _barHeight = 14;
  static const double _rowSpacing = 28;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _EmptyState();

    final maxValue =
        data.map((e) => e.grossMargin).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: data.length * _rowSpacing + 20,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: data.length.toDouble(),
          minY: 0,
          rotationQuarterTurns: 1, // hace las barras horizontales
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primaryDark,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = data[group.x];
                return BarTooltipItem(
                  '${item.productName}\n'
                  'Margen: C\$${item.grossMargin.toStringAsFixed(0)}\n'
                  '${item.grossMarginPercentage.toStringAsFixed(2)}%',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Eje izquierdo → nombres de productos (aparece abajo por la rotación)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 90,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      data[index].productName,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Eje superior → valor del margen (aparece a la derecha por la rotación)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'C\$${data[index].grossMargin.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            final normalizedValue =
                (data[i].grossMargin / maxValue) * (data.length - 0.5);
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: normalizedValue,
                  color: _barColor(i),
                  width: _barHeight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: data.length.toDouble(),
                    color: AppColors.trackBackground,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Color _barColor(int index) {
    const colors = [
      AppColors.primaryDark,
      AppColors.chartBlue,
      AppColors.positiveGreen,
      Color(0xFF8B7FE0),
      AppColors.warningOrange,
      Color(0xFFE0645F),
      AppColors.chartBlue,
      AppColors.positiveGreen,
    ];
    return colors[index % colors.length];
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'Sin datos de margen',
          style: TextStyle(color: AppColors.mutedText, fontSize: 13),
        ),
      ),
    );
  }
}
