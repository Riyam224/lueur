# Implementation Plan: Arabic Localization

**Branch**: `003-arabic-localization` | **Date**: 2026-07-28 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-arabic-localization/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Add a manually-toggled English/Arabic language setting to the Settings screen. Introduce Flutter's official `gen-l10n` localization pipeline (`flutter_localizations` + `intl` + ARB files) to replace the app's existing centralized `AppStrings` string table, add a `LanguageCubit` (Clean Architecture: cubit → use case → repo → datasource, mirroring `AuthCubit`) that persists the chosen locale via `shared_preferences`, and wire it into `MaterialApp.router` so `locale` and RTL directionality follow the cubit's state. Actual Arabic copy is out of scope — `app_ar.arb` ships with placeholder TODO values only.

## Technical Context

**Language/Version**: Dart 3+ / Flutter (per `pubspec.yaml` SDK constraint)

**Primary Dependencies**: `flutter_localizations` (sdk: flutter, new), `intl` (already present at `^0.20.2`, reused — no version bump needed since it already satisfies `flutter_localizations`' constraint), `shared_preferences` (new — not currently a dependency; Hive is used elsewhere but the spec explicitly calls for `shared_preferences` for this single key), `flutter_bloc` (existing, for `LanguageCubit`), `get_it` (existing, for DI registration), `dartz` (existing, for `Either<Failure, T>` in the use case/repo layer)

**Storage**: `shared_preferences` — single string key `"preferred_language"` (`"en"` | `"ar"`). Not Hive-backed, per explicit user instruction (this is the one deliberate exception to the app's usual Hive-for-local-persistence convention).

**Testing**: `flutter_test` — unit tests for the datasource (read/write/fallback), repository (`Either` mapping), use cases, and cubit (state transitions + `isClosed` guard behavior), consistent with constitution Principle V (test coverage for domain & data layers).

**Target Platform**: iOS + Android (existing Flutter app targets)

**Project Type**: Mobile app (single Flutter project, Clean Architecture feature-first structure)

**Performance Goals**: Locale switch reflected across the widget tree within a single frame after the cubit emits (no perceptible delay) — N/A beyond standard Flutter rebuild performance.

**Constraints**: No device-locale auto-detection (explicit user action only); English is always the first-launch default; must not lose in-progress user input on switch; must not introduce clinical/medical terminology.

**Scale/Scope**: ~222 strings currently centralized in `lib/core/utils/app_strings.dart`, plus a small number of additional inline string literals identified outside that file (5 files) — all must be routed through the generated `AppLocalizations` class. ~10 primary screens/flows (home, response, chat, journal, plant, quotes, affirmation, breathing, profile/settings, onboarding, auth, splash).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Status |
|---|---|---|
| I. Clean Architecture | `LanguageCubit` depends only on a `GetLanguagePreferenceUseCase` / `SetLanguagePreferenceUseCase`, which depend on a `LanguageRepository` interface, implemented by `LanguageRepositoryImpl` backed by a `LanguageLocalDatasource` wrapping `shared_preferences`. No layer is bypassed. | PASS |
| II. Domain Layer Purity | `domain/entities`, `domain/repositories`, `domain/usecases` for the new `language` feature contain zero `package:flutter/...` imports. `Locale` (a Flutter/`dart:ui`-adjacent type) is NOT used in the domain layer — the domain represents the preference as a plain `String` or a small enum (`AppLanguage.en` / `AppLanguage.ar`); only the presentation-layer `LanguageCubit` maps that to a `Locale` for `MaterialApp`. Repository/use cases return `Either<Failure, T>`. | PASS |
| III. Cubit/Bloc State Management | `LanguageCubit extends Cubit<Locale>` (presentation layer only), depends only on the two use cases (never the repository/datasource directly), registered `registerLazySingleton` (documented exception, same class as `MoodCubit`, justified below). No Riverpod/Provider/GetX introduced. | PASS |
| IV. Minimal Footprint | Reuses the existing centralized `AppStrings` inventory as the source list for ARB key extraction (no new string-organization abstraction invented). One new package (`shared_preferences`) added only because the spec explicitly calls for it instead of the existing Hive convention. | PASS — see Complexity Tracking for the Hive-vs-shared_preferences deviation |
| V. Test Coverage | Unit tests planned for `LanguageLocalDatasource`, `LanguageRepositoryImpl`, both use cases, and `LanguageCubit`. | PASS |

No unjustified violations. One deviation (shared_preferences instead of Hive) is recorded in Complexity Tracking because it's an explicit, deliberate divergence from the codebase's established local-storage convention, not an oversight.

## Project Structure

### Documentation (this feature)

```text
specs/003-arabic-localization/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md         # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lueur/
├── l10n.yaml                                  # NEW — gen-l10n config (repo root)
├── pubspec.yaml                               # MODIFIED — add deps + generate: true
├── lib/
│   ├── l10n/                                  # NEW
│   │   ├── app_en.arb                         # NEW — extracted strings, English values
│   │   └── app_ar.arb                         # NEW — same keys, placeholder TODO values
│   ├── main.dart                              # MODIFIED — read persisted language before runApp (optional pre-warm), no Hive box needed for this feature
│   ├── core/
│   │   ├── app.dart                           # MODIFIED — BlocProvider for LanguageCubit, locale/localizationsDelegates/supportedLocales on MaterialApp.router
│   │   └── injection/injection.dart           # MODIFIED — register LanguageLocalDatasource, LanguageRepository, both use cases, LanguageCubit (registerLazySingleton)
│   └── features/
│       └── language/                          # NEW feature folder
│           ├── data/
│           │   ├── datasources/language_local_datasource.dart
│           │   └── repositories/language_repository_impl.dart
│           ├── domain/
│           │   ├── entities/app_language.dart         # enum: en, ar
│           │   ├── repositories/language_repository.dart
│           │   └── usecases/
│           │       ├── get_language_preference_usecase.dart
│           │       └── set_language_preference_usecase.dart
│           └── presentation/
│               ├── cubit/language_cubit.dart
│               └── widgets/language_toggle_widget.dart # consumed by Settings screen
│
│   # MODIFIED — string-literal call sites converted to AppLocalizations.of(context)!.<key>
│   ├── core/utils/app_strings.dart             # source inventory for ARB key extraction (removed/deprecated once callers migrate)
│   └── features/profile/presentation/widgets/profile_settings_section_widget.dart  # add language toggle row
│
└── test/
    └── features/language/
        ├── data/language_local_datasource_test.dart
        ├── data/language_repository_impl_test.dart
        ├── domain/get_language_preference_usecase_test.dart
        ├── domain/set_language_preference_usecase_test.dart
        └── presentation/language_cubit_test.dart
```

**Structure Decision**: Single Flutter mobile app, existing feature-first Clean Architecture layout (`features/{name}/data|domain|presentation/`). This feature adds a new `features/language/` folder following that exact convention, plus the standard Flutter `lib/l10n/` + root `l10n.yaml` locations required by `flutter gen-l10n`. No new top-level project or module is introduced.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `shared_preferences` added as a second local-storage mechanism alongside the existing Hive convention (`ThemeCubit`, `MoodLocalDatasource`, etc. all use Hive) | Explicit, deliberate user requirement for this feature — a single string preference key, not a data model needing a `.g.dart` adapter | Using Hive instead (opening a new box for one key) was considered simpler/more consistent, but the spec explicitly calls for `shared_preferences`; overriding an explicit instruction without cause would violate change discipline more than the one extra dependency does |
