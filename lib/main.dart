import 'package:farma_di_mobile/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:farma_di_mobile/widgets/botton_Navigation.dart';
import 'package:farma_di_mobile/screen/metrics.dart';
import 'package:farma_di_mobile/widgets/routes.dart';

void main() {
  runApp(const MyApp());
}

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
      body: const MetricsPage(),
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
