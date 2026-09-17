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

