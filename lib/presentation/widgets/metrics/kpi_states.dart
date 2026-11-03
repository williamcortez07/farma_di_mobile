import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Skeleton animado de carga para los KPIs de métricas.
class KpiSkeleton extends StatelessWidget {
  const KpiSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.chartBlue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Cargando datos del data mart…',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista de error para un KPI individual.
class KpiError extends StatelessWidget {
  const KpiError({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 24),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: onRetry,
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.chartBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper para alternar entre loading, error y contenido según el estado de un KPI.
Widget buildKpiBody({
  required dynamic status,
  required String? error,
  required Widget child,
  VoidCallback? onRetry,
}) {
  final isLoading = status.toString().endsWith('loading');
  final isError = status.toString().endsWith('error');

  if (isLoading) return const KpiSkeleton();
  if (isError) {
    return KpiError(
      message: error ?? 'Error desconocido',
      onRetry: onRetry,
    );
  }
  return child;
}
