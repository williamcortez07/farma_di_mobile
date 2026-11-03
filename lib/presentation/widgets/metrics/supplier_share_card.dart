import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'metrics_section_card.dart';

/// Modelo ligero para la distribución de proveedores.
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

/// Tarjeta que representa la distribución porcentual por proveedor con barra segmentada.
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
        children: [_buildBar(), const SizedBox(height: 14), _buildLegend()],
      ),
    );
  }

  Widget _buildBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: SizedBox(
        height: 10,
        child: Row(
          children: suppliers
              .map(
                (s) => Expanded(
                  flex: (s.percentage * 10).round(),
                  child: ColoredBox(color: s.color),
                ),
              )
              .toList(),
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
      itemBuilder: (_, i) {
        final s = suppliers[i];
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Text(
              '${s.percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        );
      },
    );
  }
}
