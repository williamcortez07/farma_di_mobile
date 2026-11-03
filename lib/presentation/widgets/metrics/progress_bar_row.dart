import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Fila con barra de progreso lineal para listas de productos y categorías.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trackColor = isDark ? const Color(0xFF263342) : AppColors.trackBackground;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final hasFooter = footerStartText != null || footerEndText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: barColor,
            backgroundColor: trackColor,
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
                style: TextStyle(
                  fontSize: 11,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
