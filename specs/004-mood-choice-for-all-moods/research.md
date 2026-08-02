# Phase 0 Research: Mood Choice Menu for All Moods

No `[NEEDS CLARIFICATION]` markers remain in the spec, and the Technical Context has
no unresolved unknowns — this is a small, well-understood change in an existing
codebase. Research here is scoped to confirming the exact current behavior so the
plan/tasks are accurate.

## Decision: Remove the `isLowMood` branch entirely, don't add a new flag

**Rationale**: `lib/features/home/presentation/widgets/mood_input_section.dart`
(`_onTalkToLuna`, lines ~104-122) currently does:

```dart
if (selectedMood.isLowMood) {
  context.read<MoodCubit>().addLocalEntry(emoji: emojiUnicode, thoughts: thoughts);
  showMoodChoiceDialog(context, emoji: emojiUnicode, thoughts: thoughts);
} else {
  context.push(AppRoutes.response, extra: {
    'emojiPath': null,
    'emojiUnicode': emojiUnicode,
    'thoughts': thoughts,
  });
}
```

The spec (FR-001) requires the dialog for every mood. The simplest, smallest change
(constitution Principle IV) is to always take the `isLowMood` branch's body and delete
the `else`. This also naturally satisfies FR-004 (mood entry saved locally before the
dialog shows) since `addLocalEntry` already happens first in that branch.

**Alternatives considered**:
- *Keep the branch but flip the condition to always true* — rejected, dead code/misleading
  conditional left behind; violates Minimal Footprint.
- *Add a new "always show chooser" config flag* — rejected, no evidence any caller needs
  the old skip-to-response behavior; the spec explicitly says this is being removed
  (see spec Assumptions), so a flag would be unused complexity.
- *Move the branching into `MoodChoiceDestination` or a new use case* — rejected, this is
  a UI navigation choice with no business/domain logic, so it stays in the presentation
  widget per Clean Architecture (only rendering/interaction/state observation there).

## Decision: `MoodType.isLowMood` stays, unused by this call site but keep it

**Rationale**: `isLowMood` (in `lib/core/models/mood_type.dart`) is a general-purpose
classifier. Grep confirms `mood_input_section.dart` is its only current call site, but
the spec's Edge Cases explicitly preserve any existing low-mood-specific routing nuance
(e.g., a breathing pre-step) — none currently exists beyond the removed branch, so no
other code depends on it. Removing the getter is out of scope: it is a reusable
classification concept in `core/`, not implementation detail of this one call site, and
deleting it is not requested by the spec. Leaving it also avoids an unrelated
public-API-removal risk in a change meant to be minimal.

**Alternatives considered**: Deleting `isLowMood` since it becomes unused — rejected,
out of scope per Minimal Footprint (don't remove things beyond what's needed to satisfy
the spec) and risks being a silent behavior-changing surprise if anything else is added
later that wants it.

## Decision: No test-framework or dependency changes needed

**Rationale**: The project already uses `flutter_test` (see `test/features/auth/` and
`CLAUDE.md` commands: `flutter test`). A widget test for `mood_input_section.dart`
follows the same pattern as existing tests under `test/features/`.

**Alternatives considered**: N/A — no new tooling required.
