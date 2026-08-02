# Implementation Plan: Mood Choice Menu for All Moods

**Branch**: `main` (no feature branch created — no git-extension hook configured) | **Date**: 2026-08-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/004-mood-choice-for-all-moods/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Today `_MoodInputSectionState._onTalkToLuna` in
`lib/features/home/presentation/widgets/mood_input_section.dart` branches on
`selectedMood.isLowMood`: only the four distressing moods (angry, anxious, scared,
burnout) call `showMoodChoiceDialog` (Talk to Luna / Breathe / Draw / Sudoku); every
other mood routes straight to the response screen. The fix removes that branch so
`showMoodChoiceDialog` is always shown, for every mood, before proceeding — with zero
changes to the dialog itself (`mood_choice_dialog.dart`) or to what each choice does
once picked. This is a presentation-layer-only change; no domain/data code, no new
abstractions, no new dependencies.

## Technical Context

**Language/Version**: Dart 3+ / Flutter (existing project toolchain, no version change)

**Primary Dependencies**: `flutter_bloc` (existing `MoodCubit`), `go_router` (existing
`AppRoutes`) — no new packages

**Storage**: N/A — no data-layer or persistence change; `MoodCubit.addLocalEntry` call
is unchanged

**Testing**: `flutter_test` + `bloc_test`/widget tests, per project convention
(`test/features/...`)

**Target Platform**: iOS + Android + macOS (existing Flutter app)

**Project Type**: mobile-app (single Flutter project, Clean Architecture)

**Performance Goals**: N/A — no new async work; behavior change is purely a removed
conditional

**Constraints**: Touched/added files MUST stay ≤140 lines (per FR-005); no visual/UX
change to the existing chooser dialog (per FR-002)

**Scale/Scope**: One conditional in one presentation widget; optionally a widget test
addition under `test/features/home/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Clean Architecture** — PASS. Change is entirely within
  `presentation/widgets/mood_input_section.dart`; no domain/data layer touched, no
  layer bypassed.
- **II. Domain Layer Purity** — PASS (not applicable; no domain files touched).
- **III. Cubit/Bloc State Management** — PASS. `MoodCubit.addLocalEntry` call and
  `setState` usage for local UI (`_selectedMood`, `_thoughtsController`) are unchanged;
  no new state-management pattern introduced.
- **IV. Minimal Footprint** — PASS. The implementation is a conditional removal
  (deleting the `if (selectedMood.isLowMood) { ... } else { ... }` branch in favor of
  always calling `showMoodChoiceDialog`), not a new abstraction. No new package.
- **V. Test Coverage for Domain & Data** — N/A for this change (no domain/data logic
  added); a presentation widget test is added instead per project testing norms, not
  because the constitution mandates it for UI code.

No violations. Complexity Tracking table is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/004-mood-choice-for-all-moods/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md         # Phase 1 output (/speckit-plan command) — N/A, no entities change
├── quickstart.md         # Phase 1 output (/speckit-plan command)
├── contracts/             # Phase 1 output — skipped, no external interface
└── tasks.md              # Phase 2 output (/speckit-tasks command - NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── models/
│       ├── mood_type.dart                 # isLowMood getter — read, unchanged
│       └── mood_choice_destination.dart   # unchanged
└── features/
    ├── home/
    │   └── presentation/
    │       └── widgets/
    │           └── mood_input_section.dart   # ONLY file with behavior change
    └── mood_choice/
        └── presentation/
            └── widgets/
                └── mood_choice_dialog.dart   # read-only reference, unchanged

test/
└── features/
    └── home/
        └── presentation/
            └── widgets/
                └── mood_input_section_test.dart   # new/updated widget test
```

**Structure Decision**: Single Flutter mobile app (existing Clean Architecture
feature-folder layout). This feature requires no new folders — it is a one-file
behavioral edit inside the existing `home` feature's presentation layer, verified by
a widget test in the existing `test/features/` tree.

## Complexity Tracking

*No violations — table not needed.*
