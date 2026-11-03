import 'package:flutter/material.dart';

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
    final colors = Theme.of(context).colorScheme;
    final hasFooter = footerStartText != null || footerEndText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
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
            backgroundColor: colors.surfaceContainerHighest,
          ),
        ),
        if (hasFooter) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                footerStartText ?? '',
                style: TextStyle(fontSize: 11, color: colors.tertiary),
              ),
              Text(
                footerEndText ?? '',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
