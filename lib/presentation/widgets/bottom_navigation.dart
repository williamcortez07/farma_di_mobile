import 'package:flutter/material.dart';

Widget buildBottomNavigationBar(
  BuildContext context,
  int currentIndex,
  ValueChanged<int> onTap,
) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return Container(
    decoration: BoxDecoration(
      color: colors.surface,
      border: Border(top: BorderSide(color: theme.dividerColor, width: 0.6)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.18 : 0.08,
          ),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colors.surface,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          label: 'Catálogos',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Métricas'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Logs'),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: 'Roles',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
      ],
    ),
  );
}
