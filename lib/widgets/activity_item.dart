import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Una fila de la sección Actividad reciente
/// descripción y hace cuánto ocurrió.
class ActivityItem extends StatelessWidget {
  final Color dotColor;
  final String description;
  final String time;

  const ActivityItem({
    super.key,
    required this.dotColor,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}