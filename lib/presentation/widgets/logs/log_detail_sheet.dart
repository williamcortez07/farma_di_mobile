import 'package:flutter/material.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';

/// Modal bottom sheet para visualizar los detalles completos de un registro de log
class LogDetailSheet extends StatelessWidget {
  const LogDetailSheet({super.key, required this.log});

  final SystemLogModel log;

  static void show(BuildContext context, SystemLogModel log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (_) => LogDetailSheet(log: log),
    );
  }

  Color _getLevelColor(BuildContext context) {
    switch (log.normalizedLevel) {
      case 'Error':
        return Theme.of(context).colorScheme.error;
      case 'Warning':
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getLevelBgColor(BuildContext context) {
    switch (log.normalizedLevel) {
      case 'Error':
        return Theme.of(context).colorScheme.errorContainer;
      case 'Warning':
        return Theme.of(context).colorScheme.tertiaryContainer;
      default:
        return Theme.of(context).colorScheme.primaryContainer;
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
                    color: Theme.of(context).dividerColor,
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
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          identifier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelBgColor(context),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      log.normalizedLevel,
                      style: TextStyle(
                        color: _getLevelColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              Divider(color: Theme.of(context).dividerColor, height: 24.0),

              // Información general
              _buildSectionTitle(context, 'Información General'),
              _buildDetailRow(
                context,
                'Nivel',
                log.normalizedLevel,
                _getLevelColor(context),
              ),
              _buildDetailRow(
                context,
                'Fecha y Hora',
                _formatDateTime(log.timestamp),
                Theme.of(context).colorScheme.onSurface,
              ),
              _buildDetailRow(
                context,
                'Usuario',
                log.userId ?? 'Anónimo',
                Theme.of(context).colorScheme.onSurface,
              ),
              _buildDetailRow(
                context,
                'IP Cliente',
                log.clientIp ?? '::1',
                Theme.of(context).colorScheme.onSurface,
              ),
              _buildDetailRow(
                context,
                'Entorno',
                log.environment ?? 'N/D',
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              _buildDetailRow(
                context,
                'Trace ID',
                log.traceId ?? 'N/D',
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),

              const SizedBox(height: 12.0),

              // Petición HTTP
              if (log.request != null) ...[
                _buildSectionTitle(context, 'Petición HTTP'),
                _buildDetailRow(
                  context,
                  'Método',
                  log.request!.method ?? 'N/D',
                  Theme.of(context).colorScheme.primary,
                ),
                _buildDetailRow(
                  context,
                  'Ruta',
                  log.request!.path ?? 'N/D',
                  Theme.of(context).colorScheme.onSurface,
                ),
                if (log.request!.queryString != null &&
                    log.request!.queryString!.isNotEmpty)
                  _buildDetailRow(
                    context,
                    'Query String',
                    log.request!.queryString!,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                if (log.request!.payload != null &&
                    log.request!.payload!.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    'Payload:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  _buildCodeBox(context, log.request!.payload!),
                ],
                const SizedBox(height: 12.0),
              ],

              // Respuesta HTTP
              if (log.response != null) ...[
                _buildSectionTitle(context, 'Respuesta'),
                _buildDetailRow(
                  context,
                  'Código HTTP',
                  '${log.response!.statusCode ?? "N/D"}',
                  (log.response!.statusCode ?? 200) >= 400
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.tertiary,
                ),
                _buildDetailRow(
                  context,
                  'Tiempo de ejecución',
                  '${log.response!.elapsedMilliseconds ?? 0} ms',
                  Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 12.0),
              ],

              // Excepción técnica
              if (log.exception != null) ...[
                _buildSectionTitle(
                  context,
                  'Excepción Técnica',
                  color: Theme.of(context).colorScheme.error,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (log.exception!.message != null)
                        Text(
                          log.exception!.message!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                      if (log.exception!.source != null &&
                          log.exception!.source!.isNotEmpty) ...[
                        const SizedBox(height: 6.0),
                        Text(
                          'Origen: ${log.exception!.source}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                      if (log.exception!.stackTrace != null &&
                          log.exception!.stackTrace!.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          'StackTrace:\n${log.exception!.stackTrace}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
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
              _buildSectionTitle(context, 'Resumen del Evento'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  log.displayMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.0,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildCodeBox(BuildContext context, String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 11.5,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
