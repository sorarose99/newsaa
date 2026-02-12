import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Widget that detects secret gesture (7 taps) to reveal admin access
class SecretAdminAccessWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onSecretGestureDetected;
  final int requiredTaps;
  final Duration tapTimeout;

  const SecretAdminAccessWidget({
    super.key,
    required this.child,
    required this.onSecretGestureDetected,
    this.requiredTaps = 7,
    this.tapTimeout = const Duration(
      seconds: 5,
    ), // Increased timeout for easier tapping on mobile
  });

  @override
  State<SecretAdminAccessWidget> createState() =>
      _SecretAdminAccessWidgetState();
}

class _SecretAdminAccessWidgetState extends State<SecretAdminAccessWidget> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _onTap() {
    final now = DateTime.now();

    // Reset counter if timeout exceeded
    if (_lastTap != null && now.difference(_lastTap!) > widget.tapTimeout) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTap = now;

    developer.log(
      'SecretAdminAccessWidget: tap $_tapCount/${widget.requiredTaps}',
    );

    // Check if secret gesture completed
    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      _lastTap = null;
      widget.onSecretGestureDetected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Adding minimal padding to ensure a decent hit area even if child is small
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color:
            Colors.transparent, // Required for opaque behavior to work reliably
        child: widget.child,
      ),
    );
  }
}
