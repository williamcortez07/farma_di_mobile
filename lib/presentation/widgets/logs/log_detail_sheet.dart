import 'package:flutter/material.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';

/// Modal bottom sheet para visualizar los detalles completos de un registro de log
class LogDetailSheet extends StatelessWidget {
  const LogDetailSheet({super.key, required this.log});

  final SystemLogModel log;

  static void show(BuildContext context, SystemLogModel log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (_) => LogDetailSheet(log: log),
    );
  }

  Color _getLevelColor() {
    switch (log.normalizedLevel) {
      case 'Error':
        return AppColors.red;
      case 'Warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color _getLevelBgColor() {
    switch (log.normalizedLevel) {
      case 'Error':
        return AppColors.redSoft;
      case 'Warning':
        return AppColors.warningSoft;
      default:
        return AppColors.primarySoft;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/D';
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }

  @override
  Widget build(BuildContext context) {
    final identifier = log.id ?? log.traceId ?? 'N/D';

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior de arrastre
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles del Log',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          identifier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: AppColors.textMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _getLevelBgColor(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      log.normalizedLevel,
                      style: TextStyle(
                        color: _getLevelColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(color: AppColors.border, height: 24.0),

              // Información general
              _buildSectionTitle('Información General'),
              _buildDetailRow('Nivel', log.normalizedLevel, _getLevelColor()),
              _buildDetailRow('Fecha y Hora', _formatDateTime(log.timestamp), AppColors.textPrimary),
              _buildDetailRow('Usuario', log.userId ?? 'Anónimo', AppColors.textPrimary),
              _buildDetailRow('IP Cliente', log.clientIp ?? '::1', AppColors.textPrimary),
              _buildDetailRow('Entorno', log.environment ?? 'N/D', AppColors.textSecondary),
              _buildDetailRow('Trace ID', log.traceId ?? 'N/D', AppColors.textSecondary),

              const SizedBox(height: 12.0),

              // Petición HTTP
              if (log.request != null) ...[
                _buildSectionTitle('Petición HTTP'),
                _buildDetailRow('Método', log.request!.method ?? 'N/D', AppColors.primary),
                _buildDetailRow('Ruta', log.request!.path ?? 'N/D', AppColors.textPrimary),
                if (log.request!.queryString != null && log.request!.queryString!.isNotEmpty)
                  _buildDetailRow('Query String', log.request!.queryString!, AppColors.textSecondary),
                if (log.request!.payload != null && log.request!.payload!.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  const Text(
                    'Payload:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  _buildCodeBox(log.request!.payload!),
                ],
                const SizedBox(height: 12.0),
              ],

              // Respuesta HTTP
              if (log.response != null) ...[
                _buildSectionTitle('Respuesta'),
                _buildDetailRow(
                  'Código HTTP',
                  '${log.response!.statusCode ?? "N/D"}',
                  (log.response!.statusCode ?? 200) >= 400 ? AppColors.red : AppColors.success,
                ),
                _buildDetailRow(
                  'Tiempo de ejecución',
                  '${log.response!.elapsedMilliseconds ?? 0} ms',
                  AppColors.textPrimary,
                ),
                const SizedBox(height: 12.0),
              ],

              // Excepción técnica
              if (log.exception != null) ...[
                _buildSectionTitle('Excepción Técnica', color: AppColors.red),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.redSoft,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (log.exception!.message != null)
                        Text(
                          log.exception!.message!,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                      if (log.exception!.source != null && log.exception!.source!.isNotEmpty) ...[
                        const SizedBox(height: 6.0),
                        Text(
                          'Origen: ${log.exception!.source}',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                      if (log.exception!.stackTrace != null && log.exception!.stackTrace!.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          'StackTrace:\n${log.exception!.stackTrace}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11.0,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
              ],

              // Resumen
              _buildSectionTitle('Resumen del Evento'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  log.displayMessage,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.0,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.0,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 11.5,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
