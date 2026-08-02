# Quickstart: Validate Mood Choice Menu for All Moods

## Prerequisites

- Flutter toolchain set up for this project (see root `CLAUDE.md` Commands section)
- A connected device/simulator or `flutter run -d ios` / `-d android`

## Automated validation

```bash
flutter test test/features/home/presentation/widgets/mood_input_section_test.dart
flutter analyze
```

Expected: all tests pass; `flutter analyze` reports no new issues, and the edited file
(`lib/features/home/presentation/widgets/mood_input_section.dart`) stays ≤140 lines.

## Manual validation (golden path)

1. `flutter run`
2. On the home screen, select a **positive/neutral** mood (e.g. Happy 😊 or Calm 😌).
3. Enter any thoughts text and submit.
4. **Expected**: the mood-choice dialog appears (Talk to Luna / Breathe / Draw / Sudoku)
   — the same dialog previously only seen for angry/anxious/scared/burnout.
5. Tap "Talk to Luna". **Expected**: proceeds to the affirmation screen exactly as it
   does today when triggered from a distressing mood.
6. Repeat step 2 with a **distressing** mood (e.g. Angry 😠). **Expected**: identical
   dialog and behavior as before this change — no regression.

## Edge cases to spot-check

- Dismiss the dialog (tap outside) after a positive mood — app returns to home with
  draft cleared, same as the existing distressing-mood dismiss behavior.
- Pick Breathe / Draw / Sudoku from a positive-mood submission — each opens the same
  screen it already opens for distressing moods, with the same `emoji`/`thoughts`
  extras passed through.
