import 'package:flutter/material.dart';

Widget buildBottomNavigationBar(
  BuildContext context,
  int currentIndex,
  ValueChanged<int> onTap,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
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
