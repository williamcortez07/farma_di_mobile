import 'package:flutter/material.dart';
// Asegúrate de que estas rutas coincidan con la ubicación de tus archivos
import '../widgets/botton_Navigation.dart'; 
import '../widgets/routes.dart'; 

// --- PUNTO DE ENTRADA AISLADO PARA PRUEBAS ---
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.catalog,
      routes: {
        AppRoutes.home: (context) => _dummyScreen('Inicio', AppRoutes.home),
        AppRoutes.catalog: (context) => const CatalogScreen(),
        AppRoutes.metrics: (context) => _dummyScreen('Métricas', AppRoutes.metrics),
        AppRoutes.logs: (context) => _dummyScreen('Logs', AppRoutes.logs),
        AppRoutes.roles: (context) => _dummyScreen('Roles', AppRoutes.roles),
        AppRoutes.settings: (context) => _dummyScreen('Ajustes', AppRoutes.settings),
      },
    ),
  );
}

// Pantalla temporal para evitar errores al probar la navegación
Widget _dummyScreen(String title, String route) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('Pantalla de $title en construcción')),
    bottomNavigationBar: Builder(
      builder: (context) {
        int index = 0;
        if (route == AppRoutes.catalog) index = 1;
        if (route == AppRoutes.metrics) index = 2;
        if (route == AppRoutes.logs) index = 3;
        if (route == AppRoutes.roles) index = 4;
        if (route == AppRoutes.settings) index = 5;

        return buildBottomNavigationBar(context, index, (newIndex) {
          String nextRoute = AppRoutes.home;
          switch (newIndex) {
            case 0: nextRoute = AppRoutes.home; break;
            case 1: nextRoute = AppRoutes.catalog; break;
            case 2: nextRoute = AppRoutes.metrics; break;
            case 3: nextRoute = AppRoutes.logs; break;
            case 4: nextRoute = AppRoutes.roles; break;
            case 5: nextRoute = AppRoutes.settings; break;
          }
          Navigator.pushReplacementNamed(context, nextRoute);
        });
      }
    ),
  );
}


class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int _selectedTab = 0; // 0: Productos, 1: Categorias, 2: Marcas
  int _selectedFilter = 0; // 0: Todos, 1: En stock, 2: Stock bajo, 3: Agotado
  int _bottomNavIndex = 1; // 1: Índice de "Catálogos"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // Integración de tu BottomNavigationBar
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        _bottomNavIndex,
        (int index) {
          if (_bottomNavIndex == index) return; 

          String routeName = '';
          switch (index) {
            case 0:
              routeName = AppRoutes.home;
              break;
            case 1:
              routeName = AppRoutes.catalog;
              break;
            case 2:
              routeName = AppRoutes.metrics;
              break;
            case 3:
              routeName = AppRoutes.logs;
              break;
            case 4:
              routeName = AppRoutes.roles;
              break;
            case 5:
              routeName = AppRoutes.settings;
              break;
          }

          if (routeName.isNotEmpty) {
            Navigator.pushReplacementNamed(context, routeName);
          }
        },
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Catálogos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildMainTabs(),
              const SizedBox(height: 16),
              
              if (_selectedTab == 0) ...[
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 16),
                Expanded(child: _buildProductsList()),
              ] else if (_selectedTab == 1) ...[
                Expanded(child: _buildCategoriesList()),
              ] else if (_selectedTab == 2) ...[
                const SizedBox(height: 16),
                Expanded(child: _buildBrandsList()),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem("Productos", 0),
          _buildTabItem("Categorias", 1),
          _buildTabItem("Marcas", 2),
        ],
      ),
    );
  }
