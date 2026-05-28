import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';
import '../../models/mood_day_data.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class EmotionalWellbeingScreen extends StatefulWidget {
  const EmotionalWellbeingScreen({super.key});

  @override
  State<EmotionalWellbeingScreen> createState() =>
      _EmotionalWellbeingScreenState();
}

class _EmotionalWellbeingScreenState extends State<EmotionalWellbeingScreen> {
  List<MoodDayData> _mood = [];
  List<EmotionalBalanceDay> _balance = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = authService.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final mood = await firestoreService.getMoodChartData(user.uid, days: 7);
    final balance =
        await firestoreService.getEmotionalBalanceData(user.uid, days: 7);
    if (mounted) {
      setState(() {
        _mood = mood;
        _balance = balance;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Emotional Wellbeing'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: HubColors.accent),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Mood trends (7 days)',
                    style: TextStyle(
                      color: HubColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: _mood.isEmpty
                        ? const Center(
                            child: Text(
                              'Chat with Detea to build mood data.',
                              style: TextStyle(color: HubColors.textSecondary),
                            ),
                          )
                        : LineChart(_buildChartData()),
                  ),
                  const SizedBox(height: 28),
                  if (_mood.isNotEmpty) ...[
                    _metricCard(
                      'Happiness',
                      _avg(_mood.map((m) => m.happiness)),
                      HubColors.accent,
                    ),
                    _metricCard(
                      'Anxiety',
                      _avg(_mood.map((m) => m.anxiety)),
                      Colors.orange,
                    ),
                    _metricCard(
                      'Stress',
                      _avg(_mood.map((m) => m.stress)),
                      Colors.redAccent,
                    ),
                    _metricCard(
                      'Energy',
                      _avg(_mood.map((m) => m.energy)),
                      Colors.greenAccent,
                    ),
                  ],
                  if (_balance.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Emotional balance',
                      style: TextStyle(
                        color: HubColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._balance.map(
                      (b) => ListTile(
                        title: Text(
                          b.dayLabel,
                          style: const TextStyle(color: HubColors.text),
                        ),
                        subtitle: Text(
                          '+${b.positive.toInt()} / -${b.negative.toInt()} / ~${b.neutral.toInt()}',
                          style: const TextStyle(color: HubColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: const TextStyle(color: HubColors.textSecondary, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= _mood.length) return const Text('');
              return Text(
                _mood[i].dayLabel,
                style: const TextStyle(color: HubColors.textSecondary, fontSize: 9),
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
          spots: [
            for (var i = 0; i < _mood.length; i++)
              FlSpot(i.toDouble(), _mood[i].happiness),
          ],
          isCurved: true,
          color: HubColors.accent,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      ],
    );
  }

  double _avg(Iterable<double> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return list.reduce((a, b) => a + b) / list.length / 10;
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
            value: value.clamp(0.0, 1.0),
            backgroundColor: HubColors.divider,
            color: color,
          ),
        ],
      ),
    );
  }
}
