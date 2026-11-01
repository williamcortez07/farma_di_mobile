import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/inventory/expiring_batch_model.dart';
import '../../theme/app_colors.dart';

class ExpiringBatchesPanel extends StatelessWidget {
  const ExpiringBatchesPanel({
    super.key,
    required this.batches,
    required this.overallExpiringPercentage,
  });

  final List<ExpiringBatchModel> batches;
  final double overallExpiringPercentage;

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    if (batches.isEmpty) {
      return _NoExpiringState(overallPct: overallExpiringPercentage);
    }

    return Column(
      children: [
        _GlobalSummaryRow(
          count: batches.length,
          overallPct: overallExpiringPercentage,
        ),
        const SizedBox(height: 12),
        // Lista de lotes
        ...batches.map((b) => _BatchTile(batch: b, dateFmt: _dateFmt)),
      ],
    );
  }
}

class _GlobalSummaryRow extends StatelessWidget {
  const _GlobalSummaryRow({required this.count, required this.overallPct});

  final int count;
  final double overallPct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 16,
          color: AppColors.warningOrange,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$count ${count == 1 ? 'lote próximo' : 'lotes próximos'} a vencer',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        // Badge del % global
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: overallPct > 0
                ? AppColors.warningBackground
                : AppColors.positiveBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${overallPct.toStringAsFixed(1)}% total',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: overallPct > 0
                  ? AppColors.warningOrange
                  : AppColors.positiveGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _BatchTile extends StatelessWidget {
  const _BatchTile({required this.batch, required this.dateFmt});

  final ExpiringBatchModel batch;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    final consumed = batch.batchInitialQuantity - batch.availableQuantity;
    final progress = batch.batchInitialQuantity > 0
        ? (consumed / batch.batchInitialQuantity).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: batch.isCritical
            ? AppColors.warningBackground
            : AppColors.infoBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  batch.productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              _DaysBadge(days: batch.daysUntilExpiration),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.tag, size: 12, color: AppColors.mutedText),
              const SizedBox(width: 3),
              Text(
                batch.batchNumber,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.calendar_month_outlined,
                size: 12,
                color: AppColors.mutedText,
              ),
              const SizedBox(width: 3),
              Text(
                dateFmt.format(batch.expirationDate),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: progress >= 1.0
                  ? AppColors.positiveGreen
                  : AppColors.warningOrange,
              backgroundColor: AppColors.trackBackground,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${batch.availableQuantity} disponibles',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.mutedText,
                ),
              ),
              Text(
                'Lote: ${batch.batchInitialQuantity} uds.',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DaysBadge extends StatelessWidget {
  const _DaysBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final isCritical = days <= 7;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCritical ? AppColors.warningOrange : AppColors.chartBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            '$days días',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoExpiringState extends StatelessWidget {
  const _NoExpiringState({required this.overallPct});

  final double overallPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.positiveBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.positiveGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin lotes próximos a vencer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.positiveGreen,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'El inventario está dentro del rango de seguridad.',
                  style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
