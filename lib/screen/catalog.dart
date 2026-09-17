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

