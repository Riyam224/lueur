# Contract: Language Repository / Use Cases

This feature exposes no external API — the "contract" here is the internal domain-layer interface that the presentation layer (`LanguageCubit`) depends on, per the constitution's cubit → use case → repo → datasource rule.

## `LanguageRepository` (domain interface)

```dart
abstract class LanguageRepository {
  Future<Either<Failure, AppLanguage>> getLanguage();
  Future<Either<Failure, void>> setLanguage(AppLanguage language);
}
```

- `getLanguage()`: reads the persisted preference. Resolves to `Right(AppLanguage.en)` when nothing valid is stored (never `Left` for "not found" — absence is not a failure, it's the default). Only resolves `Left(Failure)` for a genuine storage-layer failure (e.g., `shared_preferences` plugin unavailable).
- `setLanguage(AppLanguage)`: persists the given language. Resolves `Right(null)` on success, `Left(Failure)` on a storage-layer failure.

## Use Cases

```dart
class GetLanguagePreferenceUseCase {
  final LanguageRepository _repository;
  GetLanguagePreferenceUseCase(this._repository);
  Future<Either<Failure, AppLanguage>> call() => _repository.getLanguage();
}

class SetLanguagePreferenceUseCase {
  final LanguageRepository _repository;
  SetLanguagePreferenceUseCase(this._repository);
  Future<Either<Failure, void>> call(AppLanguage language) =>
      _repository.setLanguage(language);
}
```

## Consumer contract (`LanguageCubit`)

- On construction / app start: calls `GetLanguagePreferenceUseCase`, folds the result — `Left` or absent → emit `Locale('en')`; `Right(lang)` → emit the corresponding `Locale`. Guarded with `if (isClosed) return;` before the emit, per codebase convention (not `mounted`).
- `changeLanguage(AppLanguage language)`: calls `SetLanguagePreferenceUseCase(language)`; on `Right`, emits the new `Locale`; on `Left`, the cubit does not change state (UI remains on the previous language) — no silent partial application of a language switch that failed to persist.

## Data source contract (`LanguageLocalDatasource`)

```dart
abstract class LanguageLocalDatasource {
  Future<String?> getLanguageCode();       // raw "en"/"ar"/null — never throws for "missing"
  Future<void> setLanguageCode(String code); // throws on genuine plugin/storage error only
}
```

Implemented with `shared_preferences`, key `"preferred_language"`. Exceptions thrown by the plugin are caught here and mapped to `Failure` by the repository implementation (`LanguageRepositoryImpl`), per constitution Principle: "catch at the data layer boundary; map to typed `Failure` classes."
