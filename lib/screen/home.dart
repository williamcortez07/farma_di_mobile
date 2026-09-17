import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/sales_line_chart.dart';
import '../widgets/activity_item.dart';

/// Pantalla Panel general de la farmacia.
/// Todos los datos de aquí son de prueba (mock);
/// más adelante se reemplazan por datos reales del backend.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    // Necesario para que DateFormat pueda formatear en español.
    initializeDateFormatting('es', null).then((_) {
      if (mounted) setState(() => _localeReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate = _localeReady
        ? DateFormat('EEEE, d de MMMM', 'es').format(today).toUpperCase()
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Panel general',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Grid 2x2 de tarjetas de estadísticas.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: const [
              StatCard(
                icon: Icons.paid_outlined,
                iconColor: AppColors.amber,
                iconBackground: AppColors.amberSoft,
                badgeText: '+12.4%',
                badgeColor: AppColors.success,
                badgeBackground: AppColors.successSoft,
                value: 'C\$ 9,640',
                label: 'Ventas hoy',
              ),
              StatCard(
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.purple,
                iconBackground: AppColors.purpleSoft,
                badgeText: '+8 vs ayer',
                badgeColor: AppColors.success,
                badgeBackground: AppColors.successSoft,
                value: '47',
                label: 'Pedidos',
              ),
              StatCard(
                icon: Icons.medication_outlined,
                iconColor: AppColors.red,
                iconBackground: AppColors.redSoft,
                badgeText: '18 bajo stock',
                badgeColor: AppColors.warning,
                badgeBackground: AppColors.warningSoft,
                value: '1,284',
                label: 'Productos',
              ),
              StatCard(
                icon: Icons.groups_outlined,
                iconColor: AppColors.purple,
                iconBackground: AppColors.purpleSoft,
                badgeText: '3 en línea',
                badgeColor: AppColors.success,
                badgeBackground: AppColors.successSoft,
                value: '12',
                label: 'Usuarios activos',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjeta del gráfico de ventas.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'C\$ 45,960',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SalesLineChart(
                  values: [32000, 38500, 41000, 39200, 43500, 47200, 45960],
                  labels: ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Actividad reciente',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                ActivityItem(
                  dotColor: AppColors.success,
                  description: 'Venta #4821 — C\$ 340.00',
                  time: 'hace 5 min',
                ),
                Divider(height: 1, color: AppColors.border),
                ActivityItem(
                  dotColor: AppColors.warning,
                  description: 'Stock bajo: Paracetamol 500mg',
                  time: 'hace 14 min',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}