import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/salawat_counter_provider.dart';
import 'package:alslat_aalnabi/features/statistics/data/models/incentive_tier.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.plan)),
      body: SafeArea(
        child: Consumer<SalawatCounterProvider>(
          builder: (context, provider, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.goals,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildGoalsGrid(provider),
                          const SizedBox(height: 12),
                          Text(
                            localizations.statistics,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: localizations.today,
                                      value: '${provider.todayCount}',
                                      icon: Icons.calendar_today,
                                      color: const Color(0xFF679B9B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: localizations.week,
                                      value: '${provider.getWeeklyTotal()}',
                                      icon: Icons.grid_on_outlined,
                                      color: const Color(0xFF86B984),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: localizations.month,
                                      value: '${provider.getMonthlyTotal()}',
                                      icon: Icons.calendar_month,
                                      color: const Color(0xFF65A9E9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildIncentiveEmoji(
                                      value: '${provider.todayCount}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildIncentiveEmoji(
                                      value: '${provider.getWeeklyTotal()}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildIncentiveEmoji(
                                      value: '${provider.getMonthlyTotal()}',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildTotalCard(
                                title: localizations.total,
                                value: '${provider.lifetimeTotal}',
                                icon: Icons.all_inclusive,
                                color: const Color(0xFF349FA7),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalsGrid(SalawatCounterProvider provider) {
    final goals = SalawatCounterProvider.goalValues;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        return _buildGoalCard(goals[index], provider.count);
      },
    );
  }

  Widget _buildGoalCard(int goalValue, int currentCount) {
    final isAchieved = currentCount >= goalValue;
    final backgroundColor = isAchieved
        ? Colors.green.shade400
        : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatNumber(goalValue),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isAchieved ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

Widget _buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  final formattedValue = _formatNumberStatic(value);

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: Colors.white),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTotalCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  final formattedValue = _formatNumberStatic(value);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: Colors.white),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget _buildIncentiveEmoji({required String value}) {
  final count = int.tryParse(value) ?? 0;
  final incentive = IncentiveTier.getTierForCount(count);

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Center(
      child: Text(incentive.emoji, style: const TextStyle(fontSize: 28)),
    ),
  );
}

String _formatNumberStatic(String number) {
  return number.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}
