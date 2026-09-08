import 'package:hive_flutter/hive_flutter.dart';

/// Persists, per-account, whether the user has confirmed they meet the
/// app's age requirement. Unlike [OnboardingPrefs], this never needs a
/// "pending" pre-auth key — the uid is always known by the time age
/// confirmation is relevant (right after `signInWithCredential` succeeds,
/// or after a checkbox-gated email/password register call).
class AgeConfirmationPrefs {
  static const _boxName = 'age_confirmation';

  static String _key(String uid) => 'confirmed_$uid';

  /// Returns whether [uid] has already confirmed the age requirement.
  /// Fails closed (returns `false`) on any storage error, so a read
  /// failure re-prompts rather than silently skipping the check.
  static Future<bool> hasConfirmedAge(String uid) async {
    try {
      final box = await Hive.openBox<bool>(_boxName);
      return box.get(_key(uid), defaultValue: false)!;
    } catch (_) {
      return false;
    }
  }

  /// Records that [uid] has confirmed the age requirement. Idempotent —
  /// safe to call multiple times. Silently swallows storage errors
  /// (non-critical write failure).
  static Future<void> markAgeConfirmed(String uid) async {
    try {
      final box = await Hive.openBox<bool>(_boxName);
      await box.put(_key(uid), true);
    } catch (_) {}
  }
}
