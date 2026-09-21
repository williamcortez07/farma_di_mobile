import 'package:farma_di_mobile/screen/home.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
=======
import 'package:farma_di_mobile/widgets/botton_Navigation.dart';
import 'package:farma_di_mobile/screen/metrics.dart';
import 'package:farma_di_mobile/widgets/routes.dart';
>>>>>>> 39b85324467656d1441ee36ac07ccc4a10ab0d92

import 'widgets/routes.dart';
import 'screen/login.dart';
import 'screen/home.dart';

<<<<<<< HEAD
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
      home: const LoginPage(),
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        // Las demás rutas se agregan cuando existan sus pantallas.
      },
    );
  }
}
=======
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currenteIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Metrics(),
      bottomNavigationBar: buildBottomNavigationBar(context, _currenteIndex, (
        index,
      ) {
        setState(() {
          _currenteIndex = index;
        });
      }),
    );
  }
}
>>>>>>> 39b85324467656d1441ee36ac07ccc4a10ab0d92
