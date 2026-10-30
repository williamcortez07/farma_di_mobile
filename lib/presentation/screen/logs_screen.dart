import 'package:flutter/material.dart';
import 'package:farma_di_mobile/core/di/injection.dart';
import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';
import 'package:farma_di_mobile/presentation/theme/app_colors.dart';
import 'package:farma_di_mobile/presentation/widgets/logs/log_card.dart';
import 'package:farma_di_mobile/presentation/widgets/logs/log_filter_bar.dart';
import 'package:farma_di_mobile/presentation/widgets/logs/log_search_field.dart';
import 'package:farma_di_mobile/presentation/widgets/logs/log_states.dart';

export 'package:farma_di_mobile/presentation/widgets/logs/log_card.dart';

/// Pantalla principal para la visualización y gestión de Logs del sistema
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final LogController _logController;

  @override
  void initState() {
    super.initState();
    _logController = getIt<LogController>();
    _logController.addListener(_onControllerUpdate);
    _logController.attachScrollController(_scrollController);

    // Carga inicial de los registros del día actual
    _logController.init();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _logController.removeListener(_onControllerUpdate);
    _scrollController.dispose();
    _searchController.dispose();
    _logController.dispose();
    super.dispose();
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
              const SizedBox(height: 20.0),
              _buildHeader(),
              const SizedBox(height: 16.0),
              LogSearchField(
                controller: _searchController,
                onChanged: _logController.setSearchQuery,
                onClear: _logController.clearSearch,
              ),
              const SizedBox(height: 16.0),
              LogFilterBar(
                selectedCategory: _logController.selectedCategory,
                onCategorySelected: _logController.selectCategory,
                totalCount: _logController.allLogs.length,
                errorCount: _logController.errorCount,
                warningCount: _logController.warningCount,
                infoCount: _logController.infoCount,
              ),
              const SizedBox(height: 16.0),
              Expanded(child: _buildLogContent()),
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
          onPressed: () => _logController.refresh(),
        ),
      ],
    );
  }

  Widget _buildLogContent() {
    // 1. Estado de carga inicial
    if (_logController.isLoading && _logController.visibleLogs.isEmpty) {
      return const LogLoadingView();
    }

    // 2. Estado de error
    if (_logController.status == LogStatus.error && _logController.visibleLogs.isEmpty) {
      return LogErrorView(
        errorMessage: _logController.errorMessage,
        onRetry: () => _logController.refresh(),
      );
    }

    // 3. Estado sin registros
    if (_logController.visibleLogs.isEmpty) {
      return LogEmptyView(
        onRefresh: () => _logController.refresh(),
      );
    }

    // 4. Datos disponibles con soporte para paginación continua y pull-to-refresh
    final logs = _logController.visibleLogs;
    final hasLoader = _logController.isLoadingMore;

    return RefreshIndicator(
      onRefresh: () => _logController.refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: logs.length + (hasLoader ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == logs.length) {
            return const LogPaginationLoader();
          }
          return LogCard(log: logs[index]);
        },
      ),
    );
  }
}
