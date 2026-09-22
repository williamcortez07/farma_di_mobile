import 'package:flutter/material.dart';

import 'screen/catalog.dart';
import 'screen/home.dart';
import 'screen/login.dart';
import 'screen/logs.dart';
import 'screen/metrics.dart';
import 'screen/roles.dart';
import 'screen/settings.dart';
import 'widgets/routes.dart';

void main() => runApp(const FarmaDiApp());

class FarmaDiApp extends StatelessWidget {
  const FarmaDiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farma-Di',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C3E50)),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.catalog: (_) => const CatalogScreen(),
        AppRoutes.metrics: (_) => const Metrics(),
        AppRoutes.logs: (_) => const LogsScreen(),
        AppRoutes.roles: (_) => const RolesScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
