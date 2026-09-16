import 'package:flutter/material.dart';
import 'package:farma_di_mobile/widgets/botton_Navigation.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MetricsApp());
}

class MetricsApp extends StatelessWidget {
  const MetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel general',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFFFFFFC),
      ),
      home: const MetricsPage(),
    );
  }
}

class MetricsPage extends StatefulWidget {
  const MetricsPage({super.key});

  @override
  State<MetricsPage> createState() => _MetricsPageState();
}

class _MetricsPageState extends State<MetricsPage> {
  int _currentIndex = 2;

  final List<String> _viewTitles = const [
    'Inicio',
    'Catálogos',
    'Panel general',
    'Logs',
    'Roles',
    'Ajustes',
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd/MM/yyyy')
        .format(DateTime.now());
    final String currentTitle = _viewTitles[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fecha actual: $formattedDate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                currentTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    'Contenido de $currentTitle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        _currentIndex,
        _onNavigationTap,
      ),
    );
  }
}
