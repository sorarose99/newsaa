import 'package:flutter/material.dart';
import 'package:alslat_aalnabi/core/services/storage_service.dart';
import 'package:alslat_aalnabi/core/services/notification_service.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';
import 'package:alslat_aalnabi/features/statistics/data/models/incentive_tier.dart';
import 'package:alslat_aalnabi/features/statistics/data/models/localized_tier_model.dart';

class SalawatCounterProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notificationService = NotificationService();

  int _count = 0;
  int get count => _count;

  int _lifetimeTotal = 0;
  int get lifetimeTotal => _lifetimeTotal;

  int get todayCount => _storage.getDailySalawatCount(DateTime.now());

  int _weeklyCount = 0;
  int _monthlyCount = 0;

  int _lastNotifiedTierMin = -1; // For lifetime total notifications
  int _lastNotifiedCycleTierMin = -1; // For main circle counter notifications
  int _lastAchievedGoal = -1;
  int _countingSpeed = 1;

  int get countingSpeed => _countingSpeed;

  VoidCallback? _onGoalAchieved;

  set onGoalAchieved(VoidCallback? callback) {
    _onGoalAchieved = callback;
  }

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

  SalawatCounterProvider() {
    _loadCount();
  }

  void _loadCount() {
    _count = _storage.getSalawatCount();
    _lifetimeTotal = _storage.getLifetimeCount();
    _weeklyCount = _storage.getWeeklyCount();
    _monthlyCount = _storage.getMonthlyCount();
    _countingSpeed = _storage.getCountingSpeed();
    _lastNotifiedTierMin = _storage.getLastNotifiedTierMin();
    _lastNotifiedCycleTierMin = _storage.getLastNotifiedCycleTierMin();
    _calculateLastAchievedGoal();
    notifyListeners();
  }

  void _calculateLastAchievedGoal() {
    int lastAchieved = -1;
    for (int goal in goalValues) {
      if (_count >= goal) {
        lastAchieved = goal;
      } else {
        break;
      }
    }
    _lastAchievedGoal = lastAchieved;
  }

  Future<void> incrementCounter({AppLocalizations? localizations}) async {
    await _storage.incrementSalawatCount();
    _count = _storage.getSalawatCount();
    _lifetimeTotal = _storage.getLifetimeCount();
    _weeklyCount = _storage.getWeeklyCount();
    _monthlyCount = _storage.getMonthlyCount();

    // Check for lifetime total achievements
    if (_lifetimeTotal >= 100) {
      final lifetimeMilestone = _checkForMilestone(
        _lifetimeTotal,
        _lastNotifiedTierMin,
      );
      if (lifetimeMilestone != null) {
        _lastNotifiedTierMin = lifetimeMilestone;
        await _storage.setLastNotifiedTierMin(_lastNotifiedTierMin);

        if (localizations != null) {
          final currentTier = LocalizedTierModel.getTierForCount(
            _lifetimeTotal,
            localizations,
          );
          await _notificationService.showInstantNotification(
            id: _lifetimeTotal.hashCode,
            title: '${currentTier.name} - الإجمالي',
            body:
                'بارك الله فيك! وصل إجماليك إلى $_lifetimeTotal صلاة على النبي ﷺ',
          );
        } else {
          final currentTier = IncentiveTier.getTierForCount(_lifetimeTotal);
          await _notificationService.showInstantNotification(
            id: _lifetimeTotal.hashCode,
            title: '${currentTier.name} - الإجمالي',
            body:
                'بارك الله فيك! وصل إجماليك إلى $_lifetimeTotal صلاة على النبي ﷺ',
          );
        }
      }
    }

    // Check for main circle counter achievements
    if (_count >= 100) {
      final cycleMilestone = _checkForMilestone(
        _count,
        _lastNotifiedCycleTierMin,
      );
      if (cycleMilestone != null) {
        _lastNotifiedCycleTierMin = cycleMilestone;
        await _storage.setLastNotifiedCycleTierMin(_lastNotifiedCycleTierMin);

        if (localizations != null) {
          final currentTier = LocalizedTierModel.getTierForCount(
            _count,
            localizations,
          );
          await _notificationService.showInstantNotification(
            id: _count.hashCode + 1000000, // Different ID to avoid conflicts
            title: '${currentTier.name} - الدورة الحالية',
            body:
                'بارك الله فيك! وصلت في الدورة الحالية إلى $_count صلاة على النبي ﷺ',
          );
        } else {
          final currentTier = IncentiveTier.getTierForCount(_count);
          await _notificationService.showInstantNotification(
            id: _count.hashCode + 1000000, // Different ID to avoid conflicts
            title: '${currentTier.name} - الدورة الحالية',
            body:
                'بارك الله فيك! وصلت في الدورة الحالية إلى $_count صلاة على النبي ﷺ',
          );
        }
      }
    }

    _checkAndTriggerGoalAchievement(_count);

    notifyListeners();
  }

  // Check if current count is a milestone worth notifying about
  int? _checkForMilestone(int count, int lastNotified) {
    final milestones = [
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

    // Find the highest milestone the user has reached
    int? highestReached;
    for (int milestone in milestones) {
      if (count >= milestone) {
        highestReached = milestone;
      } else {
        break;
      }
    }

    // Only return if this is a new milestone (higher than last notified)
    if (highestReached != null && highestReached > lastNotified) {
      return highestReached;
    }

    return null;
  }

  void _checkAndTriggerGoalAchievement(int currentCount) {
    for (int goal in goalValues) {
      if (currentCount == goal && _lastAchievedGoal != goal) {
        _lastAchievedGoal = goal;
        _onGoalAchieved?.call();
        break;
      }
    }
  }

  Map<String, int> getWeeklyData() {
    return _storage.getWeeklySalawatCount();
  }

  int getTodayCount() {
    return _storage.getDailySalawatCount(DateTime.now());
  }

  Future<void> resetCounter() async {
    await _storage.resetSalawatCount();
    _loadCount();
  }

  Future<void> resetTodayCounter() async {
    await _storage.resetDailySalawatCount(DateTime.now());
    _loadCount();
  }

  Future<void> resetWeekCounter() async {
    await _storage.resetWeeklySalawatCount();
    _loadCount();
  }

  Future<void> resetMonthCounter() async {
    await _storage.resetMonthlySalawatCount();
    _loadCount();
  }

  Future<void> resetAllCounters() async {
    await _storage.resetSalawatCount();
    await _storage.resetDailySalawatCount(DateTime.now());
    await _storage.resetWeeklySalawatCount();
    await _storage.resetMonthlySalawatCount();
    _lastNotifiedTierMin = -1;
    _lastNotifiedCycleTierMin = -1;
    await _storage.setLastNotifiedTierMin(_lastNotifiedTierMin);
    await _storage.setLastNotifiedCycleTierMin(_lastNotifiedCycleTierMin);
    _loadCount();
  }

  Map<String, int> getMonthlyData() {
    return _storage.getMonthlySalawatCount();
  }

  int getWeeklyTotal() {
    return _weeklyCount;
  }

  int getMonthlyTotal() {
    return _monthlyCount;
  }

  Future<void> setCountingSpeed(int speed) async {
    await _storage.setCountingSpeed(speed);
    _countingSpeed = speed;
    notifyListeners();
  }

  // Method to reset tier notifications - useful for debugging or fixing notification issues
  Future<void> resetTierNotifications() async {
    _lastNotifiedTierMin = -1;
    _lastNotifiedCycleTierMin = -1;
    await _storage.setLastNotifiedTierMin(_lastNotifiedTierMin);
    await _storage.setLastNotifiedCycleTierMin(_lastNotifiedCycleTierMin);
    notifyListeners();
  }

  // Reset only lifetime total notifications
  Future<void> resetLifetimeNotifications() async {
    _lastNotifiedTierMin = -1;
    await _storage.setLastNotifiedTierMin(_lastNotifiedTierMin);
    notifyListeners();
  }

  // Reset only cycle counter notifications
  Future<void> resetCycleNotifications() async {
    _lastNotifiedCycleTierMin = -1;
    await _storage.setLastNotifiedCycleTierMin(_lastNotifiedCycleTierMin);
    notifyListeners();
  }
}
