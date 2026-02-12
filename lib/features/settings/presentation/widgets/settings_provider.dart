import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alslat_aalnabi/core/services/storage_service.dart';
import 'package:alslat_aalnabi/core/services/audio_service.dart';
import 'package:alslat_aalnabi/core/services/notification_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:alslat_aalnabi/features/admin/data/services/content_service.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/theme_controller.dart'
    as theme_controller;

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  final AudioService _audioService = AudioService();
  final ContentService _contentService = ContentService();

  bool _isDarkMode = false;
  bool _isReminderEnabled = true;
  int _reminderInterval = 15;
  String _selectedFormat = 'اللهم صل وسلم على نبينا محمد';
  String _language = 'ar';
  String _notificationTitle = 'تذكير الصلاة على النبي';
  bool _pauseRemindersInTimeRange = false;
  bool _stopDuringCalls = false;
  bool _notifyInSilent = true;
  double _notificationVolume = 0.5;
  bool _isLanguageSelected = false;
  TimeOfDay _timeRangeStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _timeRangeEnd = const TimeOfDay(hour: 6, minute: 0);
  String? _selectedReminderSoundId;
  Map<String, dynamic>? _savedReminderSound;
  String _quranTheme = 'green';

  bool get isDarkMode => _isDarkMode;
  bool get isReminderEnabled => _isReminderEnabled;
  int get reminderInterval => _reminderInterval;
  String get selectedFormat => _selectedFormat;
  String get language => _language;
  String get notificationTitle => _notificationTitle;
  bool get pauseRemindersInTimeRange => _pauseRemindersInTimeRange;
  bool get stopDuringCalls => _stopDuringCalls;
  bool get notifyInSilent => _notifyInSilent;
  double get notificationVolume => _notificationVolume;
  bool get isLanguageSelected => _isLanguageSelected;
  TimeOfDay get timeRangeStart => _timeRangeStart;
  TimeOfDay get timeRangeEnd => _timeRangeEnd;
  String? get selectedReminderSoundId => _selectedReminderSoundId;
  Map<String, dynamic>? get savedReminderSound => _savedReminderSound;
  String get quranTheme => _quranTheme;

  SettingsProvider() {
    _loadSettings();
    _initializeReminders();
  }

  void _loadSettings() {
    _isDarkMode = _storage.isDarkMode();
    _isReminderEnabled = _storage.isReminderEnabled();
    _reminderInterval = _storage.getReminderInterval();
    _selectedFormat = _storage.getSelectedSalawatFormat();
    _language = _storage.getLanguage();
    _isLanguageSelected = _storage.hasLanguageSelected();
    _pauseRemindersInTimeRange = _storage.getPauseRemindersInTimeRange();
    _stopDuringCalls = _storage.getStopDuringCalls();
    _notifyInSilent = _storage.getNotifyInSilentMode();
    _notificationVolume = _storage.getNotificationVolume();
    _selectedReminderSoundId = _storage.getSelectedReminderSoundId();
    _savedReminderSound = _storage.getSavedReminderSound();
    _quranTheme = _storage.getQuranTheme();
    // Force reset from blue to green as per user request for new default
    if (_quranTheme == 'blue') {
      _quranTheme = 'green';
      _storage.setQuranTheme('green');
    }
    _loadTimeRangeTimes();
    notifyListeners();
  }

  Future<void> _initializeReminders() async {
    if (_isReminderEnabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _scheduleReminders();
    }
  }

  void _loadTimeRangeTimes() {
    final timeRangeStartStr = _storage.getTimeRangeStartTime();
    final timeRangeEndStr = _storage.getTimeRangeEndTime();

    if (timeRangeStartStr != null && timeRangeStartStr.isNotEmpty) {
      final parts = timeRangeStartStr.split(':');
      if (parts.length == 2) {
        _timeRangeStart = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    if (timeRangeEndStr != null && timeRangeEndStr.isNotEmpty) {
      final parts = timeRangeEndStr.split(':');
      if (parts.length == 2) {
        _timeRangeEnd = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
  }

  Future<void> setAppearanceStyle(String style) async {
    _quranTheme = style;
    _isDarkMode = (style == 'dark');
    await _storage.setQuranTheme(style);
    await _storage.setDarkMode(_isDarkMode);

    // Sync with Quran ThemeController
    try {
      final themeCtrl = Get.find<theme_controller.ThemeController>();
      theme_controller.AppTheme? targetTheme;
      switch (style) {
        case 'green':
          targetTheme = theme_controller.AppTheme.green;
          break;
        case 'blue':
          targetTheme = theme_controller.AppTheme.blue;
          break;
        case 'brown':
          targetTheme = theme_controller.AppTheme.brown;
          break;
        case 'old':
          targetTheme = theme_controller.AppTheme.old;
          break;
        case 'dark':
          targetTheme = theme_controller.AppTheme.dark;
          break;
      }
      if (targetTheme != null && themeCtrl.currentTheme != targetTheme) {
        themeCtrl.setTheme(targetTheme);
      }
    } catch (e) {
      debugPrint('Error syncing with ThemeController: $e');
    }

    notifyListeners();
  }

  Future<void> toggleReminder() async {
    _isReminderEnabled = !_isReminderEnabled;
    await _storage.setReminderEnabled(_isReminderEnabled);

    if (_isReminderEnabled) {
      await _scheduleReminders();
    } else {
      await _notifications.cancelAllNotifications();
    }

    notifyListeners();
  }

  Future<void> setReminderInterval(int minutes) async {
    _reminderInterval = minutes;
    await _storage.setReminderInterval(minutes);

    if (_isReminderEnabled) {
      await _scheduleReminders();
    }

    notifyListeners();
  }

  Future<void> setSelectedFormat(String format) async {
    _selectedFormat = format;
    await _storage.setSelectedSalawatFormat(format);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    await _storage.setLanguage(languageCode);
    _isLanguageSelected = true;
    Get.updateLocale(Locale(languageCode));
    notifyListeners();
  }

  void setNotificationTitle(String title) {
    _notificationTitle = title;
    if (_isReminderEnabled) {
      _scheduleReminders();
    }
    notifyListeners();
  }

  Future<void> _scheduleReminders() async {
    debugPrint('========== SCHEDULING REMINDERS ==========');
    debugPrint('Reminders Enabled: $_isReminderEnabled');
    debugPrint('Interval: $_reminderInterval minutes');
    debugPrint('Selected Format: $_selectedFormat');
    debugPrint('Selected Sound ID: $_selectedReminderSoundId');

    if (!_isReminderEnabled) {
      debugPrint('⚠ Reminders are disabled, skipping schedule');
      debugPrint('=========================================');
      return;
    }

    try {
      await _notifications.cancelAllNotifications();
      debugPrint('✓ All previous notifications cancelled');
    } catch (e) {
      debugPrint('⚠ Error cancelling notifications: $e');
    }

    List<int>? soundBinary;

    if (_savedReminderSound != null && _savedReminderSound!.isNotEmpty) {
      try {
        debugPrint(
          '[SOUND_LOAD] ✓ Found saved reminder sound in local storage',
        );
        debugPrint(
          '[SOUND_LOAD] Sound title: ${_savedReminderSound!['title']}',
        );

        final soundData = _savedReminderSound!['sound_binary'];
        if (soundData is List<int> && soundData.isNotEmpty) {
          soundBinary = soundData;
          debugPrint(
            '[SOUND_LOAD] ✓ Loaded saved sound from local storage: ${soundBinary.length} bytes',
          );
        } else {
          debugPrint(
            '[SOUND_LOAD] ⚠ Saved sound binary is empty or invalid, attempting to fetch from ContentService',
          );
          soundBinary = null;
        }
      } catch (e) {
        debugPrint('[SOUND_LOAD] ✗ Error loading saved reminder sound: $e');
        soundBinary = null;
      }
    } else if (_selectedReminderSoundId != null &&
        _selectedReminderSoundId!.isNotEmpty) {
      debugPrint(
        '[SOUND_LOAD] No saved sound found, fetching from ContentService by ID...',
      );
      try {
        debugPrint('[SOUND_LOAD] Fetching sounds from ContentService...');
        final sounds = await _contentService.getPrayerFormulaSounds();
        debugPrint('[SOUND_LOAD] Total sounds fetched: ${sounds.length}');

        if (sounds.isEmpty) {
          debugPrint('[SOUND_LOAD] ⚠ No sounds available in ContentService');
        } else {
          debugPrint(
            '[SOUND_LOAD] Available sound IDs: ${sounds.map((s) => s.id).toList()}',
          );
        }

        try {
          final selectedSound = sounds.firstWhere(
            (sound) => sound.id == _selectedReminderSoundId,
          );
          debugPrint(
            '[SOUND_LOAD] Found sound: ${selectedSound.title} (${selectedSound.language})',
          );

          if (selectedSound.soundBinary != null &&
              selectedSound.soundBinary!.isNotEmpty) {
            soundBinary = selectedSound.soundBinary;
            debugPrint(
              '[SOUND_LOAD] ✓ Sound binary loaded: ${soundBinary!.length} bytes',
            );

            final soundDataMap = {
              'id': selectedSound.id,
              'title': selectedSound.title,
              'language': selectedSound.language,
              'sound_binary': selectedSound.soundBinary,
              'created_at': selectedSound.createdAt?.toIso8601String(),
            };
            await setSavedReminderSound(soundDataMap);
            debugPrint(
              '[SOUND_LOAD] ✓ Saved sound to local storage for offline access',
            );
          } else {
            debugPrint('[SOUND_LOAD] ✗ Sound binary is empty or null');
            soundBinary = null;
          }
        } catch (e) {
          debugPrint(
            '[SOUND_LOAD] ✗ Selected reminder sound not found: $_selectedReminderSoundId',
          );
          debugPrint('[SOUND_LOAD] Error: $e');
          soundBinary = null;
        }
      } catch (e) {
        debugPrint('[SOUND_LOAD] ✗ Error fetching reminder sounds: $e');
        soundBinary = null;
      }
    } else {
      debugPrint(
        '[SOUND_LOAD] ⚠ No reminder sound selected (ID is null or empty)',
      );
    }

    debugPrint('[SCHEDULE] Setting up notification callback to play audio...');
    final hasSoundBinary = soundBinary?.isNotEmpty ?? false;

    _notifications.setOnNotificationShown((notificationId) {
      debugPrint(
        '[SCHEDULE] Notification shown callback triggered - playing audio',
      );
      if (_pauseRemindersInTimeRange && _isInPauseTimeRange()) {
        debugPrint(
          '[SCHEDULE] ⚠ In pause time range, skipping audio playback and cancelling notification',
        );
        AwesomeNotifications().cancel(notificationId);
        return;
      }

      // ALWAYS prioritize assets/audio/default.mp3 if no sound binary is found
      if (hasSoundBinary) {
        _playReminderSound(soundBinary as List<int>);
      } else {
        debugPrint(
          '[SCHEDULE] Using default sound from assets: assets/audio/default.mp3',
        );
        _audioService.playAssetSound('assets/audio/default.mp3');
      }
    });

    debugPrint('[SCHEDULE] Calling scheduleRepeatingNotification...');
    debugPrint('[SCHEDULE] Sound available: $hasSoundBinary');
    debugPrint('[SCHEDULE] Reminder Interval: $_reminderInterval minutes');

    try {
      await _notifications.scheduleRepeatingNotification(
        id: 1,
        title: _notificationTitle,
        body: _selectedFormat,
        intervalMinutes: _reminderInterval,
        soundId: _selectedReminderSoundId,
        soundBinary: soundBinary,
      );
      debugPrint('[SCHEDULE] ✓ Reminders scheduled successfully');
      debugPrint('[SCHEDULE] Auto-dismiss after: 8 seconds');
      debugPrint('[SCHEDULE] Next reminder in $_reminderInterval minutes');
    } catch (e) {
      debugPrint('[SCHEDULE] ✗ Error scheduling reminders: $e');
      debugPrint('[SCHEDULE] Stack trace: ${StackTrace.current}');
    }

    debugPrint('=========================================');
  }

  Future<void> _playReminderSound(List<int> soundBinary) async {
    try {
      debugPrint('[AUDIO] Playing reminder sound...');
      await _audioService.playBinarySound(soundBinary);
      debugPrint('[AUDIO] ✓ Reminder sound playback initiated');
    } catch (e) {
      debugPrint('[AUDIO] ✗ Error playing reminder sound: $e');
    }
  }

  Future<void> togglePauseRemindersInTimeRange() async {
    _pauseRemindersInTimeRange = !_pauseRemindersInTimeRange;
    await _storage.setPauseRemindersInTimeRange(_pauseRemindersInTimeRange);
    if (_isReminderEnabled) {
      await _scheduleReminders();
    }
    notifyListeners();
  }

  Future<void> toggleStopDuringCalls() async {
    _stopDuringCalls = !_stopDuringCalls;
    await _storage.setStopDuringCalls(_stopDuringCalls);
    notifyListeners();
  }

  Future<void> toggleNotifyInSilent() async {
    _notifyInSilent = !_notifyInSilent;
    await _storage.setNotifyInSilentMode(_notifyInSilent);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _notificationVolume = volume;
    await _storage.setNotificationVolume(volume);
    notifyListeners();
  }

  Future<void> setTimeRangeStartTime(TimeOfDay time) async {
    _timeRangeStart = time;
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    await _storage.setTimeRangeStartTime(timeStr);
    if (_isReminderEnabled) {
      await _scheduleReminders();
    }
    notifyListeners();
  }

  Future<void> setTimeRangeEndTime(TimeOfDay time) async {
    _timeRangeEnd = time;
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    await _storage.setTimeRangeEndTime(timeStr);
    if (_isReminderEnabled) {
      await _scheduleReminders();
    }
    notifyListeners();
  }

  Future<void> setSelectedReminderSoundId(String? soundId) async {
    _selectedReminderSoundId = soundId;
    await _storage.setSelectedReminderSoundId(soundId);

    if (_isReminderEnabled) {
      await _scheduleReminders();
    }

    notifyListeners();
  }

  Future<void> setSavedReminderSound(Map<String, dynamic> soundData) async {
    _savedReminderSound = soundData;
    await _storage.setSavedReminderSound(soundData);
    notifyListeners();
  }

  Future<void> clearSavedReminderSound() async {
    _savedReminderSound = null;
    await _storage.clearSavedReminderSound();
    notifyListeners();
  }

  Future<void> setQuranTheme(String theme) async {
    await setAppearanceStyle(theme);
  }

  bool _isInPauseTimeRange() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final startMinutes = _timeRangeStart.hour * 60 + _timeRangeStart.minute;
    final endMinutes = _timeRangeEnd.hour * 60 + _timeRangeEnd.minute;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    // If start time is before end time (same day range, e.g., 09:00 - 17:00)
    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // If start time is after end time (overnight range, e.g., 22:00 - 06:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}
