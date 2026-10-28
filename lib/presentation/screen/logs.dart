
import 'package:flutter/material.dart';

import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/data/models/system_log_model.dart';
import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';

import '../settings/app_preferences.dart';
import '../theme/app_colors.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final LogController _logController;

  bool get _isEnglish =>
      AppPreferences.locale.value.languageCode == 'en';

  String _t(String es, String en) => _isEnglish ? en : es;

  @override
  void initState() {
    super.initState();
    _logController = getIt<LogController>();
    _logController.addListener(_onControllerUpdate);
    _logController.fetchLogs();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearchBar(context),
              const SizedBox(height: 16),
              _buildFilters(context),
              const SizedBox(height: 16),
              Expanded(child: _buildLogList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            _t('Logs del sistema', 'System logs'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
        IconButton(
          tooltip: _t('Recargar logs', 'Refresh logs'),
          icon: const Icon(
            Icons.refresh,
            color: AppColors.primary,
          ),
          onPressed: () => _logController.fetchLogs(refresh: true),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TextField(
      controller: _searchController,
      onChanged: _handleSearchChanged,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: _t(
          'Buscar por ID, ruta, IP, usuario o mensaje...',
          'Search by ID, path, IP, user or message...',
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 13.5,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: scheme.onSurfaceVariant,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                tooltip: _t('Limpiar búsqueda', 'Clear search'),
                icon: Icon(
                  Icons.clear,
                  color: scheme.onSurfaceVariant,
                  size: 18,
                ),
                onPressed: () {
                  _searchController.clear();
                  _handleSearchChanged('');
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            'ALL',
            null,
            _logController.allLogs.length.toString(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'ERROR',
            AppColors.red,
            _logController.errorCount.toString(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'WARN',
            AppColors.warning,
            _logController.warningCount.toString(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'INFO',
            AppColors.primary,
            _logController.infoCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    Color? dotColor,
    String count,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = _logController.selectedFilter == label;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: () => _handleFilterTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.22 : 0.10,
                  )
                : scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : theme.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Icon(Icons.circle, size: 8, color: dotColor),
                const SizedBox(width: 6),
              ],
              Text(
                label == 'ALL' ? _t('TODOS', 'ALL') : label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : scheme.onSurface,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                count,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : scheme.onSurfaceVariant,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogList(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (_logController.status == LogStatus.loading &&
        _logController.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              _t(
                'Cargando logs desde la API...',
                'Loading logs from the API...',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (_logController.status == LogStatus.error &&
        _logController.logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: scheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _logController.errorMessage ??
                    _t(
                      'Error al consultar logs.',
                      'Error retrieving logs.',
                    ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    _logController.fetchLogs(refresh: true),
                icon: const Icon(Icons.refresh),
                label: Text(_t('Reintentar', 'Retry')),
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
          children: [
            const SizedBox(height: 100),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _t(
                    'No hay logs registrados con el filtro actual.',
                    'There are no logs for the current filter.',
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
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

class LogCard extends StatelessWidget {
  final SystemLogModel log;

  const LogCard({super.key, required this.log});

  bool get _isEnglish =>
      AppPreferences.locale.value.languageCode == 'en';

  String _t(String es, String en) => _isEnglish ? en : es;

  String _normalizedLevel() {
    final level = (log.level ?? '').toUpperCase();

    if (level.contains('ERROR')) return 'ERROR';
    if (level.contains('WARN')) return 'WARN';
    return 'INFO';
  }

  Color _getBadgeBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_normalizedLevel()) {
      case 'ERROR':
        return AppColors.red.withValues(alpha: isDark ? 0.20 : 0.12);
      case 'WARN':
        return AppColors.warning.withValues(alpha: isDark ? 0.20 : 0.12);
      default:
        return AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.10);
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/D';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute:$second';
  }

  void _showDetailsModal(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final modalTheme = Theme.of(context);
            final modalScheme = modalTheme.colorScheme;

            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_t('Detalles del log', 'Log details')}: '
                          '${log.id ?? log.traceId ?? "N/D"}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: modalTheme.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: modalScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: _t('Cerrar', 'Close'),
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: modalTheme.dividerColor),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    _t('Nivel', 'Level'),
                    _normalizedLevel(),
                    _getBadgeTextColor(),
                  ),
                  _buildDetailRow(
                    context,
                    _t('Fecha', 'Date'),
                    _formatDate(log.timestamp),
                    modalScheme.onSurface,
                  ),
                  _buildDetailRow(
                    context,
                    _t('Entorno', 'Environment'),
                    log.environment ?? 'N/D',
                    modalScheme.onSurface,
                  ),
                  _buildDetailRow(
                    context,
                    _t('Usuario', 'User'),
                    log.userId ?? _t('Anónimo', 'Anonymous'),
                    modalScheme.onSurface,
                  ),
                  _buildDetailRow(
                    context,
                    _t('IP del cliente', 'Client IP'),
                    log.clientIp ?? '::1',
                    modalScheme.onSurface,
                  ),
                  _buildDetailRow(
                    context,
                    'Trace ID',
                    log.traceId ?? 'N/D',
                    modalScheme.onSurfaceVariant,
                  ),
                  if (log.request != null) ...[
                    _buildDetailRow(
                      context,
                      _t('Método', 'Method'),
                      log.request!.method ?? 'N/D',
                      AppColors.primary,
                    ),
                    _buildDetailRow(
                      context,
                      _t('Ruta', 'Path'),
                      log.request!.path ?? 'N/D',
                      modalScheme.onSurface,
                    ),
                    if (log.request!.queryString != null &&
                        log.request!.queryString!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Query',
                        log.request!.queryString!,
                        modalScheme.onSurfaceVariant,
                      ),
                    if (log.request!.payload != null &&
                        log.request!.payload!.isNotEmpty)
                      _buildDetailRow(
                        context,
                        'Payload',
                        log.request!.payload!,
                        modalScheme.onSurfaceVariant,
                      ),
                  ],
                  if (log.response != null)
                    _buildDetailRow(
                      context,
                      _t('Código HTTP', 'HTTP status'),
                      '${log.response!.statusCode ?? "N/D"} '
                      '(${log.response!.elapsedMilliseconds ?? 0} ms)',
                      (log.response!.statusCode ?? 200) >= 400
                          ? scheme.error
                          : AppColors.primary,
                    ),
                  if (log.exception != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _t('Excepción técnica:', 'Technical exception:'),
                      style: modalTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: modalScheme.error,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: modalScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: modalScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (log.exception!.message != null)
                            Text(
                              '${_t('Mensaje', 'Message')}: '
                              '${log.exception!.message}',
                              style: TextStyle(
                                color: modalScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (log.exception!.source != null &&
                              log.exception!.source!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${_t('Origen', 'Source')}: '
                              '${log.exception!.source}',
                              style: TextStyle(
                                color: modalScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (log.exception!.stackTrace != null &&
                              log.exception!.stackTrace!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            SelectableText(
                              'StackTrace:\n${log.exception!.stackTrace}',
                              style: TextStyle(
                                color: modalScheme.onErrorContainer,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    _t('Información del log:', 'Log information:'),
                    style: modalTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: modalScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: modalScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: modalTheme.dividerColor,
                      ),
                    ),
                    child: SelectableText(
                      log.displayMessage,
                      style: TextStyle(color: modalScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final shortId = (log.id != null && log.id!.length > 10)
        ? log.id!.substring(0, 10)
        : (log.id ?? log.traceId ?? 'LOG');

    final path = log.request?.path ?? 'Sistema';
    final user = log.userId ?? _t('Anónimo', 'Anonymous');
    final code = log.response?.statusCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getBadgeBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _normalizedLevel(),
                        style: TextStyle(
                          color: _getBadgeTextColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      shortId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (code != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: code >= 400
                              ? scheme.errorContainer
                              : AppColors.primary.withValues(
                                  alpha: theme.brightness == Brightness.dark
                                      ? 0.20
                                      : 0.10,
                                ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          code.toString(),
                          style: TextStyle(
                            color: code >= 400
                                ? scheme.onErrorContainer
                                : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _t('Ver detalles', 'View details'),
                onPressed: () => _showDetailsModal(context),
                icon: Icon(
                  Icons.open_in_new,
                  size: 20,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            log.displayMessage,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildChip(context, path),
              _buildChip(context, user),
              Text(
                _formatDate(log.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
