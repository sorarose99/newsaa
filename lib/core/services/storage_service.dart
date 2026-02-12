import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box _salawatBox;
  late Box _settingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();

    _salawatBox = await Hive.openBox('salawat_box');
    _settingsBox = await Hive.openBox('settings_box');

    await _checkAndResetWeekly();
    await _checkAndResetMonthly();
    await _migrateToLifetimeCount();
  }

  Future<void> _migrateToLifetimeCount() async {
    if (!_salawatBox.containsKey('lifetime_count')) {
      final currentCount = getSalawatCount();
      await _salawatBox.put('lifetime_count', currentCount);
    }
  }

  Future<void> _checkAndResetWeekly() async {
    final lastWeekStartDate = _salawatBox.get('week_start_date') as String?;
    final today = DateTime.now();
    final currentWeekStart = _getWeekStartDate(today);

    if (lastWeekStartDate != currentWeekStart) {
      await _salawatBox.put('week_count', 0);
      await _salawatBox.put('week_start_date', currentWeekStart);
    }
  }

  Future<void> _checkAndResetMonthly() async {
    final lastMonthStartDate = _salawatBox.get('month_start_date') as String?;
    final today = DateTime.now();
    final currentMonthStart = _getMonthStartDate(today);

    if (lastMonthStartDate != currentMonthStart) {
      await _salawatBox.put('month_count', 0);
      await _salawatBox.put('month_start_date', currentMonthStart);
    }
  }

  String _getWeekStartDate(DateTime date) {
    int daysBack;
    if (date.weekday == 6) {
      daysBack = 0;
    } else if (date.weekday == 7) {
      daysBack = 1;
    } else {
      daysBack = date.weekday + 1;
    }
    final weekStart = date.subtract(Duration(days: daysBack));
    return weekStart.toIso8601String().split('T')[0];
  }

  String _getMonthStartDate(DateTime date) {
    return DateTime(date.year, date.month, 1).toIso8601String().split('T')[0];
  }

  int getSalawatCount() {
    final value = _salawatBox.get('count', defaultValue: 0);
    return (value ?? 0) as int;
  }

  int getLifetimeCount() {
    final value = _salawatBox.get('lifetime_count', defaultValue: 0);
    return (value ?? 0) as int;
  }

  Future<void> incrementSalawatCount() async {
    await _checkAndResetWeekly();
    await _checkAndResetMonthly();

    // Increment lifetime count
    final lifetimeCount = getLifetimeCount();
    await _salawatBox.put('lifetime_count', lifetimeCount + 1);

    // Increment cycle count with reset logic
    int currentCount = getSalawatCount();
    currentCount++;

    if (currentCount > 1000000) {
      currentCount = 100;
    }

    await _salawatBox.put('count', currentCount);
    await _updateDailyCount();
  }

  Future<void> resetSalawatCount() async {
    await _salawatBox.put('count', 0);
  }

  Future<void> decrementSalawatCount(int amount) async {
    final currentCount = getSalawatCount();
    final newCount = (currentCount - amount).clamp(0, currentCount);
    await _salawatBox.put('count', newCount);
  }

  Future<void> resetAllData() async {
    await _salawatBox.clear();
  }

  Future<void> _updateDailyCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final dailyKey = 'daily_$today';
    final value = _salawatBox.get(dailyKey, defaultValue: 0);
    final currentDailyCount = (value ?? 0) as int;
    await _salawatBox.put(dailyKey, currentDailyCount + 1);
    await _updateWeeklyCount();
    await _updateMonthlyCount();
  }

  Future<void> _updateWeeklyCount() async {
    final value = _salawatBox.get('week_count', defaultValue: 0);
    final currentWeekCount = (value ?? 0) as int;
    await _salawatBox.put('week_count', currentWeekCount + 1);
  }

  Future<void> _updateMonthlyCount() async {
    final value = _salawatBox.get('month_count', defaultValue: 0);
    final currentMonthCount = (value ?? 0) as int;
    await _salawatBox.put('month_count', currentMonthCount + 1);
  }

  int getWeeklyCount() {
    final value = _salawatBox.get('week_count', defaultValue: 0);
    return (value ?? 0) as int;
  }

  int getMonthlyCount() {
    final value = _salawatBox.get('month_count', defaultValue: 0);
    return (value ?? 0) as int;
  }

  Future<void> resetDailySalawatCount(DateTime date) async {
    final dateKey = 'daily_${date.toIso8601String().split('T')[0]}';
    await _salawatBox.put(dateKey, 0);
  }

  Future<void> resetWeeklySalawatCount() async {
    final now = DateTime.now();
    await _salawatBox.put('week_count', 0);
    await _salawatBox.put('week_start_date', _getWeekStartDate(now));
  }

  Future<void> resetMonthlySalawatCount() async {
    final now = DateTime.now();
    await _salawatBox.put('month_count', 0);
    await _salawatBox.put('month_start_date', _getMonthStartDate(now));
  }

  Future<void> decrementWeeklyCount(int amount) async {
    final currentWeekCount = getWeeklyCount();
    final newWeekCount = (currentWeekCount - amount).clamp(0, currentWeekCount);
    await _salawatBox.put('week_count', newWeekCount);
  }

  Future<void> decrementMonthlyCount(int amount) async {
    final currentMonthCount = getMonthlyCount();
    final newMonthCount = (currentMonthCount - amount).clamp(
      0,
      currentMonthCount,
    );
    await _salawatBox.put('month_count', newMonthCount);
  }

  int getDailySalawatCount(DateTime date) {
    final dateKey = 'daily_${date.toIso8601String().split('T')[0]}';
    final value = _salawatBox.get(dateKey, defaultValue: 0);
    return (value ?? 0) as int;
  }

  Map<String, int> getWeeklySalawatCount() {
    final Map<String, int> weeklyData = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      weeklyData[dateKey] = getDailySalawatCount(date);
    }

    return weeklyData;
  }

  Map<String, int> getMonthlySalawatCount() {
    final Map<String, int> monthlyData = {};
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      monthlyData[dateKey] = getDailySalawatCount(date);
    }

    return monthlyData;
  }

  bool isReminderEnabled() {
    return _settingsBox.get('reminder_enabled', defaultValue: true) as bool;
  }

  Future<void> setReminderEnabled(bool enabled) async {
    await _settingsBox.put('reminder_enabled', enabled);
  }

  int getReminderInterval() {
    final value = _settingsBox.get('reminder_interval', defaultValue: 15);
    return (value ?? 15) as int;
  }

  Future<void> setReminderInterval(int minutes) async {
    await _settingsBox.put('reminder_interval', minutes);
  }

  bool isDarkMode() {
    return _settingsBox.get('dark_mode', defaultValue: false) as bool;
  }

  Future<void> setDarkMode(bool enabled) async {
    await _settingsBox.put('dark_mode', enabled);
  }

  String getSelectedSalawatFormat() {
    return _settingsBox.get(
          'selected_format',
          defaultValue: 'اللهم صل وسلم على نبينا محمد ﷺ',
        )
        as String;
  }

  Future<void> setSelectedSalawatFormat(String format) async {
    await _settingsBox.put('selected_format', format);
  }

  String getLanguage() {
    return _settingsBox.get('language', defaultValue: 'ar') as String;
  }

  bool hasLanguageSelected() {
    return _settingsBox.containsKey('language');
  }

  Future<void> setLanguage(String languageCode) async {
    await _settingsBox.put('language', languageCode);
  }

  bool getPauseRemindersInTimeRange() {
    return _settingsBox.get(
          'pause_reminders_in_time_range',
          defaultValue: false,
        )
        as bool;
  }

  Future<void> setPauseRemindersInTimeRange(bool enabled) async {
    await _settingsBox.put('pause_reminders_in_time_range', enabled);
  }

  bool getStopDuringCalls() {
    return _settingsBox.get('stop_during_calls', defaultValue: false) as bool;
  }

  Future<void> setStopDuringCalls(bool enabled) async {
    await _settingsBox.put('stop_during_calls', enabled);
  }

  bool getNotifyInSilentMode() {
    return _settingsBox.get('notify_in_silent', defaultValue: true) as bool;
  }

  Future<void> setNotifyInSilentMode(bool enabled) async {
    await _settingsBox.put('notify_in_silent', enabled);
  }

  double getNotificationVolume() {
    return _settingsBox.get('notification_volume', defaultValue: 0.5) as double;
  }

  Future<void> setNotificationVolume(double volume) async {
    await _settingsBox.put('notification_volume', volume);
  }

  String? getTimeRangeStartTime() {
    return _settingsBox.get('time_range_start_time', defaultValue: '22:00')
        as String?;
  }

  Future<void> setTimeRangeStartTime(String time) async {
    await _settingsBox.put('time_range_start_time', time);
  }

  String? getTimeRangeEndTime() {
    return _settingsBox.get('time_range_end_time', defaultValue: '06:00')
        as String?;
  }

  Future<void> setTimeRangeEndTime(String time) async {
    await _settingsBox.put('time_range_end_time', time);
  }

  String? getSelectedReminderSoundId() {
    return _settingsBox.get('selected_reminder_sound_id') as String?;
  }

  Future<void> setSelectedReminderSoundId(String? soundId) async {
    if (soundId == null) {
      await _settingsBox.delete('selected_reminder_sound_id');
    } else {
      await _settingsBox.put('selected_reminder_sound_id', soundId);
    }
  }

  Map<String, dynamic>? getSavedReminderSound() {
    final soundData = _settingsBox.get('saved_reminder_sound');
    if (soundData is Map) {
      return Map<String, dynamic>.from(soundData);
    }
    return null;
  }

  Future<void> setSavedReminderSound(Map<String, dynamic> soundData) async {
    await _settingsBox.put('saved_reminder_sound', soundData);
  }

  Future<void> clearSavedReminderSound() async {
    await _settingsBox.delete('saved_reminder_sound');
  }

  int getCountingSpeed() {
    final value = _settingsBox.get('counting_speed', defaultValue: 1);
    return (value ?? 1) as int;
  }

  Future<void> setCountingSpeed(int speed) async {
    await _settingsBox.put('counting_speed', speed.clamp(1, 4));
  }

  String getQuranTheme() {
    return _settingsBox.get('quran_theme', defaultValue: 'green') as String;
  }

  Future<void> setQuranTheme(String theme) async {
    await _settingsBox.put('quran_theme', theme);
  }

  int getLastNotifiedTierMin() {
    return _settingsBox.get('last_notified_tier_min', defaultValue: -1) as int;
  }

  Future<void> setLastNotifiedTierMin(int tierMin) async {
    await _settingsBox.put('last_notified_tier_min', tierMin);
  }

  int getLastNotifiedCycleTierMin() {
    return _settingsBox.get('last_notified_cycle_tier_min', defaultValue: -1)
        as int;
  }

  Future<void> setLastNotifiedCycleTierMin(int tierMin) async {
    await _settingsBox.put('last_notified_cycle_tier_min', tierMin);
  }
}
