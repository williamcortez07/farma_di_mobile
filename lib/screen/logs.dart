import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los logs de la aplicación.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
