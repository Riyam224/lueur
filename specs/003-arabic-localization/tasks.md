---
description: "Task list template for feature implementation"
---

# Tasks: Arabic Localization

**Input**: Design documents from `/specs/003-arabic-localization/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/language_repository.md, quickstart.md

**Tests**: Included for the domain/data layer per constitution Principle V ("Test Coverage for Domain & Data" is NON-NEGOTIABLE in this repo's constitution — not optional). No test tasks are generated for presentation-layer string conversion (US3); that story is validated via the quickstart.md manual coverage walkthrough instead.

**Organization**: Tasks are grouped by user story (US1 = switch language, P1; US2 = persistence across restart, P2; US3 = full string coverage, P3) per spec.md.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are relative to the repo root (`/Users/r/StudioProjects/lueur`)

## Path Conventions

Single Flutter mobile project — `lib/`, `test/` at repository root, feature-first Clean Architecture (`lib/features/{name}/data|domain|presentation/`), per plan.md's Project Structure.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Get the `gen-l10n` pipeline compiling before any feature code depends on `AppLocalizations`.

- [X] T001 Add `flutter_localizations` (sdk: flutter) and `shared_preferences` (latest stable) to `pubspec.yaml`; confirm `intl: ^0.20.2` already present is compatible (no version bump needed) in `pubspec.yaml`
- [X] T002 Add `generate: true` under the `flutter:` section of `pubspec.yaml`
- [X] T003 [P] Create `l10n.yaml` at repo root (`arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `synthetic-package: false` is NOT required — use default synthetic package unless it conflicts with existing import conventions)
- [X] T004 [P] Create `lib/l10n/app_en.arb` containing every key currently in `lib/core/utils/app_strings.dart` (222 entries) with their existing English values, using the existing `AppStrings` field names as ARB keys unchanged (per research.md §4)
- [X] T005 [P] Create `lib/l10n/app_ar.arb` with the identical key set as `app_en.arb`, each value set to a placeholder marker (e.g. `"TODO_AR: <original English text>"`) — no machine translation
- [X] T006 Run `flutter pub get` then `flutter gen-l10n` (or `flutter run`) to confirm `AppLocalizations` generates without error from T001–T005

**Checkpoint**: `AppLocalizations.of(context)!.<key>` is available for every extracted key; project still builds.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The `language` feature's full Clean Architecture stack (data → domain → presentation) plus DI/app wiring that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T007 [P] Create `AppLanguage` enum (`en`, `ar`) in `lib/features/language/domain/entities/app_language.dart` (pure Dart, zero Flutter imports, per constitution Principle II)
- [X] T008 [P] Create `LanguageRepository` abstract interface in `lib/features/language/domain/repositories/language_repository.dart` per `contracts/language_repository.md` (`getLanguage()` / `setLanguage()` returning `Either<Failure, T>`)
- [X] T009 [P] Create `LanguageLocalDatasource` in `lib/features/language/data/datasources/language_local_datasource.dart` wrapping `shared_preferences`, key `"preferred_language"`; `getLanguageCode()` returns `null` for missing/invalid values (never throws for "not found"), `setLanguageCode()` throws only on genuine plugin errors
- [X] T010 Create `LanguageRepositoryImpl` in `lib/features/language/data/repositories/language_repository_impl.dart` implementing `LanguageRepository`, mapping datasource results/exceptions to `AppLanguage`/`Failure` (depends on T007, T008, T009)
- [X] T011 [P] Create `GetLanguagePreferenceUseCase` in `lib/features/language/domain/usecases/get_language_preference_usecase.dart` (depends on T008)
- [X] T012 [P] Create `SetLanguagePreferenceUseCase` in `lib/features/language/domain/usecases/set_language_preference_usecase.dart` (depends on T008)
- [X] T013 Create `LanguageCubit extends Cubit<Locale>` in `lib/features/language/presentation/cubit/language_cubit.dart`, following `AuthCubit`'s structure: depends only on the two use cases, exposes `changeLanguage(AppLanguage)`, every `emit` guarded with `if (isClosed) return;` (not `mounted`) (depends on T011, T012)
- [X] T014 Modify `lib/main.dart` to `await SharedPreferences.getInstance()` before `setupInjection()` (mirrors the existing pattern of opening Hive boxes before injection setup) so the preference can be read synchronously at cubit construction, matching `ThemeCubit`'s synchronous-load pattern
- [X] T015 Register `SharedPreferences` instance, `LanguageLocalDatasource`, `LanguageRepository`, both use cases, and `LanguageCubit` (as `registerLazySingleton`, matching the documented `MoodCubit`/`ThemeCubit` singleton precedent) in `lib/core/injection/injection.dart`

### Foundational tests (domain & data layers — constitution Principle V)

- [X] T016 [P] Unit test `LanguageLocalDatasource` in `test/features/language/data/language_local_datasource_test.dart` — covers write/read round-trip and missing/invalid-value → `null` behavior
- [X] T017 [P] Unit test `LanguageRepositoryImpl` in `test/features/language/data/language_repository_impl_test.dart` — covers `Either` mapping for success and storage-failure cases
- [X] T018 [P] Unit test `GetLanguagePreferenceUseCase` in `test/features/language/domain/get_language_preference_usecase_test.dart`
- [X] T019 [P] Unit test `SetLanguagePreferenceUseCase` in `test/features/language/domain/set_language_preference_usecase_test.dart`
- [X] T020 Unit test `LanguageCubit` in `test/features/language/presentation/language_cubit_test.dart` — covers initial-state resolution (default to `en` on missing/invalid), state transition on `changeLanguage`, and that no emit occurs after `close()` (isClosed guard) (depends on T013)

**Checkpoint**: Foundation ready — `LanguageCubit` is fully implemented, tested, and injectable. User story implementation can now begin.

---

## Phase 3: User Story 1 - Switch app language from Settings (Priority: P1) 🎯 MVP

**Goal**: A user can pick English/Arabic from Settings and see the app's locale and RTL/LTR direction change immediately.

**Independent Test**: From Settings, tap the language toggle and verify the visible screen's text direction flips to RTL immediately, with no restart required (quickstart.md scenario 2).

### Implementation for User Story 1

- [X] T021 [US1] Wire `LanguageCubit` into `lib/core/app.dart`: add `BlocProvider.value(value: sl<LanguageCubit>())` alongside the existing `ThemeCubit` provider, wrap `MaterialApp.router` build in a `BlocBuilder<LanguageCubit, Locale>`, set `locale:` from cubit state, add `localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate]` and `supportedLocales: [Locale('en'), Locale('ar')]` — no manual `Directionality` widget (depends on T013, T015)
- [X] T022 [US1] Create `LanguageToggleWidget` in `lib/features/language/presentation/widgets/language_toggle_widget.dart` — two-option control (English / العربي), cream background `#FFF8F5`, styled consistent with `_SettingsItem` in `profile_settings_section_widget.dart`; calls `context.read<LanguageCubit>().changeLanguage(...)` on selection
- [X] T023 [US1] Add a settings row rendering `LanguageToggleWidget` into `lib/features/profile/presentation/widgets/profile_settings_section_widget.dart`, alongside the existing dark-mode `_SettingsItem` (depends on T022)
- [X] T024 [US1] Convert this file's own literal/`AppStrings.*` references (`profileSettingsSectionLabel`, `profileSettingsAppearance`, plus the new language row's label) to `AppLocalizations.of(context)!.<key>` in `lib/features/profile/presentation/widgets/profile_settings_section_widget.dart` (depends on T004, T021)
- [X] T025 [US1] Manual validation per quickstart.md scenario 2: run the app, toggle language in Settings, confirm immediate locale + RTL/LTR flip with no restart (depends on T021–T024)

**Checkpoint**: User Story 1 is fully functional — the toggle mechanism, locale switch, and RTL flip work end-to-end (even though most other screens are not yet converted — that's US3).

---

## Phase 4: User Story 2 - Language choice persists across restarts (Priority: P2)

**Goal**: A previously selected language survives a full app restart.

**Independent Test**: Set language to Arabic, force-quit the app, relaunch, confirm it opens in Arabic (quickstart.md scenario 3).

### Implementation for User Story 2

- [X] T026 [US2] Verify `LanguageLocalDatasource.getLanguageCode()` (`lib/features/language/data/datasources/language_local_datasource.dart`) correctly returns the persisted value on the next app start and returns `null` for a missing key, confirming T009/T014's pre-fetched-`SharedPreferences` pattern produces a synchronous, restart-stable initial `LanguageCubit` state (depends on T009, T014, T016)
- [X] T027 [US2] Manual validation per quickstart.md scenario 3 (persistence) and scenario 4 (invalid/corrupt stored value falls back to English — verified via T016's unit test since it's not practically reproducible via CLI) (depends on T013, T020, T026)

**Checkpoint**: User Stories 1 AND 2 both work — language switches immediately and survives restart.

---

## Phase 5: User Story 3 - Existing screens remain fully readable in either language (Priority: P3)

**Goal**: Every previously hardcoded user-facing string across the app's screens is routed through `AppLocalizations` instead of a literal, so no English text leaks through when Arabic is selected and RTL layout isn't visually broken anywhere.

**Independent Test**: Switch to Arabic, walk every primary screen, confirm no hardcoded English string remains and layout isn't broken in RTL (quickstart.md scenario 5). Per spec.md FR-012, backend/AI-generated text (mood responses, weekly letter content) is excluded — only the app's own static UI strings are in scope.

### Implementation for User Story 3

Each task converts every `AppStrings.*` call site (and any additional inline string literal in that file) to `AppLocalizations.of(context)!.*`, for the files grouped by feature area below. All tasks are `[P]` — disjoint files, no cross-task dependencies — except that all of them depend on T004 (ARB keys must exist first).

- [X] T028 [P] [US3] Convert core-level widgets: `lib/core/app.dart`, `lib/core/models/mood_type.dart`, `lib/core/navigation/app_bottom_nav_bar.dart`, `lib/core/widgets/luna_check_in_prompt.dart`
- [X] T029 [P] [US3] Convert auth screens/widgets: `lib/features/auth/presentation/screens/forgot_password_screen.dart`, `lib/features/auth/presentation/screens/login_screen.dart`, `lib/features/auth/presentation/screens/register_screen.dart`, `lib/features/auth/presentation/widgets/auth_or_divider.dart`, `lib/features/auth/presentation/widgets/password_strength_indicator.dart`
- [X] T030 [P] [US3] Convert home feature (including its inline literal strings): `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/home/presentation/screens/weekly_letter_screen.dart`, `lib/features/home/presentation/widgets/home_header.dart`, `lib/features/home/presentation/widgets/mood_entry_list_view.dart`, `lib/features/home/presentation/widgets/mood_input_section.dart`, `lib/features/home/presentation/widgets/mood_selector_section.dart`, `lib/features/home/presentation/widgets/recent_entries_header.dart`, `lib/features/home/presentation/widgets/share_thoughts_section.dart`, `lib/features/home/presentation/widgets/thoughts_input_widget.dart`, `lib/features/home/presentation/widgets/weekly_letter_banner.dart`
- [X] T031 [P] [US3] Convert journal feature (including its inline literal strings): `lib/features/journal/presentation/screens/journal_grid_screen.dart`, `lib/features/journal/presentation/screens/journal_history_screen.dart`, `lib/features/journal/presentation/widgets/journal_card_options_sheet.dart`, `lib/features/journal/presentation/widgets/journal_header_widget.dart`, `lib/features/journal/presentation/widgets/journal_mood_graph_widget.dart`, `lib/features/journal/presentation/widgets/journal_search_bar_widget.dart`, `lib/features/journal/presentation/widgets/journal_streak_bar_widget.dart`
- [X] T032 [P] [US3] Convert profile/settings feature (excluding `profile_settings_section_widget.dart`, already done in T024), including inline literal strings: `lib/features/profile/presentation/screens/profile_screen.dart`, `lib/features/profile/presentation/widgets/profile_quick_links_widget.dart`, `lib/features/profile/presentation/widgets/profile_saved_drawings_section_widget.dart`, `lib/features/profile/presentation/widgets/profile_stats_widget.dart`, `lib/features/profile/presentation/widgets/profile_sudoku_history_section_widget.dart`
- [X] T033 [P] [US3] Convert response feature (including its inline literal strings): `lib/features/response/presentation/screens/response_ai_screen.dart`, `lib/features/response/presentation/widgets/after_feeling_selector_widget.dart`, `lib/features/response/presentation/widgets/ai_response_card_widget.dart`, `lib/features/response/presentation/widgets/luna_info_widget.dart`, `lib/features/response/presentation/widgets/user_mood_card_widget.dart`
- [X] T034 [P] [US3] Convert chat feature: `lib/features/chat/presentation/cubit/chat_cubit.dart`, `lib/features/chat/presentation/screens/chat_screen.dart`
- [X] T035 [P] [US3] Convert draw feature: `lib/features/draw/presentation/screens/free_draw_screen.dart`, `lib/features/draw/presentation/screens/saved_drawing_viewer_screen.dart`
- [X] T036 [P] [US3] Convert breathing screen: `lib/features/breathing/presentation/screens/breathing_screen.dart`
- [X] T037 [P] [US3] Convert affirmation screen: `lib/features/affirmation/presentation/screens/affirmation_screen.dart`
- [X] T038 [P] [US3] Convert mood_choice dialog: `lib/features/mood_choice/presentation/widgets/mood_choice_dialog.dart`
- [X] T039 [P] [US3] Convert onboarding feature: `lib/features/onboarding/presentation/constants/onboarding_constants.dart`, `lib/features/onboarding/presentation/widgets/onboarding_skip_button.dart`
- [X] T040 [P] [US3] Convert plant feature: `lib/features/plant/presentation/screens/streak_celebration_screen.dart`
- [X] T041 [P] [US3] Convert quotes screen: `lib/features/quotes/presentation/screens/saved_quotes_screen.dart`
- [X] T042 [P] [US3] Convert splash screen: `lib/features/splash/presentation/screens/splash_screen.dart`
- [X] T043 [P] [US3] Convert sudoku feature: `lib/features/sudoku/presentation/screens/sudoku_screen.dart`, `lib/features/sudoku/presentation/widgets/sudoku_number_pad_widget.dart`
- [~] T044 [US3] ~~Delete now-unused entries from `lib/core/utils/app_strings.dart`~~ — SKIPPED BY EXPLICIT USER REQUEST. All entries are migrated and the file has zero references anywhere in `lib/`/`test/`, but the user asked to keep the file in place rather than delete it (depends on T028–T043)
- [ ] T045 [US3] Manual validation per quickstart.md scenario 5: with Arabic selected, walk every primary screen (home, response, chat, journal, plant, quotes, affirmation, breathing, profile/settings, onboarding, auth, splash) confirming no leftover hardcoded English string and no broken RTL layout; compile the coverage list of every screen/widget touched (deliverable requested by the original task) (depends on T028–T044)

**Checkpoint**: All user stories independently functional — language toggle works (US1), persists (US2), and full app string coverage is routed through localization (US3).

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T046 [P] Run `flutter analyze` and fix any warnings introduced by T001–T045
- [X] T047 [P] Run `flutter test test/features/language/` and confirm all foundational tests (T016–T020) pass
- [ ] T048 Run the full quickstart.md validation checklist end-to-end and record the final screen/widget coverage list for user review before Arabic copy is authored

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup (needs `app_en.arb` keys to exist before `LanguageCubit`/tests reference generated code indirectly via the app) — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational completion
- **User Story 2 (Phase 4)**: Depends on Foundational completion; independent of US1's UI work but conceptually verifies behavior US1's toggle triggers, so sequence after US1 is recommended though not required
- **User Story 3 (Phase 5)**: Depends on Setup (T004 ARB keys) and Foundational; independent of US1/US2 implementation details — could run in parallel with Phase 3/4 by a different contributor
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### Parallel Opportunities

- T003, T004, T005 (Setup) run in parallel
- T007, T008, T009 (Foundational entities/interfaces) run in parallel; T011, T012 (use cases) run in parallel once T008 lands
- T016–T019 (foundational tests) run in parallel
- T028–T043 (all of US3's per-feature conversions) run in parallel with each other, and with Phase 3/4, once T004 and Foundational are done

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) and Phase 2 (Foundational)
2. Complete Phase 3 (US1) — toggle + locale/RTL switching works, Settings screen itself fully localized
3. **STOP and VALIDATE**: quickstart.md scenario 2
4. This is a demoable MVP even before US2/US3 land, since the mechanism is proven

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. US1 → toggle works end-to-end → demo
3. US2 → persistence confirmed → demo
4. US3 → full-app string coverage → demo, then hand off screen/widget coverage list for Arabic copywriting
