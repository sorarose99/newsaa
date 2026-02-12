import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/salawat_counter_provider.dart';
import 'package:alslat_aalnabi/features/statistics/data/models/badge_tier.dart';

class StatsOverviewPage extends StatefulWidget {
  const StatsOverviewPage({super.key});

  @override
  State<StatsOverviewPage> createState() => _StatsOverviewPageState();
}

class _StatsOverviewPageState extends State<StatsOverviewPage> {
  String _selectedPeriod = 'total';

  void _showResetConfirmation(
    BuildContext context,
    String period,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.resetCounter),
        content: Text(localizations.confirmReset),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final counterProvider = Provider.of<SalawatCounterProvider>(
                context,
                listen: false,
              );

              switch (period) {
                case 'today':
                  await counterProvider.resetTodayCounter();
                  break;
                case 'week':
                  await counterProvider.resetWeekCounter();
                  break;
                case 'month':
                  await counterProvider.resetMonthCounter();
                  break;
              }

              if (!navigator.mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(content: Text(localizations.resetCounterSuccess)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(localizations.resetCounter),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.statistics),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _showResetConfirmation(context, value, localizations);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'today',
                child: Text(localizations.resetToday),
              ),
              PopupMenuItem<String>(
                value: 'week',
                child: Text(localizations.resetWeek),
              ),
              PopupMenuItem<String>(
                value: 'month',
                child: Text(localizations.resetMonth),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<SalawatCounterProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.statistics,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        underline: const SizedBox.shrink(),
                        items: [
                          DropdownMenuItem(
                            value: 'total',
                            child: Text(localizations.total),
                          ),
                          DropdownMenuItem(
                            value: 'today',
                            child: Text(localizations.today),
                          ),
                          DropdownMenuItem(
                            value: 'week',
                            child: Text(localizations.week),
                          ),
                          DropdownMenuItem(
                            value: 'month',
                            child: Text(localizations.month),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPeriod = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildAchievementBadge(provider),
                const SizedBox(height: 24),
                if (_selectedPeriod == 'total') ...[
                  _buildStatCard(
                    title: localizations.total,
                    value: '${provider.lifetimeTotal}',
                    icon: Icons.all_inclusive,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ] else if (_selectedPeriod == 'today') ...[
                  _buildStatCard(
                    title: localizations.today,
                    value: '${provider.todayCount}',
                    icon: Icons.today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ] else if (_selectedPeriod == 'week') ...[
                  _buildWeeklyStats(provider, localizations),
                ] else if (_selectedPeriod == 'month') ...[
                  _buildMonthlyStats(provider, localizations),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.6)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(SalawatCounterProvider provider) {
    final badge = BadgeTier.getTierForCount(provider.count);

    return Center(
      child: Column(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 48)),
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

  Widget _buildWeeklyStats(
    SalawatCounterProvider provider,
    AppLocalizations localizations,
  ) {
    final weeklyData = provider.getWeeklyData();
    final total = provider.getWeeklyTotal();
    final average = weeklyData.isEmpty
        ? 0
        : (total / weeklyData.length).toInt();

    return Column(
      children: [
        _buildAchievementBadge(provider),
        const SizedBox(height: 24),
        _buildStatCard(
          title: localizations.total,
          value: '$total',
          icon: Icons.trending_up,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: localizations.average,
          value: '$average',
          icon: Icons.assessment,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.lastSevenDays,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...weeklyData.entries.map((entry) {
                  final days = [
                    localizations.saturday,
                    localizations.sunday,
                    localizations.monday,
                    localizations.tuesday,
                    localizations.wednesday,
                    localizations.thursday,
                    localizations.friday,
                  ];
                  final dayIndex = int.tryParse(entry.key) ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayIndex < days.length
                              ? days[dayIndex % 7]
                              : entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats(
    SalawatCounterProvider provider,
    AppLocalizations localizations,
  ) {
    final monthlyData = provider.getMonthlyData();
    final total = provider.getMonthlyTotal();
    final average = monthlyData.isEmpty
        ? 0
        : (total / monthlyData.length).toInt();
    final highest = monthlyData.isEmpty
        ? 0
        : monthlyData.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        _buildAchievementBadge(provider),
        const SizedBox(height: 24),
        _buildStatCard(
          title: localizations.total,
          value: '$total',
          icon: Icons.trending_up,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: localizations.average,
          value: '$average',
          icon: Icons.assessment,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: localizations.highest,
          value: '$highest',
          icon: Icons.star,
          color: const Color(0xFFD4A574),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.lastThirtyDays,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: monthlyData.length,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final value = monthlyData[day.toString()] ?? 0;
                    return Container(
                      decoration: BoxDecoration(
                        color: value > 0
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.8)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$value',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: value > 0 ? Colors.white : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
