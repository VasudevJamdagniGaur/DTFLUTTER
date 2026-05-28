import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';

/// Emotional wellbeing charts — port of `EmotionalWellbeing.js`.
class EmotionalWellbeingScreen extends StatelessWidget {
  const EmotionalWellbeingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Emotional Wellbeing'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Mood trends',
            style: TextStyle(
              color: HubColors.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track happiness, anxiety, stress, and energy over time.',
            style: TextStyle(color: HubColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          color: HubColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) return const Text('');
                        return Text(
                          days[i],
                          style: const TextStyle(
                            color: HubColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 6),
                      FlSpot(1, 5),
                      FlSpot(2, 7),
                      FlSpot(3, 4),
                      FlSpot(4, 8),
                      FlSpot(5, 6),
                      FlSpot(6, 7),
                    ],
                    isCurved: true,
                    color: HubColors.accent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _metricCard('Happiness', 0.72, HubColors.accent),
          _metricCard('Anxiety', 0.35, Colors.orange),
          _metricCard('Stress', 0.41, Colors.redAccent),
          _metricCard('Energy', 0.68, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _metricCard(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HubColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: HubColors.text)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            backgroundColor: HubColors.divider,
            color: color,
          ),
        ],
      ),
    );
  }
}
