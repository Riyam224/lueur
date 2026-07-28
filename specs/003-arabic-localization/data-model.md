# Phase 1 Data Model: Arabic Localization

## Entity: Language Preference

The user's chosen display language and, derived from it, the app's text direction. Single-valued, device-local, no relationships to other entities.

### Representation by layer

| Layer | Type | Notes |
|---|---|---|
| Data (storage) | `String` (`"en"` \| `"ar"`) | Raw value persisted in `shared_preferences` under key `preferred_language`. Any other/missing value is treated as absent. |
| Domain | `enum AppLanguage { en, ar }` | Pure Dart, zero Flutter imports. Datasource/repository translate the raw string to/from this enum; an unrecognized stored string maps to `null`/absent rather than throwing. |
| Presentation | `Locale` (`dart:ui`) | `LanguageCubit`'s state. `AppLanguage.en` → `Locale('en')`, `AppLanguage.ar` → `Locale('ar')`. This is the only layer where `Locale` appears. |

### Fields

- **value**: `AppLanguage` — `en` or `ar`. No other values are valid in this phase (spec explicitly scopes to these two).
- **direction** (derived, not stored): `TextDirection.ltr` for `en`, `TextDirection.rtl` for `ar`. Never persisted — always computed from `value` at read time by Flutter's locale-aware widgets (`GlobalWidgetsLocalizations`), not by app code.

### Validation rules

- On read: if the stored string is missing, empty, or not one of `"en"`/`"ar"`, the datasource returns `null` (absent), and the repository/use case resolves this to the default (`AppLanguage.en`) rather than surfacing an error to the UI. This satisfies FR-010 (invalid/corrupt preference falls back to English without crashing).
- On write: only `AppLanguage.en` or `AppLanguage.ar` can be persisted — the cubit's public API (`changeLanguage(AppLanguage)`) is enum-typed, so an invalid value can't be written by construction.

### State transitions

```text
[App start] --read preference--> (found "en"/"ar") --> LanguageCubit emits Locale(that value)
                                 (missing/invalid)  --> LanguageCubit emits Locale('en')  [default]

[Settings toggle] --user selects language--> write preference --> LanguageCubit emits Locale(selected)
```

There is no intermediate "loading" state modeled for the language preference itself — the read is a fast local `shared_preferences` lookup, not a network call, so `LanguageCubit`'s state is the `Locale` directly (not a sealed-class union with `Loading`/`Error`/`Loaded` variants like `AuthState`). This mirrors `ThemeCubit`, whose state is `ThemeMode` directly for the same reason (fast, synchronous-feeling local read).

## Contracts

See [contracts/language_repository.md](./contracts/language_repository.md) for the repository/use-case interface contract (this project has no external API surface for this feature — it's entirely internal to the Flutter app, so no REST/GraphQL contract applies).
