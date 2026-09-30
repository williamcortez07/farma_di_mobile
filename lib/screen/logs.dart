import 'package:flutter/material.dart';
import '../theme/app_colors.dart';


enum LogLevel {
  error,
  warn,
  info,
}

class LogEntry {
  final String id;
  final LogLevel level;
  final String message;
  final String module;
  final String user;
  final String time;

  const LogEntry({
    required this.id,
    required this.level,
    required this.message,
    required this.module,
    required this.user,
    required this.time,
  });
}

/// 2. PANTALLA PRINCIPAL

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  //Controladores indicando el campo que controlan
  final TextEditingController _searchController = TextEditingController();
  
  //Variables privadas para el estado interno
  String _selectedFilter = 'ALL';


  final List<LogEntry> _logs = [
    LogEntry(
      id: 'L-0041',
      level: LogLevel.error,
      message: 'Falló conexión con SQL Server (timeout 30s) en módulo de facturación.',
      module: 'db.connection',
      user: '@sistema',
      time: '2026-10-1',
    ),
    LogEntry(
      id: 'L-0040',
      level: LogLevel.warn,
      message: 'Alerta Farma-Di: Stock bajo detectado para Paracetamol 500mg (5 uds).',
      module: 'inventory',
      user: '@sistema',
      time: '2026-10-1',
    ),
  ]; 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //Métodos relacionado con eventos usando prefijo handle
  void _handleFilterTap(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // Métodos auxiliares para contar logs dinámicamente
  int _getLogCount(LogLevel level) {
    return _logs.where((log) => log.level == level).length;
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
              Expanded(
                child: _buildLogList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Métodos con responsabilidad específica
  Widget _buildHeader() {
    return const Text(
      'Logs del sistema',
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: AppColors.ink,
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar en logs...',
        hintStyle: const TextStyle(color: AppColors.hint),
        prefixIcon: const Icon(Icons.search, color: AppColors.hint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
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
          _buildFilterChip('ALL', null, null),
          const SizedBox(width: 8.0),
          _buildFilterChip(
              'ERROR', AppColors.red, _getLogCount(LogLevel.error).toString()),
          const SizedBox(width: 8.0),
          _buildFilterChip(
              'WARN', AppColors.warning, _getLogCount(LogLevel.warn).toString()),
          const SizedBox(width: 8.0),
          _buildFilterChip(
              'INFO', AppColors.primary, _getLogCount(LogLevel.info).toString()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color? dotColor, String? count) {
    //Variable booleana prefijada
    final bool isSelected = _selectedFilter == label; 

    return GestureDetector(
      onTap: () => _handleFilterTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? AppColors.primarySoft : AppColors.border,
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
            if (count != null) ...[
              const SizedBox(width: 6.0),
              Text(
                count,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLogList() {
    if (_logs.isEmpty) {
      return const Center(
        child: Text(
          'No hay logs registrados.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        return LogCard(log: _logs[index]);
      },
    );
  }

  
}

/// WIDGETS REUTILIZABLES
class LogCard extends StatelessWidget {
  final LogEntry log;

  const LogCard({
    super.key,
    required this.log,
  });

  Color _getBadgeBackgroundColor() {
    switch (log.level) {
      case LogLevel.error:
        return AppColors.redSoft;
      case LogLevel.warn:
        return AppColors.warningSoft;
      case LogLevel.info:
        return AppColors.primarySoft;
    }
  }

  Color _getBadgeTextColor() {
    switch (log.level) {
      case LogLevel.error:
        return AppColors.red;
      case LogLevel.warn:
        return AppColors.warning;
      case LogLevel.info:
        return AppColors.primary;
    }
  }

  String _getLevelText() {
    switch (log.level) {
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.info:
        return 'INFO';
    }
  }

//Método privado para manejar la vista del modal
  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalles del Log: ${log.id}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16.0),
              _buildDetailRow('Nivel', _getLevelText(), _getBadgeTextColor()),
              _buildDetailRow('Módulo', log.module, AppColors.textPrimary),
              _buildDetailRow('Usuario', log.user, AppColors.textPrimary),
              
              const SizedBox(height: 16.0),
              const Text(
                'Mensaje Completo:',
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
                  log.message,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  // Método auxiliar para construir las filas del modal
  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.0,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _getBadgeBackgroundColor(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      _getLevelText(),
                      style: TextStyle(
                        color: _getBadgeTextColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    log.id,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              // Botón para abrir el modal siguiendo la regla de callbacks
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
          const SizedBox(height: 12.0),
          Text(
            log.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              _buildChip(log.module),
              const SizedBox(width: 8.0),
              _buildChip(log.user),
              const Spacer(),
              
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
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}