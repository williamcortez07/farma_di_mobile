import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Gráfico de línea para la evolución histórica de gasto en compras.
class SpendingLineChart extends StatelessWidget {
  const SpendingLineChart({super.key});

  static const List<FlSpot> _spots = [
    FlSpot(0, 96),
    FlSpot(1, 82),
    FlSpot(2, 100),
    FlSpot(3, 116),
    FlSpot(4, 142),
  ];

  static const List<String> _labels = [
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
            leftTitles: _spacer(),
            rightTitles: _spacer(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  final last = i == _labels.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: last ? FontWeight.w700 : FontWeight.w400,
                        color: last
                            ? AppColors.primaryDark
                            : AppColors.mutedText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _spots,
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

  AxisTitles _spacer() => AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 24,
      getTitlesWidget: (v, m) => const SizedBox.shrink(),
    ),
  );
}
