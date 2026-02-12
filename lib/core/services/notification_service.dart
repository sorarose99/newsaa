import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:alslat_aalnabi/core/services/storage_service.dart';
import 'package:alslat_aalnabi/core/services/audio_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _reminderTimer;
  Timer? _dismissTimer;
  Function(int)? _onNotificationShown;

  static const String _salawatChannelKey = 'salawat_reminder_channel';
  static const String _salawatGroupKey = 'salawat_reminder_group';

  void setOnNotificationShown(Function(int) callback) {
    _onNotificationShown = callback;
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Initialize Flutter Local Notifications (for existing functionality)
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macOsSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macOsSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize Awesome Notifications (for persistent background scheduling)
    await AwesomeNotifications().initialize(
      null, // Use default icon
      [
        NotificationChannel(
          channelGroupKey: _salawatGroupKey,
          channelKey: _salawatChannelKey,
          channelName: 'تذكير الصلاة على النبي',
          channelDescription: 'تذكيرات منتظمة للصلاة على النبي ﷺ',
          defaultColor: const Color(0xFF9D50BB),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: false,
          playSound: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'notifications_channel_ak_notification_group',
          channelKey: 'notifications_channel_ak_notification',
          channelName: 'Quran Reading Reminders',
          channelDescription: 'Notifications for Quran reading progress',
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: _salawatGroupKey,
          channelGroupName: 'Salawat Group',
        ),
        NotificationChannelGroup(
          channelGroupKey: 'notifications_channel_ak_notification_group',
          channelGroupName: 'Quran Reminders Group',
        ),
      ],
      debug: kDebugMode,
    );

    // Set up listeners for background/foreground events
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    await requestPermissions();
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint(
      '[NOTIFICATION] Notification displayed: ${receivedNotification.id}',
    );
    NotificationService()._onNotificationShown?.call(
      receivedNotification.id ?? 0,
    );

    // Handle background audio playback with time-range check
    await _handleBackgroundAudio(receivedNotification.id ?? 0);
  }

  static Future<void> _handleBackgroundAudio(int id) async {
    try {
      final storage = StorageService();
      await storage.initialize();

      if (!storage.isReminderEnabled()) return;

      if (storage.getPauseRemindersInTimeRange()) {
        final startTimeStr = storage.getTimeRangeStartTime() ?? '22:00';
        final endTimeStr = storage.getTimeRangeEndTime() ?? '06:00';

        if (_isNowInTimeRange(startTimeStr, endTimeStr)) {
          debugPrint(
            '[NOTIFICATION] In pause time range, skipping background audio and cancelling notification',
          );
          await AwesomeNotifications().cancel(id);
          return;
        }
      }

      // Play sound from saved data
      final savedSound = storage.getSavedReminderSound();
      if (savedSound != null) {
        final soundData = savedSound['sound_binary'];
        if (soundData is List && soundData.isNotEmpty) {
          final List<int> soundBinary = List<int>.from(soundData);
          final audioService = AudioService();
          await audioService.initialize();
          await audioService.playBinarySound(soundBinary);
          debugPrint('[NOTIFICATION] Background audio played successfully');
        } else {
          _playDefaultSound();
        }
      } else {
        _playDefaultSound();
      }
    } catch (e) {
      debugPrint('[NOTIFICATION] Error in background audio handler: $e');
    }
  }

  static Future<void> _playDefaultSound() async {
    final audioService = AudioService();
    await audioService.initialize();
    await audioService.playAssetSound('assets/audio/default.mp3');
    debugPrint('[NOTIFICATION] Default background audio played');
  }

  static bool _isNowInTimeRange(String startStr, String endStr) {
    try {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final startParts = startStr.split(':');
      final endParts = endStr.split(':');

      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      if (startMinutes < endMinutes) {
        return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
      } else {
        return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
      }
    } catch (e) {
      return false;
    }
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request Awesome Notifications permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required int intervalMinutes,
    String? sound,
    String? soundId,
    List<int>? soundBinary,
  }) async {
    debugPrint(
      '[NOTIFICATION] ===== SCHEDULING START (AwesomeNotifications) =====',
    );
    debugPrint('[NOTIFICATION] ID: $id, Title: $title');
    debugPrint('[NOTIFICATION] Interval: $intervalMinutes minutes');

    try {
      _stopReminderTimer();
      await cancelNotification(id);

      if (soundBinary != null && soundBinary.isNotEmpty) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final soundFile = File(
            '${directory.path}/salawat_reminder_sound.mp3',
          );
          await soundFile.writeAsBytes(soundBinary);
          // Note: AwesomeNotifications might need the file to be in assets/raw for Android or properly linked.
          // For now, let's use the provided binary sound logic if the app is foreground,
          // but scheduling native notification usually requires resource:// or file://
          // Android resources are static, so we might need a workaround for dynamic sounds in background.
          debugPrint(
            '[NOTIFICATION] Sound saved to local file: ${soundFile.path}',
          );
        } catch (e) {
          debugPrint('[NOTIFICATION] Error saving sound binary: $e');
        }
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: _salawatChannelKey,
          groupKey: _salawatGroupKey,
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          autoDismissible: true,
        ),
        schedule: NotificationInterval(
          interval: Duration(minutes: intervalMinutes),
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          repeats: true,
          preciseAlarm: true,
        ),
      );

      debugPrint(
        '[NOTIFICATION] ✓ Scheduled successfully with AwesomeNotifications',
      );

      // Legacy fallback removed - now handled by onNotificationDisplayedMethod
    } catch (e) {
      debugPrint('[NOTIFICATION] ✗ Error scheduling: $e');
      rethrow;
    }
  }

  void _stopReminderTimer() {
    if (_reminderTimer != null) {
      debugPrint('[NOTIFICATION] Canceling existing Timer...');
      _reminderTimer!.cancel();
      _reminderTimer = null;
      debugPrint('[NOTIFICATION] ✓ Timer cancelled');
    }

    if (_dismissTimer != null) {
      debugPrint('[NOTIFICATION] Canceling dismiss Timer...');
      _dismissTimer!.cancel();
      _dismissTimer = null;
      debugPrint('[NOTIFICATION] ✓ Dismiss Timer cancelled');
    }
  }

  Future<void> cancelNotification(int id) async {
    _stopReminderTimer();
    await _notifications.cancel(id);
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    _stopReminderTimer();
    await _notifications.cancelAll();
    await AwesomeNotifications().cancelAll();
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'salawat_instant',
      'إشعارات فورية',
      channelDescription: 'إشعارات فورية للتطبيق',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  Future<void> showTestNotification() async {
    debugPrint('[TEST] Showing test notification...');
    try {
      await showInstantNotification(
        id: 999,
        title: 'تنبيه اختبار',
        body: 'هذا اختبار - التنبيهات تعمل',
      );
      debugPrint('[TEST] ✓ Test notification sent');
    } catch (e) {
      debugPrint('[TEST] ✗ Error sending test notification: $e');
    }
  }
}
