import 'package:hive_flutter/hive_flutter.dart';

/// Persists and reads the onboarding completion flag using a Hive bool box.
/// Safe to call before the box is pre-opened — opens it inline if needed.
class OnboardingPrefs {
  static const _boxName = 'onboarding';
  static const _key = 'seen';

  /// Returns true if the user has previously completed or skipped onboarding.
  /// Returns false on any storage error (safe default — shows onboarding once more).
  static Future<bool> hasSeen() async {
    try {
      final box = await Hive.openBox<bool>(_boxName);
      return box.get(_key, defaultValue: false)!;
    } catch (_) {
      return false;
    }
  }

  /// Persists the completion flag. Idempotent — safe to call multiple times.
  /// Silently swallows storage errors (non-critical write failure).
  static Future<void> markSeen() async {
    try {
      final box = await Hive.openBox<bool>(_boxName);
      await box.put(_key, true);
    } catch (_) {}
  }
}
