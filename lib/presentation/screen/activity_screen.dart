import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/network/api_client.dart';
import '../theme/app_colors.dart';

enum ActivityType {
  purchases('Compras'),
  sales('Ventas');

  const ActivityType(this.label);

  final String label;
}

enum ActivityPeriod {
  lastHour('Última hora', Duration(hours: 1)),
  last24Hours('Últimas 24 horas', Duration(hours: 24)),
  last7Days('Últimos 7 días', Duration(days: 7)),
  last30Days('Últimos 30 días', Duration(days: 30)),
  all('Todo el historial', null);

  const ActivityPeriod(this.label, this.duration);

  final String label;
  final Duration? duration;
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const int _pageSize = 15;

  late final ApiClient _api;

  ActivityType _type = ActivityType.purchases;
  ActivityPeriod _period = ActivityPeriod.last30Days;

  int _page = 1;
  int? _totalPages;
  int? _totalItems;

  List<Map<String, dynamic>> _records = [];

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = getIt<ApiClient>();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final duration = _period.duration;

      final query = <String, String>{
        if (_type == ActivityType.purchases) ...{
          'page': '$_page',
          'limit': '$_pageSize',
        } else ...{
          'pageNumber': '$_page',
          'pageSize': '$_pageSize',
        },
        if (duration != null)
          'startDate': now.subtract(duration).toUtc().toIso8601String(),
        if (duration != null) 'endDate': now.toUtc().toIso8601String(),
      };

      final response = await _api.get(
        _type == ActivityType.purchases ? '/api/Purchase/paged' : '/api/Sales',
        query: query,
      );

      final records = _extractRecords(response);
      final metadata = _findMetadata(response);

      final totalPages = _readInt(metadata, const [
        'totalPages',
        'pageCount',
        'totalPageCount',
      ]);

      final totalItems = _readInt(metadata, const [
        'totalItems',
        'totalRecords',
        'totalCount',
        'total',
      ]);

      if (!mounted) return;

      setState(() {
        _records = records;
        _totalPages = totalPages;
        _totalItems = totalItems;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _records = [];
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _changeType(ActivityType type) async {
    if (_type == type) return;

    setState(() {
      _type = type;
      _page = 1;
      _totalPages = null;
      _totalItems = null;
    });

    await _loadPage();
  }

  Future<void> _changePeriod(ActivityPeriod period) async {
    if (_period == period) return;

    setState(() {
      _period = period;
      _page = 1;
      _totalPages = null;
      _totalItems = null;
    });

    await _loadPage();
  }

  Future<void> _previousPage() async {
    if (_loading || _page <= 1) return;

    setState(() => _page--);
    await _loadPage();
  }

  Future<void> _nextPage() async {
    if (_loading) return;

    if (_totalPages != null && _page >= _totalPages!) return;

    if (_totalPages == null && _records.length < _pageSize) return;

    setState(() => _page++);
    await _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canGoNext =
        !_loading &&
        (_totalPages != null
            ? _page < _totalPages!
            : _records.length >= _pageSize);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Actividad',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadPage,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compras y ventas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Consultá los movimientos por periodo y página.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<ActivityType>(
                    segments: ActivityType.values.map((type) {
                      return ButtonSegment<ActivityType>(
                        value: type,
                        label: Text(type.label),
                        icon: Icon(
                          type == ActivityType.purchases
                              ? Icons.shopping_cart_outlined
                              : Icons.point_of_sale_outlined,
                        ),
                      );
                    }).toList(),
                    selected: {_type},
                    onSelectionChanged: (selection) {
                      _changeType(selection.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ActivityPeriod>(
                    initialValue: _period,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Periodo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range_outlined),
                    ),
                    items: ActivityPeriod.values.map((period) {
                      return DropdownMenuItem<ActivityPeriod>(
                        value: period,
                        child: Text(period.label),
                      );
                    }).toList(),
                    onChanged: (period) {
                      if (period != null) _changePeriod(period);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _totalItems == null
                              ? 'Página $_page'
                              : '$_totalItems registros',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _totalPages == null
                            ? '$_page / …'
                            : '$_page / $_totalPages',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildContent(context)),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _page > 1 && !_loading ? _previousPage : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canGoNext ? _nextPage : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Siguiente'),
                      iconAlignment: IconAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading && _records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 42),
              const SizedBox(height: 12),
              Text(
                'No se pudo cargar la actividad',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPage,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 42),
              const SizedBox(height: 12),
              const Text('No hay registros para mostrar.'),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadPage,
                icon: const Icon(Icons.refresh),
                label: const Text('Volver a intentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _records.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _ActivityRecordCard(record: _records[index], type: _type);
          },
        ),
        if (_loading)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

class _ActivityRecordCard extends StatelessWidget {
  const _ActivityRecordCard({required this.record, required this.type});

  final Map<String, dynamic> record;
  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPurchase = type == ActivityType.purchases;

    final id = _readString(record, const [
      'id',
      'purchaseId',
      'saleId',
      'purchaseNum',
      'saleNum',
      'invoiceNumber',
      'transactionId',
    ]);

    final person = _readString(
      record,
      isPurchase
          ? const ['supplierName', 'supplier', 'providerName', 'supplierId']
          : const ['clientName', 'customerName', 'client', 'customer'],
    );

    final date = _readString(record, const [
      'purchaseDate',
      'saleDate',
      'createdAt',
      'createdDate',
      'createdOn',
      'registeredDate',
      'registeredAt',
      'transactionDate',
      'transactionDateTime',
      'saleDateTime',
      'purchaseDateTime',
      'date',
      'fecha',
      'fechaCompra',
      'fechaVenta',
      'timestamp',
    ]);

    final total = _readDouble(record, const [
      'total',
      'totalAmount',
      'totalPrice',
      'totalPurchase',
      'totalSale',
      'grandTotal',
      'amount',
    ]);

    final color = isPurchase ? AppColors.purple : AppColors.success;
    final icon = isPurchase
        ? Icons.shopping_cart_outlined
        : Icons.point_of_sale_outlined;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isPurchase ? 'Compra' : 'Venta'}${id == null ? '' : ' #$id'}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  person ?? 'Nombre no disponible',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (total != null) ...[
            const SizedBox(width: 8),
            Text(
              'C\$ ${total.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _extractRecords(dynamic response) {
  if (response is List) {
    return response.whereType<Map>().map(_asMap).toList();
  }

  final map = _asMap(response);

  for (final key in const [
    'items',
    'data',
    'results',
    'records',
    'purchases',
    'sales',
  ]) {
    final value = _readValue(map, key);

    if (value is List) {
      return value.whereType<Map>().map(_asMap).toList();
    }

    if (value is Map) {
      final nested = _extractRecords(value);
      if (nested.isNotEmpty) return nested;
    }
  }

  return [];
}

Map<String, dynamic> _findMetadata(dynamic response) {
  if (response is! Map) return {};

  final map = _asMap(response);

  for (final key in const ['meta', 'metadata', 'pagination', 'pageInfo']) {
    final value = _readValue(map, key);
    if (value is Map) return _asMap(value);
  }

  for (final value in map.values) {
    if (value is Map) {
      final nested = _findMetadata(value);
      if (nested.isNotEmpty) return nested;
    }
  }

  return {};
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;

  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  return {};
}

dynamic _readValue(Map<String, dynamic> map, String key) {
  for (final entry in map.entries) {
    if (entry.key.toLowerCase() == key.toLowerCase()) {
      return entry.value;
    }
  }

  return null;
}

String? _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _readValue(map, key);

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  return null;
}

double? _readDouble(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _readValue(map, key);

    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }

  return null;
}

int? _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _readValue(map, key);

    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }

  return null;
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/${date.year} $hour:$minute';
}
