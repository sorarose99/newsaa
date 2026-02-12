import 'dart:async';
import 'package:flutter/foundation.dart';

/// Manages admin session lifecycle and auto-logout on inactivity
class AdminSessionManager extends ChangeNotifier {
  static const Duration _sessionTimeout = Duration(minutes: 15);

  DateTime? _lastActivity;
  Timer? _timeoutTimer;
  bool _isActive = false;

  /// Whether an admin session is currently active
  bool get isActive => _isActive;

  /// Time remaining until session expires (null if no active session)
  Duration? get timeRemaining {
    if (!_isActive || _lastActivity == null) return null;
    final elapsed = DateTime.now().difference(_lastActivity!);
    final remaining = _sessionTimeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Start a new admin session
  void startSession() {
    _isActive = true;
    _updateActivity();
    notifyListeners();
  }

  /// End the current admin session
  void endSession() {
    _isActive = false;
    _lastActivity = null;
    _cancelTimer();
    notifyListeners();
  }

  /// Update last activity timestamp (call this on user interaction)
  void updateActivity() {
    if (!_isActive) return;
    _updateActivity();
  }

  /// Check if session has expired
  bool get isExpired {
    if (!_isActive || _lastActivity == null) return true;
    final elapsed = DateTime.now().difference(_lastActivity!);
    return elapsed >= _sessionTimeout;
  }

  void _updateActivity() {
    _lastActivity = DateTime.now();
    _resetTimer();
  }

  void _resetTimer() {
    _cancelTimer();
    _timeoutTimer = Timer(_sessionTimeout, () {
      if (_isActive) {
        endSession();
        // Notify listeners that session has expired
        notifyListeners();
      }
    });
  }

  void _cancelTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
