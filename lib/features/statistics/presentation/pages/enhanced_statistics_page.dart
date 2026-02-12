import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/salawat_counter_provider.dart';
import 'package:alslat_aalnabi/features/statistics/data/models/badge_tier.dart';

class EnhancedStatisticsPage extends StatefulWidget {
  const EnhancedStatisticsPage({super.key});

  @override
  State<EnhancedStatisticsPage> createState() => _EnhancedStatisticsPageState();
}

class _EnhancedStatisticsPageState extends State<EnhancedStatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'أسبوعي', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'شهري', icon: Icon(Icons.calendar_month)),
          ],
        ),
      ),
      body: Consumer<SalawatCounterProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildStatsCards(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeeklyTab(provider),
                    _buildMonthlyTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(SalawatCounterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الإجمالي',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.count}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.today,
                      size: 40,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اليوم',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.getTodayCount()}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(SalawatCounterProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAchievementBadge(provider),
          const SizedBox(height: 24),
          _buildWeeklyChart(provider),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(SalawatCounterProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAchievementBadge(provider),
          const SizedBox(height: 24),
          _buildMonthlyChart(provider),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(SalawatCounterProvider provider) {
    final badge = BadgeTier.getTierForCount(provider.count);

    return Center(
      child: Column(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(SalawatCounterProvider provider) {
    final weeklyData = provider.getWeeklyData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات الأسبوع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(weeklyData),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = [
                            'السبت',
                            'الأحد',
                            'الإثنين',
                            'الثلاثاء',
                            'الأربعاء',
                            'الخميس',
                            'الجمعة',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt() % 7],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(weeklyData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(SalawatCounterProvider provider) {
    final monthlyData = provider.getMonthlyData();
    final values = monthlyData.values.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات الشهر (30 يوم)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt() + 1}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        values.length,
                        (index) =>
                            FlSpot(index.toDouble(), values[index].toDouble()),
                      ),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: _getMaxYFromList(values),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMonthlyStats(values),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(List<int> values) {
    final total = values.reduce((a, b) => a + b);
    final average = values.isEmpty ? 0 : total / values.length;
    final max = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('الإجمالي', total.toString()),
            _buildStatItem('المتوسط', average.toStringAsFixed(1)),
            _buildStatItem('الأعلى', max.toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  double _getMaxY(Map<String, int> data) {
    final values = data.values.toList();
    if (values.isEmpty) return 10;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max.toDouble() + (max * 0.2);
  }

  double _getMaxYFromList(List<int> values) {
    if (values.isEmpty) return 10;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max.toDouble() + (max * 0.2);
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> data) {
    final entries = data.entries.toList();
    return List.generate(
      entries.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entries[index].value.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
    );
  }
}
