import 'package:flutter/material.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';
import 'package:farma_di_mobile/services/log_service.dart';

/// Barra de filtros por categoría para los Logs del sistema.
/// Permite conmutar entre la visualización general del día (ALL)
/// y las categorías de severidad: Information, Warning y Error.
class LogFilterBar extends StatelessWidget {
  const LogFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.totalCount,
    this.errorCount,
    this.warningCount,
    this.infoCount,
  });

  final LogCategory selectedCategory;
  final ValueChanged<LogCategory> onCategorySelected;
  final int? totalCount;
  final int? errorCount;
  final int? warningCount;
  final int? infoCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            category: LogCategory.today,
            label: 'ALL',
            dotColor: null,
            count: totalCount?.toString(),
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(width: 8.0),
          _buildFilterChip(
            category: LogCategory.error,
            label: 'ERROR',
            dotColor: AppColors.red,
            count: errorCount?.toString(),
            icon: Icons.error_outline,
          ),
          const SizedBox(width: 8.0),
          _buildFilterChip(
            category: LogCategory.warning,
            label: 'WARN',
            dotColor: AppColors.warning,
            count: warningCount?.toString(),
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(width: 8.0),
          _buildFilterChip(
            category: LogCategory.information,
            label: 'INFO',
            dotColor: AppColors.primary,
            count: infoCount?.toString(),
            icon: Icons.info_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required LogCategory category,
    required String label,
    required Color? dotColor,
    required IconData icon,
    String? count,
  }) {
    final bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Icon(Icons.circle, size: 8.0, color: dotColor),
              const SizedBox(width: 6.0),
            ] else ...[
              Icon(icon, size: 13.0, color: isSelected ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13.0,
              ),
            ),
            if (count != null && count.isNotEmpty) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.track,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
