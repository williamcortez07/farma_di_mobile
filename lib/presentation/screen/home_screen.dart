import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../data/models/auth_model/user_model.dart';
import '../../data/models/inventory/inventory_data_mart_response.dart';
import '../../data/models/sales/sales_data_mart_response.dart';
import '../../services/inventory_metrics_service.dart';
import '../../services/sales_metrics_service.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_navbar.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/routes.dart';

import 'catalog_screen.dart';
import 'logs_screen.dart';
import 'metrics_screen.dart';
import 'activity_screen.dart';
import 'roles_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = getIt<UserProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _userProvider,
      builder: (context, _) {
        final user = _userProvider.user;

        final screens = <Widget>[
          _HomeOverview(
            user: user,
            onViewActivity: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ActivityScreen()),
              );
            },
            onViewMetrics: () => setState(() => _currentIndex = 2),
          ),
          const CatalogScreen(),
          const MetricsScreen(),
          const LogsScreen(),
          const RolesScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppNavbar(
            profileImageUrl: null,
            userInitials: user?.initials,
            userName: user?.userName,
            onProfileTap: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: buildBottomNavigationBar(
            context,
            _currentIndex,
            (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// HOME: resumen compacto, KPIs y accesos a la actividad detallada.
// -----------------------------------------------------------------------------

class _HomeOverview extends StatefulWidget {
  const _HomeOverview({
    required this.user,
    required this.onViewActivity,
    required this.onViewMetrics,
  });

  final UserModel? user;
  final VoidCallback onViewActivity;
  final VoidCallback onViewMetrics;

  @override
  State<_HomeOverview> createState() => _HomeOverviewState();
}

class _HomeOverviewState extends State<_HomeOverview> {
  final SalesMetricsService _salesService = SalesMetricsService();
  final InventoryMetricsService _inventoryService = InventoryMetricsService();

  SalesDataMartResponse? _sales;
  InventoryDataMartResponse? _inventory;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKpis();
  }

  Future<void> _loadKpis() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final results = await Future.wait<dynamic>([
      _salesService.fetchFullDataMart().then<dynamic>(
        (value) => value,
        onError: (Object error) => error,
      ),
      _inventoryService.fetchFullDataMart().then<dynamic>(
        (value) => value,
        onError: (Object error) => error,
      ),
    ]);

    if (!mounted) return;

    setState(() {
      if (results[0] is SalesDataMartResponse) {
        _sales = results[0] as SalesDataMartResponse;
      }

      if (results[1] is InventoryDataMartResponse) {
        _inventory = results[1] as InventoryDataMartResponse;
      }

      final errors = <String>[];

      if (_sales == null) errors.add('No se pudieron cargar las ventas.');
      if (_inventory == null) {
        errors.add('No se pudo cargar el inventario.');
      }

      _error = errors.isEmpty ? null : errors.join(' ');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadKpis,
      color: AppColors.chartBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel general',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.user != null
                  ? 'Bienvenido, ${widget.user!.fullName}'
                  : 'Resumen de actividad de Farma-DI',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),

            // La actividad ya no despliega cientos de registros en el Home.
            _sectionTitle(
              context,
              'Actividad reciente',
              'Accedé a las compras y ventas desde una vista independiente.',
            ),
            const SizedBox(height: 12),
            _ActivityShortcut(
              icon: Icons.history_rounded,
              title: 'Consultar actividad',
              subtitle: 'Compras, ventas, filtros y paginación',
              onTap: widget.onViewActivity,
            ),

            const SizedBox(height: 24),
            _sectionTitle(
              context,
              'Indicadores principales',
              'Datos de los DataMarts de ventas e inventario',
            ),
            const SizedBox(height: 12),
            _buildKpis(context),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onViewMetrics,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Ver todas las métricas'),
              ),
            ),
            const SizedBox(height: 12),
            _refreshInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildKpis(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final cards = <_KpiData>[];

    if (_sales != null) {
      final sales = _sales!;

      cards.addAll([
        _KpiData(
          title: 'Ventas acumuladas',
          value: 'C\$ ${_formatNumber(sales.totalOverallRevenue)}',
          description: 'Ingresos totales del DataMart',
          icon: Icons.point_of_sale_outlined,
          color: AppColors.success,
        ),
        _KpiData(
          title: 'Unidades vendidas',
          value: _formatNumber(sales.totalItemsSold.toDouble(), decimals: 0),
          description: 'Unidades registradas',
          icon: Icons.shopping_bag_outlined,
          color: AppColors.chartBlue,
        ),
      ]);

      final variations = [...sales.salesVariations]
        ..sort((a, b) => a.period.compareTo(b.period));

      if (variations.isNotEmpty) {
        final latest = variations.last;

        cards.add(
          _KpiData(
            title: 'Ventas del último periodo',
            value: 'C\$ ${_formatNumber(latest.currentSales)}',
            description: _formatPeriodLabel(latest.period),
            icon: Icons.calendar_month_outlined,
            color: AppColors.purple,
          ),
        );

        final variation = latest.variationPercentage;

        if (variation != null) {
          cards.add(
            _KpiData(
              title: 'Variación de ventas',
              value:
                  '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(2)}%',
              description: 'Comparación con el periodo anterior',
              icon: variation >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: variation >= 0 ? AppColors.success : AppColors.red,
            ),
          );
        }
      }

      if (sales.grossMargins.isNotEmpty) {
        final totalMargin = sales.grossMargins.fold<double>(
          0,
          (sum, item) => sum + item.grossMargin,
        );

        final margins = [...sales.grossMargins]
          ..sort((a, b) => b.grossMargin.compareTo(a.grossMargin));

        cards.add(
          _KpiData(
            title: 'Margen bruto acumulado',
            value: _formatNumber(totalMargin),
            description: 'Mejor producto: ${margins.first.productName}',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.amber,
          ),
        );
      }
    }

    if (_inventory != null) {
      final inventory = _inventory!;
      final availability = inventory.availability;

      cards.addAll([
        _KpiData(
          title: 'Productos en inventario',
          value: availability.totalProducts.toString(),
          description: 'Productos contemplados por el DataMart',
          icon: Icons.inventory_2_outlined,
          color: AppColors.chartBlue,
        ),
        _KpiData(
          title: 'Disponibilidad de inventario',
          value:
              '${availability.availabilityRatePercentage.toStringAsFixed(2)}%',
          description:
              '${availability.inStockProducts} productos con existencias',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        _KpiData(
          title: 'Stock crítico',
          value: availability.criticalStockProducts.toString(),
          description: 'Productos que requieren revisión',
          icon: Icons.warning_amber_rounded,
          color: AppColors.amber,
        ),
        _KpiData(
          title: 'Productos agotados',
          value: availability.outOfStockProducts.toString(),
          description: 'Productos sin existencias',
          icon: Icons.remove_shopping_cart_outlined,
          color: AppColors.red,
        ),
        _KpiData(
          title: 'Lotes próximos a vencer',
          value: inventory.expiringBatches.length.toString(),
          description: 'Lotes señalados por el DataMart',
          icon: Icons.event_busy_outlined,
          color: AppColors.purple,
        ),
      ]);
    }

    if (cards.isEmpty) {
      return _infoBox(context, _error ?? 'No hay indicadores disponibles.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          _infoBox(context, _error!),
          const SizedBox(height: 10),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: width,
                      child: _KpiCard(data: card),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _refreshInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_outlined, color: AppColors.chartBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Deslizá hacia abajo para actualizar los indicadores.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadKpis,
            tooltip: 'Actualizar indicadores',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _ActivityShortcut extends StatelessWidget {
  const _ActivityShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.chartBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.chartBlue, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _KpiData {
  const _KpiData({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color color;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(data.icon, size: 17, color: data.color),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle_outline,
                size: 15,
                color: AppColors.positiveGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// UTILIDADES PARA RESPUESTAS JSON DE LA API
// -----------------------------------------------------------------------------

String _formatNumber(double value, {int decimals = 2}) {
  final parts = value.toStringAsFixed(decimals).split('.');
  final whole = parts.first;
  final buffer = StringBuffer();

  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(whole[i]);
  }

  if (parts.length > 1) {
    buffer.write('.${parts[1]}');
  }

  return buffer.toString();
}

String _formatPeriodLabel(String period) {
  final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(period);
  if (match == null) return period;

  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  final month = int.tryParse(match.group(2) ?? '');
  if (month == null || month < 1 || month > 12) return period;

  return '${months[month - 1]} ${match.group(1)}';
}

Widget _infoBox(BuildContext context, String message) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Text(
      message,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
