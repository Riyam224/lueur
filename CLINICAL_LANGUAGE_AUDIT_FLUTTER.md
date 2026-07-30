# Clinical Language Audit — Flutter Codebase

**Date:** 2026-07-30
**Scope:** All Dart source under `lib/`, both localization files (`lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`), and `pubspec.yaml`'s `description` field.
**Method:** Case-insensitive pattern search across all `.dart` files (excluding generated `.g.dart`) for clinical/medical terminology, diagnostic framing, licensed-practice titles, and app-metadata risk words (see patterns below), plus a full manual read-through of both `.arb` files and a targeted Arabic-term search (معالج / علاج / طبيب نفسي / تشخيص / أعراض / اضطراب / مريض / عيادة / دواء / جرعة / أخصائي نفسي).

Patterns searched: `therap(y|ist)`, `treatment`, `diagnos(is|e|ed|tic)`, `symptom`, `disorder`, `clinical`, `patient`, `condition`, `prescri(be|ption)`, `medication`, `dosage`, `counselor`, `psycholog*`, `psychiatr*`, `mental health professional`, `mental health app`, `therapy app`, `cures/treats`, `depress*`, `anxiety` (as a diagnostic label), `PTSD`, `trauma`, `bipolar`, `schizophrenia`, `addiction`, `self-harm`, `you may have`, `this indicates`, `signs of`, `seek help`, `professional help`, `licensed`. Also checked all `tooltip:` and `Semantics`/`semanticLabel` usages, and confirmed no push-notification infrastructure exists in the codebase to scan.

**No crisis/emergency-support screen or flow exists anywhere in this codebase** — confirmed via repo-wide search for crisis/emergency/hotline/suicide/helpline before starting. This item from the task's flag-only list is therefore not applicable; noted here for completeness rather than omitted silently.

---

## Auto-fixed

**None.** No user-facing clinical language was found, so there was nothing to fix.

---

## Flagged for review

**None.** No crisis/emergency-support flow exists in this codebase, and no string requiring a structural (non-string-swap) change was found.

---

## Not flagged (internal-only, confirmed out of scope)

| File | Line | String | Why out of scope |
|---|---|---|---|
| `lib/firebase_options.dart` | 74 | `iosBundleId: 'com.example.aiTherapistApp'` | Generated Firebase config file — an internal iOS bundle identifier, never rendered to a user or an App Store/Play Store reviewer as visible text. Same category as `applicationId`, which the task explicitly excludes. |

No other matches were internal-only findings worth listing — everything else the pattern scan surfaced was a false positive from substring matching (e.g. `obscureText`/`_obscurePassword` matching the `cure` fragment inside "obs**cure**", and a code comment "contrast-safe **treat**ment" in `app_colors.dart` referring to a color gradient, not a medical treatment). These aren't included in the table above since they're not even related identifiers — just accidental substring hits, not clinical language of any kind.

---

## Summary

The app's copy — onboarding, greeting messages, mood prompts, journal/chat/response screens, settings, empty states, and both English and Arabic `.arb` files — is already consistently framed as a companion/friend experience ("Luna", "your companion", "talk it out", "a gentle space") with zero clinical, diagnostic, or licensed-practice language anywhere in user-facing text. **Zero changes were made to any file.**

---

## Verification

- `flutter analyze`: **82 pre-existing info-level lints** (all `discarded_futures`, none in files touched by this audit since no files were touched), **zero errors, zero warnings**. Identical to the pre-audit baseline.
- `flutter test`: **47 passing**, **2 pre-existing failures** in `test/features/journal/journal_card_options_sheet_test.dart` (`delete requires confirmation before removing from the list`, `tapping a color swatch updates that entry's color`) — confirmed unrelated to this audit; these failures exist independent of any changes made in this or prior sessions and were not introduced here. **Zero new failures compared to the pre-audit baseline.**
