import 'package:flutter/material.dart';

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
    final colors = Theme.of(context).colorScheme;
    return MetricsSectionCard(
      title: 'Participación por proveedor',
      subtitle: 'Distribución de volumen',
      trailing: Icon(
        Icons.pie_chart_outline,
        size: 18,
        color: colors.onSurfaceVariant,
      ),
      child: Column(
        children: [
          _buildBar(),
          const SizedBox(height: 14),
          _buildLegend(context),
        ],
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

  Widget _buildLegend(BuildContext context) {
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
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              '${s.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
  Widget _buildLegend() {
    return Builder(
      builder: (context) {
        final onSurface = Theme.of(context).colorScheme.onSurface;

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
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurface,
                    ),
                  ),
                ),
                Text(
                  '${s.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
