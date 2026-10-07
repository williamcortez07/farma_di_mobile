import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout, size: 16),
      label: const Text('Salir'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.trackBackground),
        shape: const StadiumBorder(),
      ),
    );
  }
}
