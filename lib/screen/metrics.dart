import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MetricsApp());
}

class MetricsApp extends StatelessWidget {
  const MetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel general',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFFFFFFC),
      ),
      home: const Metrics(),
    );
  }
}

// este fragmento esra de prueba para la poner la fecha en tiempo real
class MetricsPage extends StatelessWidget {
  const MetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel general'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Métricas generales',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            Text(
              'Fecha actual: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// final

class Metrics extends StatelessWidget {
  const Metrics({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fecha actual: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),
              const Text(
                'Metricas y análisis',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildMetricsGrid(),
              const SizedBox(height: 20),
              // _buildChartCard(), // comentado por ahora para compilarción, implementarlo abajo
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMetricsGrid() {
  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 1.5,
    children: const [
      MetricCard(
        value: 'C\$ 365,600',
        title: 'Ingresos totales',
        detail: '+18.3% vs año anterior',
        detailColor: Colors.green,
      ),
      MetricCard(
        value: 'C\$ 176.50',
        title: 'Ticket promedio',
        detail: '+ C\$ 12 vs mes anterior',
        detailColor: Colors.green,
      ),
      MetricCard(
        value: '2,096',
        title: ':::',
        detail: '95 tasa de exito',
        detailColor: Colors.green,
      ),
      MetricCard(
        value: '14',
        title: ' productos pronto a vencer',
        detail: '3 desde el lunes',
        detailColor: Colors.red,
      ),
    ],
  );
}

class MetricCard extends StatelessWidget {
  final String value;
  final String title;
  final String detail;
  final Color detailColor;

  const MetricCard({
    super.key,
    required this.value,
    required this.title,
    required this.detail,
    required this.detailColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text(detail, style: TextStyle(fontSize: 11, color: detailColor)),
        ],
      ),
    );
  }
}
