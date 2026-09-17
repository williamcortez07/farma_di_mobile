import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fila de Preferencias con tít, subtít y switch a la derecha.
/// Es un StatefulWidget propio porque cada fila maneja su encendido/apagado
/// de forma independiente (todavía no hay persistencia real).
class SettingsSwitchTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<SettingsSwitchTile> createState() => _SettingsSwitchTileState();
}

class _SettingsSwitchTileState extends State<SettingsSwitchTile> {
  late bool _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: _value,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged?.call(v);
            },
          ),
        ],
      ),
    );
  }
}