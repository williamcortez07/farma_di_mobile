import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/network/api_client.dart';
import '../../data/models/auth_model/user_model.dart';
import '../controllers/inventory_metrics_controller.dart';
import '../controllers/sales_metrics_controller.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_navbar.dart';
import '../widgets/botton_Navigation.dart';
import '../widgets/routes.dart';

import 'catalog_screen.dart';
import 'logs_screen.dart';
import 'metrics_screen.dart';
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
  late final ApiClient _api;
  late final SalesMetricsController _salesController;
  late final InventoryMetricsController _inventoryController;

  List<Map<String, dynamic>> _purchases = [];
  List<Map<String, dynamic>> _sales = [];

  bool _loadingPurchases = true;
  bool _loadingSales = true;
  String? _purchaseError;
  String? _salesError;

  @override
  void initState() {
    super.initState();

    _userProvider = getIt<UserProvider>();
    _api = getIt<ApiClient>();
    _salesController = SalesMetricsController();
    _inventoryController = InventoryMetricsController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider.loadProfile();
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    await Future.wait([
      _loadPurchases(),
      _loadSales(),
      _salesController.loadAll(),
      _inventoryController.loadAll(),
    ]);
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadPurchases(),
      _loadSales(),
      _salesController.refresh(),
      _inventoryController.refresh(),
    ]);
  }

  Future<void> _loadPurchases() async {
    if (!mounted) return;

    setState(() {
      _loadingPurchases = true;
      _purchaseError = null;
    });

    try {
      final response = await _api.get(
        '/api/Purchase/paged',
        query: {'page': '1', 'limit': '10'},
      );

      final records = _extractRecords(response, const [
        'purchases',
        'items',
        'data',
        'results',
        'records',
      ]);

      records.sort((a, b) => _readDate(b).compareTo(_readDate(a)));

      if (!mounted) return;

      setState(() {
        _purchases = records.take(3).toList();
        _loadingPurchases = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _purchaseError = _errorMessage(e);
        _loadingPurchases = false;
      });
    }
  }

  Future<void> _loadSales() async {
    if (!mounted) return;

    setState(() {
      _loadingSales = true;
      _salesError = null;
    });

    try {
      final response = await _api.get(
        '/api/Sales',
        query: {'pageNumber': '1', 'pageSize': '10'},
      );

      final records = _extractRecords(response, const [
        'sales',
        'items',
        'data',
        'results',
        'records',
      ]);

      records.sort((a, b) => _readDate(b).compareTo(_readDate(a)));

      if (!mounted) return;

      setState(() {
        _sales = records.take(3).toList();
        _loadingSales = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _salesError = _errorMessage(e);
        _loadingSales = false;
      });
    }
  }

  @override
  void dispose() {
    _salesController.dispose();
    _inventoryController.dispose();
    super.dispose();
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
            purchases: _purchases,
            sales: _sales,
            salesController: _salesController,
            inventoryController: _inventoryController,
            loadingPurchases: _loadingPurchases,
            loadingSales: _loadingSales,
            purchaseError: _purchaseError,
            salesError: _salesError,
            onRefresh: _refreshDashboard,
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

// ============================================================
// HOME OVERVIEW
// ============================================================

class _HomeOverview extends StatelessWidget {
  const _HomeOverview({
    required this.user,
    required this.purchases,
    required this.sales,
    required this.salesController,
    required this.inventoryController,
    required this.loadingPurchases,
    required this.loadingSales,
    required this.purchaseError,
    required this.salesError,
    required this.onRefresh,
    required this.onViewMetrics,
  });

  final UserModel? user;
  final List<Map<String, dynamic>> purchases;
  final List<Map<String, dynamic>> sales;

  final SalesMetricsController salesController;
  final InventoryMetricsController inventoryController;

  final bool loadingPurchases;
  final bool loadingSales;
  final String? purchaseError;
  final String? salesError;

  final Future<void> Function() onRefresh;
  final VoidCallback onViewMetrics;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: salesController,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: inventoryController,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              color: AppColors.chartBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 22),
                    _sectionTitle(context, 
                      'Actividad reciente',
                      'Últimas compras y ventas registradas',
                    ),
                    const SizedBox(height: 12),
                    _buildMovements(),
                    const SizedBox(height: 24),
                    _sectionTitle(context, 
                      'Indicadores principales',
                      'Valores disponibles y métricas pendientes',
                    ),
                    const SizedBox(height: 12),
                    _buildAllKpis(context),
                    const SizedBox(height: 22),
                    _buildMetricsButton(context),
                    const SizedBox(height: 16),
                    _buildRefreshInformation(context),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
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
          user != null
              ? 'Bienvenido, ${user!.fullName}'
              : 'Resumen de actividad de Farma-DI',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildMovements() {
    return Column(
      children: [
        _MovementCard(
          title: 'Compras recientes',
          icon: Icons.shopping_cart_outlined,
          color: AppColors.purple,
          records: purchases,
          isLoading: loadingPurchases,
          error: purchaseError,
          emptyMessage: 'No hay compras registradas.',
          isPurchase: true,
        ),
        const SizedBox(height: 12),
        _MovementCard(
          title: 'Ventas recientes',
          icon: Icons.point_of_sale_outlined,
          color: AppColors.success,
          records: sales,
          isLoading: loadingSales,
          error: salesError,
          emptyMessage: 'No hay ventas registradas.',
          isPurchase: false,
        ),
      ],
    );
  }

  // Todos los KPI se muestran en la misma sección.
  // Se recuperan las métricas mediante los controladores existentes.
  Widget _buildAllKpis(BuildContext context) {
    final cards = <_KpiData>[];

    // Variación de ventas.
    final variations = salesController.salesVariations;

    if (salesController.variationsStatus == SalesKpiStatus.success &&
        variations.isNotEmpty) {
      final item = variations.last;

      cards.add(
        _KpiData(
          title: 'Variación de ventas',
          value: _percentage(item.variationPercentage),
          description: item.period,
          icon: Icons.trending_up,
          color: AppColors.success,
        ),
      );
    } else if (salesController.variationsStatus == SalesKpiStatus.error ||
        salesController.variationsStatus == SalesKpiStatus.success) {
      cards.add(
        _unavailable(
          'Variación de ventas',
          Icons.trending_up,
          AppColors.success,
          salesController.variationsError,
        ),
      );
    }

    // Margen bruto. Se conserva el valor numérico que entrega el modelo.
    final margins = salesController.grossMargins;

    if (salesController.marginsStatus == SalesKpiStatus.success &&
        margins.isNotEmpty) {
      final item = margins.last;

      cards.add(
        _KpiData(
          title: 'Margen bruto',
          value: item.grossMargin.toStringAsFixed(2),
          description: 'Valor reportado por la API',
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.chartBlue,
        ),
      );
    } else if (salesController.marginsStatus == SalesKpiStatus.error ||
        salesController.marginsStatus == SalesKpiStatus.success) {
      cards.add(
        _unavailable(
          'Margen bruto',
          Icons.account_balance_wallet_outlined,
          AppColors.chartBlue,
          salesController.marginsError,
        ),
      );
    }

    // Participación por categoría.
    final shares = salesController.categoryShares;

    if (salesController.sharesStatus == SalesKpiStatus.success &&
        shares.isNotEmpty) {
      cards.add(
        _KpiData(
          title: 'Participación por categoría',
          value: shares.length.toString(),
          suffix: ' categorías',
          description: 'Categorías reportadas por la API',
          icon: Icons.category_outlined,
          color: AppColors.purple,
        ),
      );
    } else if (salesController.sharesStatus == SalesKpiStatus.error ||
        salesController.sharesStatus == SalesKpiStatus.success) {
      cards.add(
        _unavailable(
          'Participación por categoría',
          Icons.category_outlined,
          AppColors.purple,
          salesController.sharesError,
        ),
      );
    }

    // Rotación de inventario.
    final turnovers = inventoryController.turnovers;

    if (inventoryController.turnoverStatus == InventoryKpiStatus.success &&
        turnovers.isNotEmpty) {
      final average =
          turnovers.map((item) => item.turnoverRatio).reduce((a, b) => a + b) /
          turnovers.length;

      cards.add(
        _KpiData(
          title: 'Rotación de inventario',
          value: average.toStringAsFixed(2),
          description: '${turnovers.length} productos analizados',
          icon: Icons.autorenew,
          color: AppColors.amber,
        ),
      );
    } else if (inventoryController.turnoverStatus == InventoryKpiStatus.error) {
      cards.add(
        _unavailable(
          'Rotación de inventario',
          Icons.autorenew,
          AppColors.amber,
          inventoryController.turnoverError,
        ),
      );
    }

    // Lotes próximos a vencer.
    if (inventoryController.expiringStatus == InventoryKpiStatus.success) {
      cards.add(
        _KpiData(
          title: 'Productos próximos a vencer',
          value: inventoryController.expiringBatches.length.toString(),
          suffix: ' lotes',
          description: 'Lotes identificados por el sistema',
          icon: Icons.warning_amber_rounded,
          color: AppColors.red,
        ),
      );
    } else if (inventoryController.expiringStatus == InventoryKpiStatus.error) {
      cards.add(
        _unavailable(
          'Productos próximos a vencer',
          Icons.warning_amber_rounded,
          AppColors.red,
          inventoryController.expiringError,
        ),
      );
    }

    // La API/controlador actual no proporciona un valor confirmado
    // para estos indicadores de compras e inventario.
    cards.add(
      _unavailable(
        'Participación por proveedor',
        Icons.local_shipping_outlined,
        AppColors.purple,
        'Indicador de compras pendiente de integrar',
      ),
    );

    cards.add(
      _unavailable(
        'Variación del gasto en compras',
        Icons.shopping_bag_outlined,
        AppColors.warning,
        'Indicador de compras pendiente de integrar',
      ),
    );

    cards.add(
      _unavailable(
        'Reducción de inventario',
        Icons.inventory_2_outlined,
        AppColors.amber,
        'No hay un valor confirmado para este indicador',
      ),
    );

    if (salesController.isLoading || inventoryController.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (cards.isEmpty) {
      return _emptyInformation(context, 'Todavía no hay indicadores disponibles.');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((card) {
            return SizedBox(
              width: width,
              child: _KpiCard(data: card),
            );
          }).toList(),
        );
      },
    );
  }

  _KpiData _unavailable(
    String title,
    IconData icon,
    Color color,
    String? error,
  ) {
    return _KpiData(
      title: title,
      value: 'No disponible',
      description: error == null || error.trim().isEmpty
          ? 'Sin datos confirmados'
          : 'Error: ${error.replaceFirst('Exception: ', '')}',
      icon: icon,
      color: color,
      available: false,
    );
  }

  Widget _emptyInformation(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildMetricsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onViewMetrics,
        icon: const Icon(Icons.analytics_outlined, size: 19),
        label: Text(
          'Ver todas las métricas',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshInformation(BuildContext context) {
    final loading =
        loadingPurchases ||
        loadingSales ||
        salesController.isLoading ||
        inventoryController.isLoading;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            loading ? Icons.sync : Icons.cloud_done_outlined,
            color: loading ? AppColors.chartBlue : AppColors.positiveGreen,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loading
                  ? 'Consultando información del servidor'
                  : 'Consulta finalizada; revisá los errores de cada indicador',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Actualizar información',
            icon: const Icon(Icons.refresh, color: AppColors.primary, size: 21),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECENT MOVEMENTS
// ============================================================

class _MovementCard extends StatelessWidget {
  const _MovementCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.records,
    required this.isLoading,
    required this.error,
    required this.emptyMessage,
    required this.isPurchase,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> records;
  final bool isLoading;
  final String? error;
  final String emptyMessage;
  final bool isPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                'Últimas 3',
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (error != null)
            _message(context, error!, isError: true)
          else if (records.isEmpty)
            _message(context, emptyMessage)
          else
            ...records.map((record) => _buildRecord(context, record)),
        ],
      ),
    );
  }

  Widget _buildRecord(BuildContext context, Map<String, dynamic> record) {
    final id = _readStringFromMap(record, const ['id', 'purchaseId', 'saleId']);

    final person = _readStringFromMap(
      record,
      isPurchase
          ? const ['supplierName', 'supplier', 'providerName']
          : const ['clientName', 'customerName', 'client'],
    );

    final date = _readStringFromMap(record, const [
      'purchaseDate',
      'saleDate',
      'createdAt',
      'date',
      'transactionDate',
    ]);

    final total = _readNumberFromMap(record, const [
      'total',
      'totalAmount',
      'totalPrice',
      'grandTotal',
      'amount',
    ]);

    final label = isPurchase ? 'Compra' : 'Venta';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id == null ? label : '$label #$id',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  person ?? 'Nombre no disponible',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (date != null)
                  Text(
                    _formatDateString(date),
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (total != null)
            Text(
              total.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }

  Widget _message(BuildContext context, String message, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            size: 16,
            color: isError ? AppColors.warningOrange : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// KPI CARD
// ============================================================

class _KpiData {
  const _KpiData({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
    this.available = true,
    this.suffix = '',
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color color;
  final bool available;
  final String suffix;
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
                data.available
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                size: 15,
                color: data.available
                    ? AppColors.positiveGreen
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value + data.suffix,
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
            style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RESPONSE PARSING HELPERS
// ============================================================

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;

  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  return {};
}

List<Map<String, dynamic>> _extractRecords(
  dynamic response,
  List<String> possibleKeys,
) {
  if (response is List) {
    return response.map(_asMap).toList();
  }

  final map = _asMap(response);

  for (final key in possibleKeys) {
    final value = _readValue(map, key);

    if (value is List) {
      return value.map(_asMap).toList();
    }

    if (value is Map) {
      final nested = _extractRecords(value, possibleKeys);
      if (nested.isNotEmpty) return nested;
    }
  }

  for (final value in map.values) {
    if (value is List) {
      return value.map(_asMap).toList();
    }
  }

  return [];
}

dynamic _readValue(Map<String, dynamic>? map, String key) {
  if (map == null) return null;

  for (final entry in map.entries) {
    if (entry.key.toLowerCase() == key.toLowerCase()) {
      return entry.value;
    }
  }

  return null;
}

String? _readString(Map<String, dynamic>? map, String key) {
  final value = _readValue(map, key);
  if (value == null) return null;

  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}

String? _readStringFromMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _readString(map, key);
    if (value != null) return value;
  }

  return null;
}

double? _readNumber(Map<String, dynamic>? map, String key) {
  final value = _readValue(map, key);

  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);

  return null;
}

double? _readNumberFromMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _readNumber(map, key);
    if (value != null) return value;
  }

  return null;
}

DateTime _readDate(Map<String, dynamic> record) {
  final value = _readStringFromMap(record, const [
    'purchaseDate',
    'saleDate',
    'createdAt',
    'date',
    'transactionDate',
  ]);

  return DateTime.tryParse(value ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _formatDateString(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String _percentage(double? value) {
  if (value == null) return 'No disponible';

  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
}

String _errorMessage(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}
