import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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

// clase original
//....
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
              _buildChartCard(),
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

Widget _buildChartCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ventas vs meta mes actual',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),

        const Text('En cordobas C\$', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        _buildSalesChart(),
      ],
    ),
  );
}

Widget _buildSalesChart() {
  final List<String> months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
  ];

  final List<FlSpot> salesData = const [
    FlSpot(0, 25000),
    FlSpot(1, 26000),
    FlSpot(2, 26500),
    FlSpot(3, 26800),
    FlSpot(4, 25000),
    FlSpot(5, 27000),
    FlSpot(6, 29000),
    FlSpot(7, 30000),
  ];

  final List<FlSpot> golData = const [
    FlSpot(0, 30000),
    FlSpot(1, 32000),
    FlSpot(2, 33000),
    FlSpot(3, 35000),
    FlSpot(4, 36000),
    FlSpot(5, 37000),
    FlSpot(6, 38000),
    FlSpot(7, 39000),
  ];

  return SizedBox(
    height: 220,
    child: LineChart(
      LineChartData(
        minX: 0,
        maxX: 7,
        minY: 0,
        maxY: 39000,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20000,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toInt()}K',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),

          // aqui le pasamos a los indeces inferiores los meses definidos en months
          // enero = 0 -> enero es el indice 0,.. febrero es el indice 1
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= months.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    months[index],
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: salesData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.20),
                  Colors.blue.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          LineChartBarData(
            spots: golData,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    ),
  );
}
