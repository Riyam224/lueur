import 'package:hive_flutter/hive_flutter.dart';

/// Persists and reads the onboarding completion flag using a Hive bool box.
/// Safe to call before the box is pre-opened — opens it inline if needed.
///
/// Onboarding always runs before an account is known in this app's flow
/// (Splash -> Onboarding -> Login/Register), so completion can't be keyed
/// by uid at the moment it happens. Three keys work together instead:
/// - [_legacyKey] — the old device-global flag from before per-account
///   scoping existed. Never written to again; read-only, for migration.
/// - [_pendingKey] — set when onboarding was just finished but not yet
///   attributed to an account; consumed (and cleared) by whichever
///   account authenticates next, so it can't also satisfy a later,
///   different account signing in on the same device.
/// - a per-uid key (`seen_<uid>`) — the durable, account-scoped record.
class OnboardingPrefs {
  static const _boxName = 'onboarding';
  static const _legacyKey = 'seen';
  static const _pendingKey = 'pending';

  static String _key(String uid) => 'seen_$uid';

  /// Pass `null` for the pre-auth check (Splash, before any account is
  /// known) — returns true once onboarding has been completed or its
  /// completion is still pending attribution. Pass the authenticated
  /// user's id for the post-auth check (Login/Register success) to get
  /// that account's own record, consuming a pending completion or
  /// migrating the legacy device flag forward the first time it's asked.
  static Future<bool> hasSeen(String? uid) async {
    try {
      final box = await Hive.openBox<bool>(_boxName);

      if (uid == null) {
        return box.get(_pendingKey, defaultValue: false)! ||
            box.get(_legacyKey, defaultValue: false)!;
      }

      final key = _key(uid);
      final existing = box.get(key);
      if (existing != null) return existing;

      if (box.get(_pendingKey, defaultValue: false)!) {
        await box.put(key, true);
        await box.delete(_pendingKey);
        return true;
      }

      // Migration: an already-live install may have the old device-global
      // flag set from before per-account scoping existed. Honor it (every
      // time it's asked, for every account on this device) so an existing
      // user isn't shown onboarding again after this update.
      if (box.get(_legacyKey, defaultValue: false)!) {
        await box.put(key, true);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Persists the completion flag as pending — attributed to whichever
  /// account authenticates next. Idempotent — safe to call multiple times.
  /// Silently swallows storage errors (non-critical write failure).
  static Future<void> markSeen() async {
    try {
      final box = await Hive.openBox<bool>(_boxName);
      await box.put(_pendingKey, true);
    } catch (_) {}
  }
}
