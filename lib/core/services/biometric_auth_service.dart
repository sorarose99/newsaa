import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

/// Service to handle biometric authentication (fingerprint, face ID)
class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric authentication is available on this device
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Authenticate user with biometrics
  /// Returns true if authentication successful, false otherwise
  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Authenticate to access admin panel',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if biometrics are available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult(
          success: false,
          error: BiometricAuthError.notAvailable,
          message: 'Biometric authentication is not available on this device',
        );
      }

      // Attempt authentication
      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow fallback to device credentials
        ),
      );

      return BiometricAuthResult(
        success: authenticated,
        error: authenticated ? null : BiometricAuthError.authFailed,
        message: authenticated
            ? 'Authentication successful'
            : 'Authentication failed',
      );
    } on PlatformException catch (e) {
      // Handle specific error cases
      BiometricAuthError error;
      String message;

      if (e.code == auth_error.notAvailable) {
        error = BiometricAuthError.notAvailable;
        message = 'Biometric authentication is not available';
      } else if (e.code == auth_error.notEnrolled) {
        error = BiometricAuthError.notEnrolled;
        message =
            'No biometrics enrolled. Please set up fingerprint or face ID';
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        error = BiometricAuthError.lockedOut;
        message = 'Too many failed attempts. Please try again later';
      } else {
        error = BiometricAuthError.unknown;
        message = 'Authentication error: ${e.message}';
      }

      return BiometricAuthResult(
        success: false,
        error: error,
        message: message,
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: BiometricAuthError.unknown,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Stop ongoing authentication (if any)
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      // Ignore errors when stopping authentication
    }
  }
}

/// Result of biometric authentication attempt
class BiometricAuthResult {
  final bool success;
  final BiometricAuthError? error;
  final String message;

  BiometricAuthResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// Possible biometric authentication errors
enum BiometricAuthError {
  notAvailable,
  notEnrolled,
  lockedOut,
  authFailed,
  unknown,
}
