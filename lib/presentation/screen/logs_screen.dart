import 'package:flutter/material.dart';

import 'package:farma_di_mobile/core/di/injection.dart';

import 'package:farma_di_mobile/data/models/system_log_model.dart';

import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';

import '../theme/app_colors.dart';

// PANTALLA PRINCIPAL

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final LogController _logController;

  @override
  void initState() {
    super.initState();

    _logController = getIt<LogController>();

    _logController.addListener(_onControllerUpdate);

    _logController.fetchLogs();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _logController.removeListener(_onControllerUpdate);

    _searchController.dispose();

    _logController.dispose();

    super.dispose();
  }

  void _handleFilterTap(String filter) {
    _logController.setFilter(filter);
  }

  void _handleSearchChanged(String query) {
    _logController.setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 24.0),

              _buildHeader(),

              const SizedBox(height: 16.0),

              _buildSearchBar(),

              const SizedBox(height: 16.0),

              _buildFilters(),

              const SizedBox(height: 16.0),

              Expanded(child: _buildLogList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        const Text(
          'Logs del sistema',

          style: TextStyle(
            fontSize: 24.0,

            fontWeight: FontWeight.bold,

            color: AppColors.ink,
          ),
        ),

        IconButton(
          tooltip: 'Recargar logs',

          icon: const Icon(Icons.refresh, color: AppColors.primary),

          onPressed: () => _logController.fetchLogs(refresh: true),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,

      onChanged: _handleSearchChanged,

      decoration: InputDecoration(
        hintText: 'Buscar por ID, ruta, IP, usuario o mensaje...',

        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13.5),

        prefixIcon: const Icon(Icons.search, color: AppColors.hint),

        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.hint, size: 18),

                onPressed: () {
                  _searchController.clear();

                  _handleSearchChanged('');
                },
              )
            : null,

        filled: true,

        fillColor: AppColors.surface,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 12.0,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),

          borderSide: const BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),

          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),

          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        children: [
          _buildFilterChip(
            'ALL',
            null,
            _logController.allLogs.length.toString(),
          ),

          const SizedBox(width: 8.0),

          _buildFilterChip(
            'ERROR',

            AppColors.red,

            _logController.errorCount.toString(),
          ),

          const SizedBox(width: 8.0),

          _buildFilterChip(
            'WARN',

            AppColors.warning,

            _logController.warningCount.toString(),
          ),

          const SizedBox(width: 8.0),

          _buildFilterChip(
            'INFO',

            AppColors.primary,

            _logController.infoCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color? dotColor, String count) {
    final bool isSelected = _logController.selectedFilter == label;

    return GestureDetector(
      onTap: () => _handleFilterTap(label),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,

          borderRadius: BorderRadius.circular(20.0),

          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),

        child: Row(
          children: [
            if (dotColor != null) ...[
              Icon(Icons.circle, size: 8.0, color: dotColor),

              const SizedBox(width: 6.0),
            ],

            Text(
              label,

              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,

                fontSize: 13.0,
              ),
            ),

            const SizedBox(width: 6.0),

            Text(
              count,

              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,

                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogList() {
    if (_logController.status == LogStatus.loading &&
        _logController.logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircularProgressIndicator(color: AppColors.primary),

            SizedBox(height: 12),

            Text(
              'Cargando logs desde la API...',

              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_logController.status == LogStatus.error &&
        _logController.logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),

              const SizedBox(height: 12),

              Text(
                _logController.errorMessage ?? 'Error al consultar logs.',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () => _logController.fetchLogs(refresh: true),

                icon: const Icon(Icons.refresh),

                label: const Text('Reintentar'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,

                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_logController.logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _logController.fetchLogs(refresh: true),

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          children: const [
            SizedBox(height: 100),

            Center(
              child: Text(
                'No hay logs registrados con el filtro actual.',

                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _logController.fetchLogs(refresh: true),

      color: AppColors.primary,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        itemCount: _logController.logs.length,

        itemBuilder: (context, index) {
          return LogCard(log: _logController.logs[index]);
        },
      ),
    );
  }
}

/// WIDGET REUTILIZABLE PARA TARJETA DE LOG

class LogCard extends StatelessWidget {
  final SystemLogModel log;

  const LogCard({super.key, required this.log});

  String _normalizedLevel() {
    final lvl = (log.level ?? '').toUpperCase();

    if (lvl.contains('ERROR')) return 'ERROR';

    if (lvl.contains('WARN')) return 'WARN';

    return 'INFO';
  }

  Color _getBadgeBackgroundColor() {
    switch (_normalizedLevel()) {
      case 'ERROR':
        return AppColors.redSoft;

      case 'WARN':
        return AppColors.warningSoft;

      default:
        return AppColors.primarySoft;
    }
  }

  Color _getBadgeTextColor() {
    switch (_normalizedLevel()) {
      case 'ERROR':
        return AppColors.red;

      case 'WARN':
        return AppColors.warning;

      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/D';

    final y = dt.year.toString();

    final m = dt.month.toString().padLeft(2, '0');

    final d = dt.day.toString().padLeft(2, '0');

    final h = dt.hour.toString().padLeft(2, '0');

    final min = dt.minute.toString().padLeft(2, '0');

    final s = dt.second.toString().padLeft(2, '0');

    return '$y-$m-$d $h:$min:$s';
  }

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: AppColors.surface,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),

      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,

          minChildSize: 0.4,

          maxChildSize: 0.95,

          expand: false,

          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,

              padding: const EdgeInsets.all(24.0),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Expanded(
                        child: Text(
                          'Detalles del Log: ${log.id ?? log.traceId ?? "N/D"}',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 17.0,

                            fontWeight: FontWeight.bold,

                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),

                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const Divider(color: AppColors.border),

                  const SizedBox(height: 12.0),

                  _buildDetailRow(
                    'Nivel',
                    _normalizedLevel(),
                    _getBadgeTextColor(),
                  ),

                  _buildDetailRow(
                    'Fecha',
                    _formatDate(log.timestamp),
                    AppColors.textPrimary,
                  ),

                  _buildDetailRow(
                    'Entorno',
                    log.environment ?? 'N/D',
                    AppColors.textPrimary,
                  ),

                  _buildDetailRow(
                    'Usuario',
                    log.userId ?? 'Anónimo',
                    AppColors.textPrimary,
                  ),

                  _buildDetailRow(
                    'IP Cliente',
                    log.clientIp ?? '::1',
                    AppColors.textPrimary,
                  ),

                  _buildDetailRow(
                    'Trace ID',
                    log.traceId ?? 'N/D',
                    AppColors.textSecondary,
                  ),

                  if (log.request != null) ...[
                    _buildDetailRow(
                      'Método',
                      log.request!.method ?? 'N/D',
                      AppColors.primary,
                    ),

                    _buildDetailRow(
                      'Ruta',
                      log.request!.path ?? 'N/D',
                      AppColors.textPrimary,
                    ),

                    if (log.request!.queryString != null &&
                        log.request!.queryString!.isNotEmpty)
                      _buildDetailRow(
                        'Query',
                        log.request!.queryString!,
                        AppColors.textSecondary,
                      ),

                    if (log.request!.payload != null &&
                        log.request!.payload!.isNotEmpty)
                      _buildDetailRow(
                        'Payload',
                        log.request!.payload!,
                        AppColors.textSecondary,
                      ),
                  ],

                  if (log.response != null) ...[
                    _buildDetailRow(
                      'Código HTTP',

                      '${log.response!.statusCode ?? "N/D"} (${log.response!.elapsedMilliseconds ?? 0} ms)',

                      (log.response!.statusCode ?? 200) >= 400
                          ? AppColors.red
                          : AppColors.primary,
                    ),
                  ],

                  if (log.exception != null) ...[
                    const SizedBox(height: 12.0),

                    const Text(
                      'Excepción técnica:',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,

                        color: AppColors.red,
                      ),
                    ),

                    const SizedBox(height: 6.0),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(12.0),

                      decoration: BoxDecoration(
                        color: AppColors.redSoft,

                        borderRadius: BorderRadius.circular(8.0),

                        border: Border.all(
                          color: AppColors.red.withValues(alpha: 0.3),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          if (log.exception!.message != null)
                            Text(
                              'Mensaje: ${log.exception!.message}',

                              style: const TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          if (log.exception!.source != null &&
                              log.exception!.source!.isNotEmpty) ...[
                            const SizedBox(height: 4),

                            Text(
                              'Origen: ${log.exception!.source}',

                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          if (log.exception!.stackTrace != null &&
                              log.exception!.stackTrace!.isNotEmpty) ...[
                            const SizedBox(height: 6),

                            Text(
                              'StackTrace:\n${log.exception!.stackTrace}',

                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16.0),

                  const Text(
                    'Información del log:',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(12.0),

                    decoration: BoxDecoration(
                      color: AppColors.background,

                      borderRadius: BorderRadius.circular(8.0),

                      border: Border.all(color: AppColors.border),
                    ),

                    child: Text(
                      log.displayMessage,

                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),

                  const SizedBox(height: 24.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 95.0,

            child: Text(
              label,

              style: const TextStyle(
                color: AppColors.textSecondary,

                fontWeight: FontWeight.w600,

                fontSize: 13.0,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w500,
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortId = (log.id != null && log.id!.length > 10)
        ? log.id!.substring(0, 10)
        : (log.id ?? log.traceId ?? 'LOG');

    final path = log.request?.path ?? 'Sistema';

    final user = log.userId ?? 'Anónimo';

    final code = log.response?.statusCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),

      padding: const EdgeInsets.all(16.0),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(16.0),

        border: Border.all(color: AppColors.border, width: 1),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,

                      vertical: 4.0,
                    ),

                    decoration: BoxDecoration(
                      color: _getBadgeBackgroundColor(),

                      borderRadius: BorderRadius.circular(12.0),
                    ),

                    child: Text(
                      _normalizedLevel(),

                      style: TextStyle(
                        color: _getBadgeTextColor(),

                        fontWeight: FontWeight.bold,

                        fontSize: 12.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8.0),

                  Text(
                    shortId,

                    style: const TextStyle(
                      color: AppColors.textSecondary,

                      fontWeight: FontWeight.w500,

                      fontSize: 13.0,
                    ),
                  ),

                  if (code != null) ...[
                    const SizedBox(width: 8.0),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),

                      decoration: BoxDecoration(
                        color: code >= 400
                            ? AppColors.redSoft
                            : AppColors.primarySoft,

                        borderRadius: BorderRadius.circular(6.0),
                      ),

                      child: Text(
                        code.toString(),

                        style: TextStyle(
                          color: code >= 400
                              ? AppColors.red
                              : AppColors.primary,

                          fontWeight: FontWeight.bold,

                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              InkWell(
                onTap: () => _showDetailsModal(context),

                borderRadius: BorderRadius.circular(8.0),

                child: const Padding(
                  padding: EdgeInsets.all(4.0),

                  child: Icon(
                    Icons.open_in_new,

                    size: 20.0,

                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          Text(
            log.displayMessage,

            maxLines: 2,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: AppColors.ink,

              fontSize: 14.0,

              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10.0),

          Row(
            children: [
              _buildChip(path),

              const SizedBox(width: 8.0),

              _buildChip(user),

              const Spacer(),

              Text(
                _formatDate(log.timestamp),

                style: const TextStyle(
                  color: AppColors.textMuted,

                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),

      decoration: BoxDecoration(
        color: AppColors.background,

        borderRadius: BorderRadius.circular(6.0),
      ),

      child: Text(
        text,

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

        style: const TextStyle(
          color: AppColors.textSecondary,

          fontSize: 11.5,

          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
