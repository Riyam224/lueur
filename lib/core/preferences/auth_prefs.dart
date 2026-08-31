import 'package:hive_flutter/hive_flutter.dart';

/// Tracks whether this device has ever had a successful login/register/Google
/// sign-in, to show Register by default on a fresh install vs. Login for a returning user who logged out.
class AuthPrefs {
  static const _boxName = 'auth';
  static const _key = 'hasEverAuthenticated';

  /// Returns false on any storage error (safe default — treats the device
  /// as never-authenticated, so it lands on Register rather than Login).
  static Future<bool> hasEverAuthenticated() async {
    try {
      final box = await Hive.openBox<bool>(_boxName);
      return box.get(_key, defaultValue: false)!;
    } catch (_) {
      return false;
    }
  }

  /// Idempotent — safe to call after every successful sign-in.
  static Future<void> markAuthenticated() async {
    try {
      final box = await Hive.openBox<bool>(_boxName);
      await box.put(_key, true);
    } catch (_) {}
  }
}
