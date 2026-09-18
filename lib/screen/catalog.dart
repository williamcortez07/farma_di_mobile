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

  Widget _buildProductsList() {
    final List<Map<String, dynamic>> allProducts = [
      {"name": "Paracetamol 500mg", "desc": "Bayer · Analgésicos", "price": "12.50", "stock": 142, "status": 1},
      {"name": "Ibuprofeno 400mg", "desc": "Genfar · Analgésicos", "price": "9.75", "stock": 8, "status": 2},
      {"name": "Amoxicilina 500mg", "desc": "MK · Antibióticos", "price": "24.00", "stock": 55, "status": 1},
      {"name": "Vitamina C 1g", "desc": "Redoxon · Vitaminas", "price": "18.50", "stock": 0, "status": 3},
      {"name": "Loratadina 10mg", "desc": "Bayer · Antihistamínicos", "price": "7.25", "stock": 230, "status": 1},
      {"name": "Metformina 850mg", "desc": "MK · Antidiabéticos", "price": "32.00", "stock": 88, "status": 1},
      {"name": "Omeprazol 20mg", "desc": "Genfar · Gastrointestinal", "price": "15.80", "stock": 17, "status": 2},
      {"name": "Atorvastatina 20mg", "desc": "Pfizer · Cardiovascular", "price": "45.00", "stock": 0, "status": 3},
    ];

    List<Map<String, dynamic>> filteredProducts = allProducts;
    if (_selectedFilter != 0) {
      filteredProducts = allProducts.where((p) => p['status'] == _selectedFilter).toList();
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text("💊", style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "Q ${product['price']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product['desc'],
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(product['status']),
                    const SizedBox(width: 8),
                    Text(
                      "${product['stock']} uds.",
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 1:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        text = "En stock";
        break;
      case 2:
        bgColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        text = "Stock bajo";
        break;
      case 3:
      default:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        text = "Agotado";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }