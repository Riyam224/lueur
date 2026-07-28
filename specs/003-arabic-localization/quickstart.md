# Quickstart: Validating Arabic Localization

## Prerequisites

- Dependencies added and fetched: `flutter pub get` after `flutter_localizations`, `intl`, `shared_preferences` are in `pubspec.yaml`.
- Codegen run at least once: `dart run build_runner build --delete-conflicting-outputs` (existing Hive/json models) — not required for `gen-l10n` itself, which runs automatically on `flutter run`/`flutter build` once `generate: true` is set, but run it if other generated models changed in the same branch.
- `l10n.yaml` present at repo root; `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` present.

## Setup

```bash
flutter pub get
flutter gen-l10n   # or just `flutter run` — gen-l10n runs as a pre-build step when generate: true
```

## Validation scenarios

### 1. Default language on first launch (SC-005, FR-002)

```bash
flutter run
```
Expected: app launches in English regardless of the simulator/device's system language setting (do not change device locale for this check — the point is the app ignores it).

### 2. Toggle language from Settings (SC-001, FR-001, FR-003, FR-005, FR-006)

1. Navigate to Settings (Profile tab → Settings section).
2. Tap the language control, select "العربي".
3. Observe: within the same frame/without navigating away, all currently-visible text (from `AppLocalizations`) switches to Arabic placeholder text, and layout mirrors to RTL (e.g., leading icons move to the right, `Row` children reverse order).
4. Tap the control again, select "English" — confirm it reverts to LTR/English.

### 3. Persistence across restart (SC-003, FR-004)

1. With Arabic selected, fully stop the app (not just background it).
2. Relaunch: `flutter run` (or reopen the app on device).
3. Expected: app opens directly in Arabic — no need to revisit Settings.

### 4. Invalid/corrupt preference falls back to English (FR-010, edge case)

```bash
# On a simulator/emulator with the app already installed once:
# Manually corrupt the shared_preferences value for key "preferred_language"
# (e.g., via `flutter_secure_storage`-style plist/xml edit, or simplest:
# clear app data then set an unsupported locale isn't directly settable via CLI —
# validate via a unit test instead, see test/features/language/data/language_local_datasource_test.dart)
```
This scenario is primarily covered by the automated unit test on `LanguageLocalDatasource`/`LanguageRepositoryImpl` rather than manual QA, since corrupting `shared_preferences` storage isn't easily reproducible via the CLI.

### 5. Full-screen string coverage audit (SC-002, User Story 3)

1. With Arabic selected, navigate through every primary screen: home (mood capture), response, chat, journal, plant, quotes, affirmation, breathing, profile/settings, onboarding, auth (login/register/forgot password), splash.
2. Confirm no leftover hardcoded English string appears anywhere (placeholder Arabic text is fine; a stray literal English string that didn't get routed through `AppLocalizations` is the failure signature to look for).
3. Cross-check against the coverage list produced during implementation (every screen/widget where a hardcoded string was found and converted — required deliverable per the original task).

## Automated checks

```bash
flutter analyze
flutter test test/features/language/
```

Expected: no analyzer warnings from the new `language` feature or from `core/app.dart`/`injection.dart` changes; all new unit tests pass.
