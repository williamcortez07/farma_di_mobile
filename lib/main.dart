import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'presentation/screen/catalog.dart';
import 'presentation/screen/home.dart';
import 'presentation/screen/login.dart';
import 'presentation/screen/logs.dart';
import 'presentation/screen/metrics.dart';
import 'presentation/screen/roles.dart';
import 'presentation/screen/settings.dart';
import 'presentation/widgets/routes.dart';
import 'core/di/injection.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  setupDependencies(); 
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
      },
    );
  }
}
