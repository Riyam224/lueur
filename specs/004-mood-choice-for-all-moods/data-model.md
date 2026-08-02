# Phase 1 Data Model: Mood Choice Menu for All Moods

No entities are added, removed, or modified by this feature. It is purely a
presentation-layer navigation change.

## Existing entities referenced (unchanged)

- **`MoodEntry`** (`lib/core/models/mood_entry.dart`) — persisted via
  `MoodCubit.addLocalEntry(emoji, thoughts)`. Save timing/fields are unchanged; only
  which moods reach `showMoodChoiceDialog` afterward changes.
- **`MoodType`** (`lib/core/models/mood_type.dart`) — the 13-value enum and its
  `isLowMood` getter are unchanged. `isLowMood` simply stops being read at the one
  call site being modified.
- **`MoodChoiceDestination`** (`lib/core/models/mood_choice_destination.dart`) — the
  4-value enum (`talkToLuna`, `breathing`, `freeDraw`, `sudoku`) is unchanged; it is
  now reachable from more mood submissions, but its own values/behavior don't change.

## State transitions

No new states. The existing transition
`mood submitted → [isLowMood? dialog : response screen]`
becomes
`mood submitted → dialog` (unconditionally), with the dialog's own choices
(`talkToLuna` / `breathing` / `freeDraw` / `sudoku`) driving subsequent navigation
exactly as they already do today.
