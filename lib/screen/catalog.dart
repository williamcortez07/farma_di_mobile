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

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C3E50) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, marca o categ...',
        hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFA0AEC0)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    List<String> filters = ["Todos", "En stock", "Stock bajo", "Agotado"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          bool isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = index);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF2C3E50),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

 