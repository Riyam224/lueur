# Data Model: Onboarding Screen

**Feature**: `specs/001-onboarding-screen`
**Date**: 2026-06-27

## Entities

### OnboardingPageData *(existing — presentation-only)*

Immutable value object. No persistence.

| Field | Type | Notes |
|---|---|---|
| `title` | `String` | Headline text for the page |
| `subtitle` | `String` | Body text for the page |
| `variant` | `OnboardingIllustrationVariant` | Drives which CustomPainter to render |
| `blobColor` | `Color` | Wave blob background color |

`OnboardingIllustrationVariant` enum values: `luna`, `chat`, `sprout`
(rename from `glow`/`speechBubble`/`sprout` during illustration refactor — or keep
existing names and map to new painters).

---

### OnboardingCompletionFlag *(new — persisted via Hive)*

Single boolean stored in a named Hive box. Not a Hive model — no adapter needed.

| Key | Type | Box | Default |
|---|---|---|---|
| `'seen'` | `bool` | `'onboarding'` | absent (treated as `false`) |

**Lifecycle**:
- Written `true` when user taps Skip or the page-3 CTA.
- Read once on app launch by `SplashScreen._navigate()`.
- Never reset on app update. Reset only on reinstall (Hive data deleted with app).

**Access**: via `OnboardingPrefs` helper in `core/preferences/`.

---

## State Transitions

```
App launch
  └─ SplashScreen reads OnboardingPrefs.hasSeen()
       ├─ false → route to OnboardingScreen
       │    └─ user taps Skip or last-page CTA
       │         └─ OnboardingPrefs.markSeen() → route to LoginScreen
       └─ true  → route directly to LoginScreen
```
