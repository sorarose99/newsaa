import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/salawat_counter_provider.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/daily_goal_bar.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/goal_achievement_overlay.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/battery_charge_indicator.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Timer? _countingTimer;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SalawatCounterProvider>(
        context,
        listen: false,
      );
      provider.onGoalAchieved = _showGoalAchievementAnimation;
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _countingTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _showGoalAchievementAnimation() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => GoalAchievementOverlay(
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _startContinuousCounting(
    SalawatCounterProvider provider,
    AppLocalizations localizations,
  ) {
    setState(() {
      _isLongPressing = true;
    });
    _scaleController.forward();
    _countingTimer?.cancel();

    final speedIntervals = {1: 1500, 2: 750, 3: 650, 4: 500};

    final interval = Duration(
      milliseconds: speedIntervals[provider.countingSpeed] ?? 1500,
    );

    _countingTimer = Timer.periodic(interval, (_) {
      if (mounted) {
        provider.incrementCounter(localizations: localizations);
        _triggerVibration();
      }
    });
  }

  void _stopContinuousCounting() {
    setState(() {
      _isLongPressing = false;
    });
    _scaleController.reverse();
    _countingTimer?.cancel();
    _countingTimer = null;
  }

  Future<void> _triggerVibration() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error triggering vibration: $e');
    }
  }

  int _getLastAchievedGoal(int count) {
    const goalValues = [
      100,
      500,
      1000,
      5000,
      10000,
      30000,
      50000,
      100000,
      200000,
      500000,
      750000,
      1000000,
    ];

    int lastAchieved = 0;
    for (int goal in goalValues) {
      if (count >= goal) {
        lastAchieved = goal;
      } else {
        break;
      }
    }
    return lastAchieved;
  }

  void _showSpeedSelector(
    BuildContext context,
    SalawatCounterProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر سرعة العداد',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(4, (index) {
                final speed = index + 1;
                final isSelected = provider.countingSpeed == speed;
                return GestureDetector(
                  onTap: () {
                    provider.setCountingSpeed(speed);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$speed',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context, String resetType) {
    final localizations = AppLocalizations.of(context)!;
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

              switch (resetType) {
                case 'today':
                  await counterProvider.resetTodayCounter();
                  break;
                case 'week':
                  await counterProvider.resetWeekCounter();
                  break;
                case 'month':
                  await counterProvider.resetMonthCounter();
                  break;
                case 'all':
                  await counterProvider.resetAllCounters();
                  break;
              }

              if (!navigator.mounted) {
                return;
              }
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _showResetConfirmationDialog(context, value);
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
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'all',
                child: Text(localizations.resetAll),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<SalawatCounterProvider>(
        builder: (context, provider, child) {
          final nextGoal = DailyGoalBar.getNextGoal(provider.todayCount);
          final lastAchievedGoal = _getLastAchievedGoal(provider.todayCount);
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/Background1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 12),
                    Image.asset(
                      'assets/images/Header_LOGO.png',
                      height: 100.h,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          provider.incrementCounter(
                            localizations: localizations,
                          );
                          _triggerVibration();
                        },
                        onLongPressStart: (_) {
                          _startContinuousCounting(provider, localizations);
                        },
                        onLongPressEnd: (_) {
                          _stopContinuousCounting();
                        },
                        child: Container(
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Container(
                                    width: 200.w,
                                    height: 200.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(
                                                alpha: _isLongPressing
                                                    ? 0.5
                                                    : 0.3,
                                              ),
                                          blurRadius: _isLongPressing ? 30 : 20,
                                          spreadRadius: _isLongPressing ? 8 : 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${provider.todayCount}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 56.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 60.w,
                            right: 30.w,
                            top: 0.0,
                            bottom: 0.0,
                          ),
                          child: Row(
                            children: [
                              Consumer<SalawatCounterProvider>(
                                builder: (context, speedProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showSpeedSelector(
                                        context,
                                        speedProvider,
                                      );
                                    },
                                    child: Container(
                                      width: 35.w,
                                      height: 35.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${speedProvider.countingSpeed}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BatteryChargeIndicator(
                                  currentCount: provider.todayCount,
                                  lastAchievedGoal: lastAchievedGoal,
                                  nextGoal: nextGoal,
                                  width: double.infinity,
                                  height: 28.h,
                                  horizontal: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DailyGoalBar(currentGoal: nextGoal),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
