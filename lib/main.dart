
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'presentation/screen/catalog.dart';
import 'presentation/screen/home.dart';
import 'presentation/screen/login.dart';
import 'presentation/screen/logs.dart';
import 'presentation/screen/metrics.dart';
import 'presentation/screen/roles.dart';
import 'presentation/screen/settings.dart';
import 'presentation/settings/app_preferences.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  setupDependencies();
  await AppPreferences.load();

  runApp(const FarmaDiApp());
}

class FarmaDiApp extends StatelessWidget {
  const FarmaDiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppPreferences.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppPreferences.locale,
          builder: (context, locale, _) {
            return ValueListenableBuilder<double>(
              valueListenable: AppPreferences.textScale,
              builder: (context, textScale, _) {
                return MaterialApp(
                  title: 'Farma-Di',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: const [
                    Locale('es'),
                    Locale('en'),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  builder: (context, child) {
                    final media = MediaQuery.of(context);

                    return MediaQuery(
                      data: media.copyWith(
                        textScaler: TextScaler.linear(textScale),
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
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
