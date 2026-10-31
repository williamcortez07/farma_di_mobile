import 'package:flutter/material.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';
import 'package:farma_di_mobile/presentation/widgets/logout_button.dart';

class ProfileLogoutCard extends StatelessWidget {
  const ProfileLogoutCard({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Finalizar la sesión en este dispositivo',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          LogoutButton(onPressed: onLogout),
        ],
      ),
    );
  }
}
