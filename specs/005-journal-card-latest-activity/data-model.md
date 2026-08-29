# Phase 1 Data Model: Journal Card Shows Latest Activity Only; Timeline Shows Full Day

No persisted entities change. This feature only changes how existing presentation-layer
models are *consumed* by widgets. Documented here for completeness.

## Existing entities (unchanged)

### `MoodEntryEntity` (`lib/features/home/domain/entities/mood_entry_entity.dart`)

Already has everything this feature needs: `id`, `emoji`, `thoughts` (the user's written
reason), `aiResponse`, `createdAt`, `entryType` (`'mood_chat' | 'breathing' | 'sudoku' |
'drawing'`), `payload`. No fields added.

### `DayGroup` (`lib/features/journal/presentation/models/day_group.dart`)

```dart
class DayGroup {
  final DateTime date;
  final List<MoodEntryEntity> entries; // chronological, ascending

  MoodEntryEntity get representative => entries.last;      // REUSED — now also Journal's card entry
  MoodEntryEntity get primaryEntry => ...;                   // UNCHANGED — still Timeline's mood-biased card face
  Set<String> get activityTypes => ...;                      // no longer used by Journal (footer removed there)
  bool get pinned => ...;                                     // unchanged
  Duration? get conversationDuration => ...;                  // unchanged
}
```

No fields or getters are added to `DayGroup`. `representative` already existed (previously
used only for color/pin/delete target and `_openDay`'s `userId`/`emoji`) and is now also read
by Journal's recent-memories section to pick which entry to render as the card face.

## Changed call-site contracts (presentation widgets, not data)

### `journal_recent_memories_section.dart`

- Before: `group.primaryEntry.entryType == 'mood_chat' ? JournalGridCardWidget(entry:
  group.primaryEntry, ..., footer: JournalDayActivityDots(...)) : JournalActivityChoiceCard(entry:
  group.primaryEntry, footer: ...)`
- After: `group.representative.entryType == 'mood_chat' ? JournalGridCardWidget(entry:
  group.representative, ...) : JournalActivityChoiceCard(entry: group.representative)` — no
  `footer` argument passed (defaults to `null`).
- `onTap`/`onLongPress`: `onTap` now navigates to `AppRoutes.timeline` with `extra:
  group.date` instead of calling the existing `_openDay` (chat) helper. `onLongPress` (card
  options sheet — pin/recolor/delete) is unchanged, still keyed off `group.representative.id`
  (previously `group.primaryEntry.id`, since long-press options should act on the same entry
  the card now visually represents).

### `timeline_activity_description_row.dart`

- `TimelineActivityDescriptionRow` keeps its existing public constructor signature
  (`dayEntries`, `excludingType`, `maxWidth`) so `timeline_month_section_widget.dart` (its only
  caller) needs no changes beyond continuing to pass `group.primaryEntry.entryType` as before.
- Internal change only: replace the `byType` last-entry-wins map with a plain
  chronological iteration that renders one row per entry whose `id` differs from the
  excluded entry's `id` (the widget now takes the excluded entry's `id` internally via a
  small signature addition — see below — rather than only its type).

  **Signature change**: add an `excludingId` parameter (the primary/representative entry's
  `id`) alongside the existing `excludingType`, so the widget can exclude *that one entry*
  from the list while still rendering every other entry — including other entries that share
  its type. `excludingType` is kept for the one case where the primary card entry is itself
  the "extra" concept being deduped against nothing else (kept for backward call-site clarity,
  not removed to minimize churn at the one call site).

  ```dart
  class TimelineActivityDescriptionRow extends StatelessWidget {
    final List<MoodEntryEntity> dayEntries;
    final int excludingId;      // NEW — replaces type-based exclusion
    final double maxWidth;
    // ...
  }
  ```

  Call site update in `timeline_month_section_widget.dart`:
  `excludingId: group.primaryEntry.id` (was `excludingType: group.primaryEntry.entryType`).

### `router_generation_config.dart` / `timeline_screen.dart`

- `AppRoutes.timeline` route: `state.extra as DateTime?` read and passed to
  `TimelineScreen(initialFocusDate: extra)`.
- `TimelineScreen` gains an optional constructor parameter `initialFocusDate` (nullable,
  defaults to `null` — existing callers like the "view full timeline" link pass no extra and
  are unaffected). Internally, each day-group's rendered widget gets a `GlobalKey` derived
  from its `date`; on first frame, if `initialFocusDate` matches a built day group, the screen
  calls `Scrollable.ensureVisible` on that key.

## Validation rules

- No new validation — `representative`/`primaryEntry` are non-nullable and always resolvable
  for any non-empty `DayGroup` (a `DayGroup` is never constructed with an empty `entries`
  list, per `TimelineLayout.groupByDay`'s grouping logic).
