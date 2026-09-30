// se crea este "widget "  o elemento para mostrar notificaciones en la
// app, se puede usar para mostrar mensajes de exito, error, cancelacion o
//alerta. Se puede usar en cualquier parte de la app y se puede personalizar
//el mensaje y el tipo de notificacion.
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum NotificationType { success, error, cancellation, alert }

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({
    super.key,
    required this.type,
    required this.message,
  });

  final NotificationType type;
  final String message;

  static void show(
    BuildContext context, {
    required NotificationType type,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: NotificationWidget(type: type, message: message),
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  Color get _accentColor {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.red;
      case NotificationType.cancellation:
        return AppColors.textSecondary;
      case NotificationType.alert:
        return AppColors.warning;
    }
  }

  Color get _backgroundColor {
    switch (type) {
      case NotificationType.success:
        return AppColors.successSoft;
      case NotificationType.error:
        return AppColors.redSoft;
      case NotificationType.cancellation:
        return AppColors.trackBackground;
      case NotificationType.alert:
        return AppColors.warningBackground;
    }
  }

  IconData get _icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.cancellation:
        return Icons.cancel_outlined;
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(_icon, size: 19, color: _accentColor),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
