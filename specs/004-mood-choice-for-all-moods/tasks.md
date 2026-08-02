# Tasks: Mood Choice Menu for All Moods

**Input**: Design documents from `/specs/004-mood-choice-for-all-moods/`
**Prerequisites**: plan.md, research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested by the spec, but a widget test is included per the
project's existing `test/features/` convention and to guard the FR-001/FR-002/FR-003
behavior described in spec.md.

**Organization**: This feature has a single user story (P1) — there is only one
behavioral change (the mood-choice dialog now shows for all moods), so all tasks are
grouped under it.

## Phase 1: Setup

- [X] T001 Confirm `flutter analyze` and `flutter test` run clean on `main` before
      changes, as a baseline (no file changes; verification only)

## Phase 2: Foundational

*No foundational/blocking work — this feature touches one existing widget and adds one
test file; nothing shared needs to be built first.*

## Phase 3: User Story 1 - Choose a coping activity after any mood check-in (Priority: P1) 🎯 MVP

**Goal**: Make `showMoodChoiceDialog` (Talk to Luna / Breathe / Draw / Sudoku) appear
after every mood + thoughts submission, not just for angry/anxious/scared/burnout,
with zero change to the dialog itself or to what each choice does once picked.

**Independent Test**: Log a mood entry with a positive mood (e.g. "happy") and thoughts
text, submit, and confirm the mood-choice dialog appears exactly as it does today for
"angry", before proceeding to the affirmation screen.

### Tests for User Story 1

- [X] T002 [P] [US1] Write/extend widget test in
      `test/features/home/presentation/widgets/mood_input_section_test.dart` asserting
      that submitting a non-low mood (e.g. `MoodType.happy`) with the "Talk to Luna"
      thoughts action calls `showMoodChoiceDialog`-driven navigation (i.e. the dialog's
      `MoodChoiceDialog`/`_MoodChoiceCard` widgets, or the pushed `AppRoutes.affirmation`
      route once a choice is tapped) instead of pushing `AppRoutes.response` directly

### Implementation for User Story 1

- [X] T003 [US1] In `lib/features/home/presentation/widgets/mood_input_section.dart`,
      in `_onTalkToLuna`, remove the `if (selectedMood.isLowMood) { ... } else { ... }`
      branch and always run the current `if`-branch body (`MoodCubit.addLocalEntry`
      then `showMoodChoiceDialog`) for every mood; delete the now-unreachable
      `context.push(AppRoutes.response, ...)` `else` branch
- [X] T004 [US1] Remove the now-unused `AppRoutes` import from
      `lib/features/home/presentation/widgets/mood_input_section.dart` if
      `AppRoutes.response` was its only remaining use (check other usages in the file
      first — `go_router`'s `context.push`/`context.read` may still need other imports)
- [X] T005 [US1] Verify `lib/features/home/presentation/widgets/mood_input_section.dart`
      is still ≤140 lines after the edit (per FR-005); if not, this task is not
      independently completable without violating scope — flag rather than split into
      new files, since the spec requires a minimal, single-file behavioral change

**Checkpoint**: At this point, User Story 1 (the entire feature) should be fully
functional and independently testable via `flutter test` and the quickstart.md manual
steps.

## Phase 4: Polish & Cross-Cutting Concerns

- [X] T006 [P] Run `flutter analyze` and confirm no new lint issues were introduced
- [X] T007 [P] Manually validate both flows from `quickstart.md` (positive mood → dialog
      shown; distressing mood → unchanged behavior) on a simulator/device
- [X] T008 Re-run the full `flutter test` suite to confirm no regressions in other
      features that reference `mood_input_section.dart`, `MoodChoiceDestination`, or
      `MoodCubit.addLocalEntry`

## Dependencies & Execution Order

- **Phase 1 (Setup)** → **Phase 3 (US1)** → **Phase 4 (Polish)**. Phase 2 is empty for
  this feature.
- Within Phase 3: T002 (test) should be written before T003 (implementation) if
  following TDD; T003 must complete before T004/T005 (both operate on the same file
  T003 changed). T004 and T005 can be done together since they're both quick checks on
  the same already-edited file (not truly parallel-safe as `[P]` since they touch the
  same file — sequential is safer).
- Phase 4 tasks T006 and T007 are parallelizable with each other; T008 should run last.

## Parallel Example: User Story 1

```text
# T002 (new test file) can be written in parallel with nothing else in this feature,
# since T003 is the only other US1 task and it touches a different file:
Task T002: "Write widget test in test/features/home/presentation/widgets/mood_input_section_test.dart"
Task T003: "Edit lib/features/home/presentation/widgets/mood_input_section.dart"
```

## Implementation Strategy

### MVP = User Story 1 (the whole feature)

This feature has no meaningful smaller slice — Phase 3 alone delivers 100% of the
spec's scope. Complete Phase 1 → Phase 3 → Phase 4 in order; there is no incremental
multi-story rollout to plan.
