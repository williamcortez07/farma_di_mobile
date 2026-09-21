import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screen/home.dart';

void main() {
  runApp(const FarmaDiApp());
}

class FarmaDiApp extends StatelessWidget {
  const FarmaDiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farma-Di',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
