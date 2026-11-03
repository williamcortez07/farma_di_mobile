import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/sales/category_share_model.dart';
import '../../theme/app_colors.dart';

/// KPI 3 – Participación de ventas por categoría (%).
///
/// Muestra un [PieChart] con la distribución porcentual de ingresos por
/// categoría, acompañado de una leyenda compacta.
class CategoryShareChart extends StatefulWidget {
  const CategoryShareChart({
    super.key,
    required this.data,
  });

  final List<CategoryShareModel> data;

  @override
  State<CategoryShareChart> createState() => _CategoryShareChartState();
}

class _CategoryShareChartState extends State<CategoryShareChart> {
  int _touchedIndex = -1;

  static const List<Color> _palette = [
    AppColors.primaryDark,
    AppColors.chartBlue,
    AppColors.positiveGreen,
    Color(0xFF8B7FE0),
    AppColors.warningOrange,
    Color(0xFFE0645F),
    Color(0xFFE0A438),
    AppColors.neutralGray,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const _EmptyState();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: List.generate(widget.data.length, (i) {
                final isTouched = i == _touchedIndex;
                final item = widget.data[i];
                return PieChartSectionData(
                  color: _palette[i % _palette.length],
                  value: item.sharePercentage,
                  radius: isTouched ? 70 : 58,
                  title: isTouched
                      ? '${item.sharePercentage.toStringAsFixed(1)}%'
                      : '',
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 24,
        crossAxisSpacing: 8,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, i) {
        final item = widget.data[i];
        final color = _palette[i % _palette.length];
        final isHighlighted = i == _touchedIndex;
        return GestureDetector(
          onTap: () => setState(
              () => _touchedIndex = _touchedIndex == i ? -1 : i),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.categoryName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isHighlighted
                        ? AppColors.primaryDark
                        : AppColors.mutedText,
                  ),
                ),
              ),
              Text(
                '${item.sharePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted ? color : AppColors.mutedText,
                ),
              ),
            ],
          ),
        );
      },
    );
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
          'Sin datos de categorías',
          style: TextStyle(color: AppColors.mutedText, fontSize: 13),
        ),
      ),
    );
  }
}
