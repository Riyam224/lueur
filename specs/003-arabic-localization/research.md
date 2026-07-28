# Phase 0 Research: Arabic Localization

## 1. Localization mechanism: `flutter gen-l10n` vs. hand-rolled string maps

**Decision**: Use Flutter's built-in `gen-l10n` tool (ARB files + generated `AppLocalizations` class), enabled via `generate: true` in `pubspec.yaml` and an `l10n.yaml` at the repo root.

**Rationale**: It's the official, zero-extra-dependency (beyond `flutter_localizations`/`intl`, both already required for `MaterialApp` locale support) path recommended by the Flutter team. It integrates with `MaterialApp.router`'s `localizationsDelegates`/`supportedLocales` with no extra glue code, generates compile-time-checked accessors (`AppLocalizations.of(context)!.settingsTitle`), and supports RTL automatically once `ar` is declared as a supported locale (Flutter's `GlobalMaterialLocalizations`/`GlobalWidgetsLocalizations` delegates already know Arabic is RTL).

**Alternatives considered**:
- Hand-rolled `Map<String, Map<String,String>>` lookup (like the existing `AppStrings` class, extended with a language parameter): rejected — reinvents what `gen-l10n` already does, no compile-time key checking, and would require manually wiring RTL detection instead of getting it for free from `Locale('ar')`.
- Third-party packages (`easy_localization`, `slang`, etc.): rejected per constitution Principle IV (minimal footprint / no new package without justification) — `gen-l10n` needs no extra package beyond the two Flutter/Dart-team-maintained ones already required for locale support at all.

## 2. Persisting the language preference: `shared_preferences` vs. Hive

**Decision**: `shared_preferences`, storing a single string key `"preferred_language"` with value `"en"` or `"ar"`.

**Rationale**: Explicitly required by the task instructions. It's simple, well-maintained (Flutter-team-owned plugin), and appropriate for a single scalar preference — no need for Hive's typed-box/adapter machinery for one string.

**Alternatives considered**:
- Hive (`Hive.box<String>` under a new box, matching `ThemeCubit`'s `Hive.box<bool>` pattern): this would be more consistent with the app's existing convention (documented as the deviation in plan.md's Complexity Tracking), but was explicitly overridden by the user's instruction. Not pursued.

## 3. Domain-layer representation of the language preference

**Decision**: A plain enum `AppLanguage { en, ar }` lives in `domain/entities/app_language.dart` (zero Flutter imports — an enum is pure Dart). The datasource/repository read and write a raw `String` ("en"/"ar") and the domain layer maps it to/from `AppLanguage`. Only the presentation-layer `LanguageCubit` converts `AppLanguage` to a `dart:ui`/Flutter `Locale` for `MaterialApp`.

**Rationale**: Keeps `Locale` (a Flutter-adjacent type) entirely out of `domain/`, satisfying constitution Principle II (domain layer purity — zero Flutter imports). Mirrors how other cubits in this codebase keep framework types (`ThemeMode`, `Locale`) at the cubit/presentation boundary while domain layer works with plain values.

**Alternatives considered**: Using `Locale` directly in the domain layer — rejected, would violate domain purity since `Locale` comes from `dart:ui`, which the constitution treats as part of the Flutter/framework surface that domain code must not depend on (consistent with how `ThemeMode` is never referenced below the cubit layer in this codebase either).

## 4. String extraction scope

**Decision**: Extract all `static const String` entries in `lib/core/utils/app_strings.dart` (222 entries, confirmed via `grep`) into `app_en.arb`/`app_ar.arb` keys, using the existing `AppStrings` field names (camelCase, already descriptive, e.g. `profileSettingsAppearance`) as ARB keys directly — no renaming needed. Additionally, a repo-wide search found 5 additional files containing inline `Text('...')`/`Text("...")` literals outside `app_strings.dart`; these must be located during implementation (Phase 2 tasks) and migrated the same way.

**Rationale**: Reusing `AppStrings`' existing field names as ARB keys avoids inventing a second naming scheme and makes the diff mechanically traceable (call sites change from `AppStrings.x` to `AppLocalizations.of(context)!.x`). Minimal footprint per constitution Principle IV.

**Alternatives considered**: Re-keying strings by screen/feature namespace (e.g. `settings.appearance`) — rejected as unnecessary churn; ARB keys don't support dots as namespacing in the generated Dart class anyway (they become flat method names), and the existing names are already sufficiently descriptive.

## 5. RTL layout handling

**Decision**: Do not add any manual `Directionality` widget. Declare `supportedLocales: [Locale('en'), Locale('ar')]` and the three standard `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate` delegates (plus the generated `AppLocalizations.delegate`) on `MaterialApp.router`. Flutter's `MaterialApp`/`WidgetsApp` automatically derives `Directionality` from the active `Locale` via `GlobalWidgetsLocalizations`, so every `Directionality.of(context)`-aware widget (Row, Padding.directional, Icons via `Directionality`-aware assets, etc.) flips automatically.

**Rationale**: Matches the explicit instruction "don't manually force Directionality unless needed" — and it isn't needed since `Locale('ar')` alone is sufficient for Flutter's framework-level RTL support.

**Alternatives considered**: Wrapping the app in an explicit `Directionality` widget keyed off the cubit state — rejected as redundant and a common source of bugs (two sources of truth for direction: the widget and the locale) when `MaterialApp` already derives it correctly from `locale`.

## 6. Cubit registration lifetime: `registerLazySingleton` vs. `registerFactory`

**Decision**: `registerLazySingleton`, matching the existing documented exception for `MoodCubit` (and precedent of `ThemeCubit`, which is also a singleton despite not being explicitly called out as an "exception" in CLAUDE.md).

**Rationale**: The language preference is app-wide state that must be shared across the entire widget tree (via a single `BlocProvider.value` near the root in `core/app.dart`, alongside the existing `ThemeCubit` provider) — a new instance per screen would fragment state and break locale consistency across the shell's tabs, exactly the reasoning already documented for why `MoodCubit` is a singleton.

**Alternatives considered**: `registerFactory` (the default for cubits per constitution) — rejected because it would create a fresh, unsynced `LanguageCubit`/`Locale` instance wherever it's injected, which is incompatible with a single global `MaterialApp.locale` needing one authoritative source of truth.
