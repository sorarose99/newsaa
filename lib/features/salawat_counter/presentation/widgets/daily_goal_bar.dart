import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';

class DailyGoalBar extends StatelessWidget {
  final int currentGoal;

  const DailyGoalBar({super.key, required this.currentGoal});

  static const List<int> goalValues = [
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

  static int getNextGoal(int todayCount) {
    for (int goal in goalValues) {
      if (todayCount < goal) {
        return goal;
      }
    }
    return goalValues.last;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              localizations.dailyGoal(currentGoal),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
