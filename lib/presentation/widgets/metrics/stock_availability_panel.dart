import 'package:flutter/material.dart';

import '../../../data/models/inventory/inventory_availability_model.dart';
import '../../theme/app_colors.dart';

class StockAvailabilityPanel extends StatelessWidget {
  const StockAvailabilityPanel({super.key, required this.data});

  final InventoryAvailabilityModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tres stat-cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline,
                label: 'En stock',
                value: '${data.inStockProducts}',
                iconColor: AppColors.positiveGreen,
                bgColor: AppColors.positiveBackground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.warning_amber_outlined,
                label: 'Crítico',
                value: '${data.criticalStockProducts}',
                iconColor: AppColors.warningOrange,
                bgColor: AppColors.warningBackground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.remove_circle_outline,
                label: 'Sin stock',
                value: '${data.outOfStockProducts}',
                iconColor: const Color(0xFFE0645F),
                bgColor: const Color(0xFFFBE9E8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Barra de disponibilidad global
        _AvailabilityBar(
          rate: data.availabilityRatePercentage,
          total: data.totalProducts,
        ),
      ],
    );
  }
}

// Stat-card individual

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

// Barra de disponibilidad global

class _AvailabilityBar extends StatelessWidget {
  const _AvailabilityBar({required this.rate, required this.total});

  final double rate;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = (rate / 100).clamp(0.0, 1.0);
    final barColor = rate >= 90
        ? AppColors.positiveGreen
        : rate >= 70
        ? AppColors.chartBlue
        : AppColors.warningOrange;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Disponibilidad global',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              '${rate.toStringAsFixed(1)}%  •  $total productos',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: barColor,
            backgroundColor: AppColors.trackBackground,
          ),
        ),
      ],
    );
  }
}
