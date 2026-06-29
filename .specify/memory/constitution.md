<!--
SYNC IMPACT REPORT
==================
Version change: (none) → 1.0.0 (initial ratification)
Modified principles: N/A — first issue
Added sections:
  - Core Principles (I–V)
  - Flutter & Dart Standards
  - Development Workflow
  - Governance
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ no changes needed — Constitution Check section is generic
  - .specify/templates/spec-template.md ✅ no changes needed — structure is generic
  - .specify/templates/tasks-template.md ✅ Mobile path conventions already present
Deferred TODOs: none
-->

# MindEase Constitution

## Core Principles

### I. Clean Architecture (NON-NEGOTIABLE)

Every feature MUST follow strict layer separation: **presentation → domain → data**.
Layers MUST NOT be bypassed or have their responsibilities mixed.
The UI/presentation layer MUST contain zero business logic — only rendering, interaction,
and state observation are permitted there.
Business logic lives exclusively in the domain layer.
Data access (APIs, databases, local storage) lives exclusively in the data layer.

**Rationale**: Enforcing layer boundaries keeps each layer independently testable,
replaceable, and comprehensible. Violations create hidden coupling that makes
refactoring and debugging exponentially harder over time.

### II. Domain Layer Purity (NON-NEGOTIABLE)

The domain layer MUST have zero Flutter imports. No `package:flutter/...` is permitted
in any file under `domain/`. Repositories and use cases MUST return `Either<Failure, T>`
(dartz). Cubits fold the `Either` and emit typed states — they MUST NOT expose raw
`Either` values to the UI.

**Rationale**: Framework-free domain logic can be tested with plain Dart unit tests,
run on any platform, and understood without Flutter knowledge. Leaking Flutter into
the domain layer destroys this guarantee.

### III. Cubit/Bloc State Management (NON-NEGOTIABLE)

Feature and application state MUST be managed with Cubit or Bloc.
Riverpod, Provider, GetX, and other state-management libraries are prohibited.
Cubits MUST depend only on use cases — never directly on repositories or data sources.
`setState` is permitted ONLY for local UI state (e.g., animation toggles, form focus)
and MUST be scoped to the smallest widget possible.

**Rationale**: A single state-management approach across the codebase reduces cognitive
overhead, makes state transitions auditable, and keeps business logic out of widgets.

### IV. Minimal Footprint

Every change MUST be the smallest modification that solves the stated problem.
New abstractions, patterns, or dependencies MUST NOT be introduced without explicit
justification. Three similar lines are preferable to a premature abstraction.
New packages MUST be: latest stable, well-maintained, and production-grade.

**Rationale**: Complexity is the primary source of defects and maintenance burden.
Features are added for users, not for engineering elegance.

### V. Test Coverage for Domain & Data

Tests MUST be written for all domain and data layer logic.
Bug fixes MUST include a reproducing test.
Tests MUST be deterministic — timing-dependent or flaky tests are prohibited.
Each test MUST cover one behavior.

**Rationale**: Presentation layer correctness is verified by manual/automated UI testing;
domain and data layers have no visual output and MUST be verified by automated tests.

## Flutter & Dart Standards

- Use Dart 3+ native `sealed class` + exhaustive `switch` for state unions. **No Freezed.**
- `json_serializable` and `hive_generator` are the approved code-generation tools.
  Run `dart run build_runner build --delete-conflicting-outputs` after changing any
  annotated model. Never manually edit `.g.dart` files.
- `const` constructors MUST be used wherever possible.
- `TextEditingController`, `AnimationController`, `FocusNode`, and other stateful objects
  MUST NOT be created inside `build()`. They MUST be initialised in `initState()` and
  disposed in `dispose()`.
- `BlocBuilder`/`BlocSelector` MUST be placed on the smallest widget that needs the state —
  never at the top of the widget tree.
- Any `TextStyle` that may render emoji MUST include
  `fontFamilyFallback: ['NotoColorEmoji']` because Urbanist has no emoji glyphs.
- All dependencies are registered in `core/injection/injection.dart` exclusively.
  Cubits are `registerFactory`; singletons/services are `registerLazySingleton`.
- All routes are defined in `core/routing/router_generation_config.dart`.
  `BlocProvider` for screen-scoped cubits goes here, not inside screens.
- Shared utilities, constants, extensions, or helpers used in 2+ places MUST live in
  `core/`. Always check `core/` before creating new shared code.

## Development Workflow

- Before creating any new feature: invoke `/flutter-feature` for scaffolding and
  architecture reference.
- Before marking any task done: run `/flutter-code-review`.
- After review passes: use `@code-reviewer` for an independent review, then
  `@git-expert` for branch, commit, and PR.
- Errors MUST flow cleanly across layers. Catch at the data layer boundary; map to
  typed `Failure` classes (`core/errors/failures.dart`). Never catch deep inside
  business logic.
- Secrets, tokens, and credentials MUST NOT be hardcoded or logged.
- All external and API input MUST be validated at the boundary.
- Feature folder structure is always:
  `features/{feature_name}/data/`, `features/{feature_name}/domain/`,
  `features/{feature_name}/presentation/`.
- Onboarding is presentation-only (no domain/data sub-folders) and uses
  `MediaQuery.sizeOf(context)` multiplied by fraction constants — not `flutter_screenutil`.

## Governance

This constitution supersedes all other stated practices. Any conflict between this
document and other guidelines resolves in favour of the constitution.

**Amendment procedure**:
1. Propose the amendment in a PR description with rationale.
2. Increment `CONSTITUTION_VERSION` according to semantic versioning:
   - MAJOR: backward-incompatible removal or redefinition of a principle.
   - MINOR: new principle or section added, or materially expanded guidance.
   - PATCH: clarifications, wording fixes, non-semantic refinements.
3. Update `LAST_AMENDED_DATE` to the amendment date (ISO 8601).
4. Run consistency propagation: update `.specify/templates/` files if any
   principle-driven sections changed.

**Compliance**: All PRs MUST be verified against this constitution before merge.
Complexity violations (e.g., a fourth project, an extra abstraction layer) MUST be
justified in the plan's Complexity Tracking table.

**Runtime guidance**: See `CLAUDE.md` for agent-specific development guidance.

---

**Version**: 1.0.0 | **Ratified**: 2026-06-27 | **Last Amended**: 2026-06-27
