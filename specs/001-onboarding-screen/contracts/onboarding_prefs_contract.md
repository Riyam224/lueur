# Contract: OnboardingPrefs

**Location**: `lib/core/preferences/onboarding_prefs.dart`
**Type**: Static utility (no DI registration needed — no async constructor)

## Interface

```dart
class OnboardingPrefs {
  // Returns true if the user has previously completed or skipped onboarding.
  static Future<bool> hasSeen() async { ... }

  // Persists the completion flag. Call on Skip tap and last-page CTA tap.
  static Future<void> markSeen() async { ... }
}
```

## Behaviour

| Method | Pre-condition | Post-condition |
|---|---|---|
| `hasSeen()` | Hive initialized | Returns `true` if key `'seen'` exists in box `'onboarding'`; `false` otherwise |
| `markSeen()` | Hive initialized | Writes `true` to key `'seen'` in box `'onboarding'`; idempotent |

## Error Handling

If the Hive box cannot be opened (corrupted data, storage unavailable):
- `hasSeen()` catches the exception and returns `false` (safe default — user sees onboarding at worst once more).
- `markSeen()` catches and swallows the exception silently (non-critical write failure).

## Hive Initialization

`Hive.openBox('onboarding')` must be called before either method.
Callers (`SplashScreen`, `OnboardingScreen`) open the box inline via `await`.
The box is lightweight (one key) — open/close overhead is negligible.
