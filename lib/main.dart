import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'presentation/screen/catalog_screen.dart';
import 'presentation/screen/home_screen.dart';
import 'presentation/screen/login_screen.dart';
import 'presentation/screen/logs_screen.dart';
import 'presentation/screen/metrics_screen.dart';
import 'presentation/screen/roles_screen.dart';
import 'presentation/screen/settings_screen.dart';
import 'presentation/widgets/routes.dart';
import 'presentation/screen/profile_screen.dart';

// se usa intl para no tener que formatear a mano la fecha
//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const FarmaDiApp());
}

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
        AppRoutes.metrics: (_) => const MetricsScreen(),
        AppRoutes.logs: (_) => const LogsScreen(),
        AppRoutes.roles: (_) => const RolesScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.profile:(_) => const ProfileScreen(),
      },
    );
  }
}
