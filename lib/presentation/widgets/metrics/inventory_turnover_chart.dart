import 'package:flutter/material.dart';

import '../../../data/models/inventory/product_turnover_model.dart';
import '../../theme/app_colors.dart';

class InventoryTurnoverChart extends StatelessWidget {
  const InventoryTurnoverChart({super.key, required this.data});

  final List<ProductTurnoverModel> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyPlaceholder(label: 'Sin datos de rotación');
    }

    final maxRatio = data
        .map((e) => e.turnoverRatio)
        .reduce((a, b) => a > b ? a : b)
        .clamp(0.1, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorLegend(),
        const SizedBox(height: 12),
        // Una fila por producto
        ...data.map((item) => _TurnoverRow(item: item, maxRatio: maxRatio)),
      ],
    );
  }
}

class _TurnoverRow extends StatelessWidget {
  const _TurnoverRow({required this.item, required this.maxRatio});

  final ProductTurnoverModel item;
  final double maxRatio;

  @override
  Widget build(BuildContext context) {
    final ratio = item.turnoverRatio;
    final progress = (ratio / maxRatio).clamp(0.0, 1.0);
    final color = _barColor(ratio);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ratio.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: color,
              backgroundColor: AppColors.trackBackground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${item.dispatchedQuantity} despachados / ${item.batchInitialQuantity} inicial',
            style: const TextStyle(fontSize: 10, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Color _barColor(double ratio) {
    if (ratio >= 1.0) return AppColors.positiveGreen;
    if (ratio >= 0.5) return AppColors.chartBlue;
    return AppColors.warningOrange;
  }
}

class _ColorLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(AppColors.positiveGreen),
        const Text(
          'Alta  ',
          style: TextStyle(fontSize: 10, color: AppColors.mutedText),
        ),
        _dot(AppColors.chartBlue),
        const Text(
          'Media  ',
          style: TextStyle(fontSize: 10, color: AppColors.mutedText),
        ),
        _dot(AppColors.warningOrange),
        const Text(
          'Baja',
          style: TextStyle(fontSize: 10, color: AppColors.mutedText),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.only(right: 4),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
        ),
      ),
    );
  }
}
