import 'package:flutter/material.dart';

import '../widgets/botton_Navigation.dart';
import 'catalog.dart';
import 'logs.dart';
import 'metrics.dart';
import 'roles.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const <Widget>[
    _HomeOverview(),
    CatalogScreen(),
    Metrics(),
    LogsScreen(),
    RolesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        _currentIndex,
        (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Panel general',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
