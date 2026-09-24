import 'package:fl_chart/fl_chart.dart';
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
      backgroundColor: const Color(0xFFF5F7F8),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        _currentIndex,
        (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ============================================================
// HOME / PANEL GENERAL
// ============================================================

class _HomeOverview extends StatelessWidget {
  const _HomeOverview();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // ENCABEZADO
            // --------------------------------------------------
            const Text(
              'JUEVES, 24 DE SEPTIEMBRE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A858D),
                letterSpacing: 0.4,
              ),
            ),

            const SizedBox(height: 3),

            const Text(
              'Panel general',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF18334A),
              ),
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // TARJETAS DE ESTADÍSTICAS
            // --------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.monetization_on_outlined,
                    iconColor: const Color(0xFFE59B1A),
                    value: 'C\$ 9,640',
                    label: 'Ventas hoy',
                    badge: '+12.4%',
                    badgeColor: const Color(0xFF27AE60),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFF9C6B3C),
                    value: '47',
                    label: 'Pedidos',
                    badge: '+8 vs ayer',
                    badgeColor: const Color(0xFF27AE60),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.medication_outlined,
                    iconColor: const Color(0xFFE84C88),
                    value: '1,284',
                    label: 'Productos',
                    badge: '18 bajo stock',
                    badgeColor: const Color(0xFFE67E22),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.people_alt_outlined,
                    iconColor: const Color(0xFF6845A5),
                    value: '12',
                    label: 'Usuarios activos',
                    badge: '3 en línea',
                    badgeColor: const Color(0xFF27AE60),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // GRÁFICA
            // --------------------------------------------------
            _SalesChartCard(),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // ACTIVIDAD RECIENTE
            // --------------------------------------------------
            const Text(
              'Actividad reciente',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18334A),
              ),
            ),

            const SizedBox(height: 8),

            _ActivityCard(
              color: const Color(0xFF27AE60),
              title: 'Venta #4821',
              description: 'C\$ 340.00',
              time: 'hace 5 min',
            ),

            const SizedBox(height: 7),

            _ActivityCard(
              color: const Color(0xFFE67E22),
              title: 'Stock bajo',
              description: 'Paracetamol 500mg',
              time: 'hace 14 min',
            ),

            const SizedBox(height: 7),

            _ActivityCard(
              color: const Color(0xFF6845A5),
              title: 'Nuevo usuario',
              description: 'Administrador registrado',
              time: 'hace 28 min',
            ),

            const SizedBox(height: 7),

            _ActivityCard(
              color: const Color(0xFF3498DB),
              title: 'Producto actualizado',
              description: 'Ibuprofeno 400mg',
              time: 'hace 42 min',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TARJETA DE ESTADÍSTICA
// ============================================================

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String badge;
  final Color badgeColor;

  const _DashboardCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE3E8EC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 17,
                color: iconColor,
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3346),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF7A858D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETA DE GRÁFICA
// ============================================================

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE3E8EC),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // TITULO DE LA GRÁFICA
          // --------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ventas — última semana',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18334A),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'C\$ 45,960',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3498DB),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // GRÁFICA
          // --------------------------------------------------
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,

                // Sin bordes
                borderData: FlBorderData(
                  show: false,
                ),

                // Sin cuadrícula
                gridData: FlGridData(
                  show: false,
                ),

                // Ejes
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'L',
                          'M',
                          'X',
                          'J',
                          'V',
                          'S',
                          'D',
                        ];

                        final index = value.toInt();

                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            days[index],
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF8A959D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Línea
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 52),
                      FlSpot(1, 63),
                      FlSpot(2, 56),
                      FlSpot(3, 72),
                      FlSpot(4, 80),
                      FlSpot(5, 91),
                      FlSpot(6, 68),
                    ],

                    isCurved: true,
                    curveSmoothness: 0.3,

                    barWidth: 1.8,

                    isStrokeCapRound: true,

                    color: const Color(0xFF3498DB),

                    dotData: const FlDotData(
                      show: false,
                    ),

                    // Área debajo de la línea
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF3498DB).withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTIVIDAD RECIENTE
// ============================================================

class _ActivityCard extends StatelessWidget {
  final Color color;
  final String title;
  final String description;
  final String time;

  const _ActivityCard({
    required this.color,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 48,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFE3E8EC),
        ),
      ),
      child: Row(
        children: [
          // Punto de actividad
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 9),

          // Información
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title — ',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF394B59),
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF687780),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          Text(
            time,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF8A959D),
            ),
          ),
        ],
      ),
    );
  }
}