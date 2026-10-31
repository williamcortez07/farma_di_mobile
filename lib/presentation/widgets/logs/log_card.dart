import 'package:flutter/material.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';
import 'package:farma_di_mobile/presentation/widgets/logs/log_detail_sheet.dart';

/// Tarjeta visual reutilizable para representar un registro de Log
class LogCard extends StatelessWidget {
  const LogCard({
    super.key,
    required this.log,
    this.onTap,
  });

  final SystemLogModel log;
  final VoidCallback? onTap;

  String _normalizedLevel() {
    final lvl = (log.level ?? '').toUpperCase();
    if (lvl.contains('ERROR')) return 'ERROR';
    if (lvl.contains('WARN')) return 'WARN';
    return 'INFO';
  }

  Color _getLevelColor() {
    switch (_normalizedLevel()) {
      case 'ERROR':
        return AppColors.red;
      case 'WARN':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color _getLevelBgColor() {
    switch (_normalizedLevel()) {
      case 'ERROR':
        return AppColors.redSoft;
      case 'WARN':
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

  void _handleOpenDetails(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      LogDetailSheet.show(context, log);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortId = (log.id != null && log.id!.length > 10)
        ? log.id!.substring(0, 10)
        : (log.id ?? log.traceId ?? 'LOG');

    final method = log.request?.method ?? 'REQ';
    final path = log.request?.path ?? 'Sistema';
    final user = log.userId ?? 'Anónimo';
    final statusCode = log.response?.statusCode;
    final elapsed = log.response?.elapsedMilliseconds;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _handleOpenDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila 1: Badge de nivel + ID + Status Code + Botón Detalle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: _getLevelBgColor(),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            _normalizedLevel(),
                            style: TextStyle(
                              color: _getLevelColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          shortId,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.0,
                          ),
                        ),
                        if (statusCode != null) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: statusCode >= 400 ? AppColors.redSoft : AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              statusCode.toString(),
                              style: TextStyle(
                                color: statusCode >= 400 ? AppColors.red : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18.0, color: AppColors.ink),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Ver detalles',
                      onPressed: () => _handleOpenDetails(context),
                    ),
                  ],
                ),

                const SizedBox(height: 10.0),

                // Fila 2: Mensaje legible o ruta
                Text(
                  log.displayMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10.0),

                // Fila 3: Chips informativos (Método/Ruta, Usuario, Elapsed, Fecha)
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildChip('$method $path'),
                    _buildChip(user, icon: Icons.person_outline),
                    if (elapsed != null)
                      _buildChip('${elapsed}ms', icon: Icons.timer_outlined),
                    Text(
                      _formatDateTime(log.timestamp),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
      constraints: const BoxConstraints(maxWidth: 190),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.0, color: AppColors.textSecondary),
            const SizedBox(width: 4.0),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
