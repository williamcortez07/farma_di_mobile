import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/botton_Navigation.dart';
import 'catalog.dart';
import 'logs.dart';
import 'metrics.dart';
import 'roles.dart';
import 'settings.dart';

// Colores propios de esta pantalla
const Color _mutedTextColor = Color(0xFF7A858D);
const Color _titleColor = Color(0xFF18334A);
const Color _valueColor = Color(0xFF1D3346);
const Color _cardBorderColor = Color(0xFFE3E8EC);
const Color _positiveColor = Color(0xFF27AE60);
const Color _warningColor = Color(0xFFE67E22);
const Color _criticalColor = Color(0xFFE74C3C);
const Color _chartAccentColor = Color(0xFF3498DB);
const Color _chartLabelColor = Color(0xFF8A959D);
const Color _newUserColor = Color(0xFF6845A5);

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
    MetricsScreen(),
    LogsScreen(),
    RolesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LUNES, 28 DE SEPTIEMBRE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _chartAccentColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Panel general',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const _LogoutButton(),
              ],
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // TARJETAS DE ESTADÍSTICAS (KPIs aprobados)
            // --------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.medication_outlined,
                    iconColor: _criticalColor,
                    value: '14',
                    label: 'Próx. a vencer',
                    badge: '3 críticos',
                    badgeColor: _criticalColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFF9C6B3C),
                    value: '842 uds',
                    label: 'Más vendidos',
                    badge: '+18% sem',
                    badgeColor: _positiveColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.savings_outlined,
                    iconColor: const Color(0xFFE59B1A),
                    value: 'C\$ 18,420',
                    label: 'Ganancia bruta',
                    badge: 'Top: Genfar',
                    badgeColor: _chartAccentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.local_shipping_outlined,
                    iconColor: _warningColor,
                    value: '+4.2%',
                    label: 'Var. compras',
                    badge: 'vs mes ant.',
                    badgeColor: _warningColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // GRÁFICA
            // --------------------------------------------------
            const _SalesChartCard(),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // ACTIVIDAD RECIENTE
            // --------------------------------------------------
            const Text(
              'Actividad reciente',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            ),

            const SizedBox(height: 8),

            const _ActivityCard(
              color: _positiveColor,
              title: 'Venta #4821',
              description: 'C\$ 340.00',
              time: 'hace 5 min',
            ),

            const SizedBox(height: 7),

            const _ActivityCard(
              color: _warningColor,
              title: 'Stock bajo / Vencimiento',
              description: 'Amoxicilina 500mg (Lote #41)',
              time: 'hace 14 min',
            ),

            const SizedBox(height: 7),

            const _ActivityCard(
              color: _chartAccentColor,
              title: 'Recepción prov. Droguería Central',
              description: 'Orden #DC-9082 confirmada',
              time: 'hace 45 min',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOTÓN "SALIR" DEL ENCABEZADO
// ============================================================

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 14, color: _mutedTextColor),
              SizedBox(width: 5),
              Text(
                'Salir',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _mutedTextColor,
                ),
              ),
            ],
          ),
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
        border: Border.all(color: _cardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
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
              Icon(icon, size: 17, color: iconColor),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.10),
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
              color: _valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: _mutedTextColor,
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
        border: Border.all(color: _cardBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ventas — última semana',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'C\$ 45,960',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: _chartAccentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isSelected = index == 5;
                        return Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 8,
                              color: isSelected ? _chartAccentColor : _chartLabelColor,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 48),
                      FlSpot(1, 58),
                      FlSpot(2, 66),
                      FlSpot(3, 50),
                      FlSpot(4, 64),
                      FlSpot(5, 92),
                      FlSpot(6, 60),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.3,
                    barWidth: 1.8,
                    isStrokeCapRound: true,
                    color: _chartAccentColor,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot.x == 5,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3,
                        color: _chartAccentColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _chartAccentColor.withValues(alpha: 0.08),
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
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
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
                    style: const TextStyle(fontSize: 9, color: Color(0xFF687780)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(time, style: const TextStyle(fontSize: 8, color: _chartLabelColor)),
        ],
      ),
    );
  }
}