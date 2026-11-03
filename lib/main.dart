import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection.dart';
import 'core/services/settings_controller.dart';
import 'presentation/screen/catalog_screen.dart';
import 'presentation/screen/home_screen.dart';
import 'presentation/screen/login_screen.dart';
import 'presentation/screen/logs_screen.dart';
import 'presentation/screen/metrics_screen.dart';
import 'presentation/screen/profile_screen.dart';
import 'presentation/screen/roles_screen.dart';
import 'presentation/screen/settings_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await initializeDateFormatting('es');
  await SettingsController.instance.load();

  setupDependencies();

  runApp(const FarmaDiApp());
}

class FarmaDiApp extends StatelessWidget {
  const FarmaDiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Farma-DI',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);

            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(settings.textScaleFactor),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: AppRoutes.login,
          routes: {
            AppRoutes.home: (_) => const HomeScreen(),
            AppRoutes.login: (_) => const LoginPage(),
            AppRoutes.catalog: (_) => const CatalogScreen(),
            AppRoutes.metrics: (_) => const MetricsScreen(),
            AppRoutes.logs: (_) => const LogsScreen(),
            AppRoutes.roles: (_) => const RolesScreen(),
            AppRoutes.settings: (_) => const SettingsScreen(),
            AppRoutes.profile: (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
