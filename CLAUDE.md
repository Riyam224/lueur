# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# Commands

```bash
# Run the app
flutter run

# Run on a specific device
flutter run -d ios
flutter run -d android

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Lint
flutter analyze

# Code generation (json_serializable + hive_generator)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for codegen
dart run build_runner watch --delete-conflicting-outputs
```

---

# Architecture Overview

LunaTree (root widget: `Lueur`) is a Flutter AI therapy app. It follows Clean Architecture with strict layer separation: **presentation → domain → data**.

## Feature inventory

| Feature | What it does |
|---|---|
| `auth` | Login / register via REST API |
| `home` | Mood capture — emoji + free-text → AI response |
| `response` | Displays AI-generated response + save-quote action |
| `chat` | Follow-up chat with the AI therapist |
| `journal` | Browseable mood history with emoji filter + chart |
| `plant` | Streak tracker visualised as a growing plant |
| `quotes` | Save/delete/view affirmation quotes (Hive) |
| `affirmation` | Rotating affirmation cards for a selected mood |
| `breathing` | Guided 4-7-8 breathing exercise screen |
| `profile` | User settings and saved quotes entry point |
| `onboarding` | First-launch walkthrough — presentation-only (no domain/data layers) |
| `splash` | Entry point — decides auth redirect |

## Key cross-cutting files

- **`core/injection/injection.dart`** — single `setupInjection()` that registers all `get_it` dependencies. Add new registrations here.
- **`core/routing/router_generation_config.dart`** — all `go_router` routes. `BlocProvider` for screen-scoped cubits goes here, not inside screens.
- **`core/networking/dio_helper.dart`** + `api_endpoints.dart` — Dio client wrapping the Railway backend (`https://web-production-f8628.up.railway.app`).
- **`core/errors/failures.dart`** — `Failure` base class + subtypes (`NetworkFailure`, `ServerFailure`).
- **`core/models/mood_entry.dart`** — shared `MoodEntry` used in `core/widgets/`.
- **`core/preferences/onboarding_prefs.dart`** — Hive-backed flag; `hasSeen()` / `markSeen()`. Splash reads this to choose onboarding vs. login.
- **`core/styling/`** — `AppTheme`, `AppColors`, `AppExtraColors` (ThemeExtension), `AppTextStyles`, `AppFonts`, `AppAssets`.
- **`core/constants/`** — `AppSizes`, `AppSpacing` (use `flutter_screenutil` `.r`/`.w`/`.h` values).

## Startup sequence

`main()` → `Hive.initFlutter()` → open three boxes (`mood_entries`, `saved_quotes`, theme) → `setupInjection()` → `GoogleFonts.pendingFonts()` → `runApp(Lueur())`.

`SplashScreen.initState` waits a fixed delay then calls `OnboardingPrefs.hasSeen()`:
- `false` → `context.go(AppRoutes.onBoarding)`
- `true` → `context.go(AppRoutes.loginScreen)`

## Navigation & shell

Routes are defined in `RouterGenerationConfig.goRouter`. The main app uses `StatefulShellRoute.indexedStack` with three branches: **home / journal / profile**.

- `MoodCubit` is registered as `registerLazySingleton` — it is a **singleton shared across all shell tabs**. It is provided via `BlocProvider.value` inside the shell builder, not re-created per tab. When the user logs out, call `moodCubit.clearEntries()` before navigating away.
- `AuthCubit` inside the shell listens for `AuthUnauthenticated` and redirects to login.
- All page transitions use `_buildTransitionPage` (fade + slight upward slide).

**Passing data via GoRouter:** multi-param routes (response, chat) receive `state.extra as Map<String, dynamic>`; single-param routes (breathing, affirmation) receive `state.extra as String`.

## Data patterns

- **Remote** — `MoodEntryModel` uses `@JsonSerializable()` with a generated `.g.dart` file; run `build_runner` after model changes.
- **Local** — Hive for mood history (`MoodLocalDatasource`) and saved quotes (`SavedQuotesLocalDatasource`); Hive adapters are also generated via `hive_generator`.
- **Return type** — repositories and use cases return `Either<Failure, T>` from `dartz`. Cubits fold the `Either` and emit typed states.
- **Exception — `WeeklyLetterCubit`**: registered with a datasource directly (`sl<MoodRemoteDatasource>()`), not via a use case. This bypasses the normal domain layer; do not follow this pattern for new features.

## Backend API

Base URL: `https://web-production-f8628.up.railway.app`

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/therapist/generate/` | Generate AI response for emoji + thoughts |
| GET | `/api/therapist/history/?user_id=` | Fetch user's mood history |
| GET | `/api/therapist/weekly-letter/` | Get AI weekly reflection |

## Theme & typography

Light and dark themes defined in `AppTheme`. Extra semantic colors (mood colours, surface variants) live in `AppExtraColors` — a `ThemeExtension` accessed via `Theme.of(context).extension<AppExtraColors>()`.

**Two text style systems exist — pick the right one:**

| Class | Scaling | When to use |
|---|---|---|
| `AppTextStyles` | Own `_scale()` helper: `size * (width / 390).clamp(0.85, 1.2)` | Newer screens (splash, onboarding, auth) |
| `ThemeTextStyles` | `flutter_screenutil .sp` | Older feature screens (home, journal, etc.) |

**Fonts:**
- **Nunito** (bundled, primary body/UI) and **DMSerifDisplay** (bundled, display/italic headings)
- **DM Sans** and **DM Serif Display** also loaded via `GoogleFonts.pendingFonts()` in `main()`
- `AppFonts.mainFontName` is used in `ThemeTextStyles`
- `ThemeTextStyles` already includes `fontFamilyFallback` with emoji fallbacks — always include them in any `TextStyle` that may render emoji

## Onboarding feature

`features/onboarding/presentation/` is **presentation-only** — no domain or data sub-folders exist or are needed.

Key files:
- `constants/onboarding_constants.dart` — all sizing fractions, animation durations, and the 3-page content list (`OnboardingConstants.pages`).
- `models/onboarding_page_data.dart` — `OnboardingPageData` + `OnboardingIllustrationVariant` enum.
- `widgets/onboarding_wave_painter.dart` — `CustomPainter` for the blob background.
- `widgets/onboarding_luna_painter.dart` / `onboarding_luna_animated.dart` — Luna character illustration.
- `widgets/onboarding_chat_painter.dart` — typing-indicator chat bubble for the `speechBubble` variant.
- `widgets/onboarding_plant_painter.dart` — sprout illustration for the `sprout` variant.
- `widgets/onboarding_illustration.dart` — composes the right painter based on `OnboardingIllustrationVariant`.
- `screens/onboarding_screen.dart` — `StatefulWidget` owning `PageController`; calls `OnboardingPrefs.markSeen()` then `context.go(AppRoutes.loginScreen)` on finish/skip.

**Sizing convention:** uses `MediaQuery.sizeOf(context)` multiplied by fraction constants in `OnboardingConstants` — **not** `flutter_screenutil`. Keep this consistent when editing onboarding UI.

---

# Section A — General Engineering Rules

## 1) Architecture & Separation of Concerns (YOU MUST FOLLOW)
- Follow the project's architecture layer boundaries strictly: presentation → domain → data
- Never bypass layers or mix responsibilities
- UI/presentation layer has ZERO business logic — only rendering, interaction, and state observation
- Business logic lives in the domain layer
- Data access (APIs, databases, storage) lives in the data layer
- Do not introduce new abstractions or patterns without justification

## 2) Shared Code (IMPORTANT)
- Any reusable logic, utility, constant, extension, or helper used in 2+ places goes in `core/`
- Check `core/` before creating new shared code — never duplicate across features

## 3) Error Handling
- Errors flow cleanly across layers — never skip layers
- Handle null, empty, loading, and error states explicitly — no silent failures
- Catch errors at the boundary (data layer), not deep inside business logic

## 4) Change Discipline
- Make the smallest change that solves the problem
- Fix root causes, not symptoms
- Don't refactor unrelated code unless explicitly requested
- Never break existing functionality, APIs, flows, or UX unless explicitly instructed
- Read relevant code before modifying it — state assumptions when unclear

## 5) Dependencies
- Don't add new packages without justification
- Any new package must be: latest stable, well-maintained, production-grade

## 6) Security
- Validate all external and API input
- Proactively flag security risks when spotted

## 7) Testing
- Write tests for domain and data layer logic
- Bug fixes must include a reproducing test
- Tests must be deterministic — no flaky or timing-dependent tests
- One behavior per test case

## 8) Workflow (Mandatory)
- Before creating any new feature → invoke the `/flutter-feature` skill first for scaffolding and architecture reference
- Before marking any task done → run the `/flutter-code-review` skill
- After task approved → use the `@git-expert` agent for branch, commit, and PR output

## 9) Agents — Proactively Suggest (YOU MUST FOLLOW)
You MUST proactively suggest the appropriate agent when the situation matches. Do not wait for the user to ask.

- `@debugger` — When a bug, crash, error, or unexpected behavior is encountered
- `@code-reviewer` — After `/flutter-code-review` passes, ALWAYS suggest running `@code-reviewer` for a deeper independent review before proceeding to PR
- `@test-writer` — When code is changed or added without corresponding tests, or when test coverage is missing
- `@git-expert` — When it's time to create a branch, commit, or PR. Also for merge conflicts, rebases, or any complex git situation

---

# Section B — Flutter / Dart Specific Rules

## 1) State Management
- Use **Cubit/Bloc** for feature and application state — not Riverpod, Provider, or GetX
- Cubits depend ONLY on use cases — never directly on repositories or data sources
- `setState` is allowed ONLY for local UI state (e.g., toggles, form focus) — never for business logic
- Keep `setState` scoped to the smallest widget possible to avoid redundant rebuilds up the tree

## 2) Code Generation
- **No Freezed.** Use Dart 3+ native `sealed class` + exhaustive `switch` for state unions.
- `json_serializable` and `hive_generator` **are** used — run `build_runner` after changing any annotated model.
- Never manually edit `.g.dart` files.

## 3) Domain Layer Purity
- Domain layer must have ZERO Flutter imports
- No `package:flutter/...` in any file under `domain/`

## 4) Feature Folder Structure
- `features/{feature_name}/data/`
- `features/{feature_name}/domain/`
- `features/{feature_name}/presentation/`

## 5) Error Handling Contract
- Data layer: catch exceptions and map to typed `Failure` classes (`core/errors/failures.dart`)
- Domain layer: return `Either<Failure, T>` (dartz) from use cases and repositories
- Presentation layer: fold the `Either` in the cubit; emit typed states; map to user-friendly UI

## 6) Dependency Injection
- Use **`get_it`** (`sl`) as the service locator
- Register all dependencies in `core/injection/injection.dart` — nowhere else
- Cubits are `registerFactory`; singletons/services are `registerLazySingleton`
- **Exception:** `MoodCubit` is `registerLazySingleton` (singleton shared across tabs)
- Cubits, use cases, and repositories are resolved via `sl<T>()`, not instantiated manually

## 7) Build Method Discipline (IMPORTANT)
- Prefer `const` constructors wherever possible
- NEVER create `TextEditingController`, `AnimationController`, `FocusNode`, or other expensive objects inside `build()`
- Avoid heavy work inside `build()` methods
- Dispose controllers and focus nodes in `StatefulWidget.dispose()`
- Prefer small, composed widgets to minimize rebuild scope
- Use `BlocBuilder`/`BlocSelector` on the smallest widget that needs the state — never at the top of the tree

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->
