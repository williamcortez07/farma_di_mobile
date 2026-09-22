import 'package:farma_di_mobile/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/routes.dart';
import 'screen/login.dart';
import 'screen/home.dart';

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
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.login: (_) => const LoginPage(),
        // Las demás rutas se agregan cuando existan sus pantallas.
      },
    );
  }
}
