# Quickstart: Journal Card Shows Latest Activity Only; Timeline Shows Full Day

## Prerequisites

- App running with a test/guest account that has at least one existing mood entry (or a
  fresh account — you'll create entries below).
- `flutter run` on a simulator/device.

## Scenario 1 — Journal card shows only the latest activity (US1)

1. Log a mood check-in on Home (any mood + a written reason), submit.
2. From the mood-choice dialog, pick "Breathe" and complete (or skip through) the breathing
   exercise so it logs a `breathing` entry for the same day.
3. Open the Journal tab.
4. **Expected**: the day's card shows only the breathing activity (its icon/label + date) —
   no mood emoji, no written reason, and no small dots/lines hinting at another activity.

Cross-check (regression): a day with only a mood check-in (no follow-up activity) still shows
the mood + reason on its card exactly as before.

## Scenario 2 — Tapping a Journal card opens Timeline, scrolled to that day (US2)

1. From Journal, tap the card produced in Scenario 1.
2. **Expected**: Timeline screen opens, already scrolled so that day's entry is visible
   without manual scrolling.
3. Go back, tap Journal's "view full timeline" link instead.
4. **Expected**: Timeline opens at the top (most recent), unchanged from current behavior.

## Scenario 3 — Timeline shows every activity for a day (US3)

1. On the day from Scenario 1, complete a second activity (e.g. a Sudoku puzzle), so that day
   now has: mood check-in, breathing, sudoku.
2. Open Timeline and find that day's entry.
3. **Expected**: the mood, the written reason, "took a breather", and "played a puzzle" (or
   "— solved!") are all visible for that single day's entry — not summarized into one line.
4. Tap the "played a puzzle" line.
5. **Expected**: navigates into the Sudoku screen (unchanged tap-through behavior, FR-006).

## Scenario 4 — Same-type activities aren't silently dropped (edge case, US3)

1. On one day, complete two separate breathing sessions (e.g. morning and evening).
2. Open Timeline for that day.
3. **Expected**: both breathing sessions appear as separate rows (previously, only one would
   show due to type-based deduplication — this is the bug this feature also fixes).

## Automated checks

```bash
flutter analyze
flutter test test/features/journal/
```

Both must be clean/passing before this feature is considered done (see tasks.md Phase 4).
