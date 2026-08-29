# Phase 0 Research: Journal Card Shows Latest Activity Only; Timeline Shows Full Day

All unknowns below were resolved by reading the existing implementation directly
(`lib/features/journal/presentation/`) rather than external research — this feature
changes existing, already-understood code paths.

## 1. Which entry should a Journal card render as "the latest activity"?

- **Decision**: Use `DayGroup.representative` (`entries.last`) as the entry Journal renders,
  replacing the current `DayGroup.primaryEntry` (which is biased toward the day's mood_chat
  entry even if a later activity exists).
- **Rationale**: `entries` is already sorted ascending by `createdAt`
  (`TimelineLayout.groupByDay`), so `.last` is already "the most recently logged entry that
  day" with zero new code — `representative` already exists on `DayGroup` and is unused by
  Journal today (only used for color/pin/delete target and `_openDay`'s `userId`/`emoji`).
- **Alternatives considered**: Adding a new `DayGroup.latestEntry` getter — rejected, it would
  be a duplicate of `representative` under a different name (violates Minimal Footprint).

## 2. How should the Journal card's footer (activity hints) be removed?

- **Decision**: Stop passing a `footer` to `JournalGridCardWidget`/`JournalActivityChoiceCard`
  from `journal_recent_memories_section.dart` entirely (omit the parameter — it already
  defaults to `null`).
- **Rationale**: `JournalBubbleContent`/`JournalActivityChoiceCard` already render nothing
  extra when `footer` is `null` — no widget changes needed, only the call site.
- **Alternatives considered**: Deleting `JournalDayActivityDots` outright — rejected; it
  becomes unused in production code by this change, but it's a small, self-contained, already
  green-tested widget. Removing it is out of scope for this feature (no functional benefit,
  extra risk) and left as a follow-up cleanup note rather than bundled here.

## 3. How should tapping a Journal card reach Timeline "scrolled to that day"?

- **Decision**: `AppRoutes.timeline`'s `GoRoute` reads `state.extra as DateTime?` (a
  single-value extra, consistent with the project's existing single-param route convention
  used by `breathing`/`affirmation`) and passes it to `TimelineScreen(initialFocusDate: ...)`.
  `TimelineScreen` attaches a `GlobalKey` to each day-group card it builds and, after first
  frame (`WidgetsBinding.instance.addPostFrameCallback`), calls
  `Scrollable.ensureVisible` on the key matching `initialFocusDate` if one was provided.
- **Rationale**: Journal's recent-memories section only ever renders the 3 most recent
  days, which are always the first month-section's first few cards in Timeline — so the
  target day's widget is guaranteed to already be built (Timeline's `SliverList` only lazily
  builds far-off month sections, not the first one) and `Scrollable.ensureVisible` works
  without needing to force-build offscreen content.
- **Alternatives considered**:
  - `scrollable_positioned_list` package (jump-to-index by list position) — rejected: new
    dependency for a problem already solvable with a `GlobalKey`, since the target is always
    near the top (Minimal Footprint).
  - Passing an entry `id` instead of a `DateTime` — rejected: `DayGroup` keys are dates, and
    matching by date is simpler and matches how Timeline already groups/filters
    (`TimelineLayout.matchesFilters` etc. all key off dates/day groups, not raw entry ids).

## 4. How should Timeline show literally every activity for a day, not one line per type?

- **Decision**: Change `TimelineActivityDescriptionRow` to iterate `dayEntries` in
  chronological order and render one row per entry whose type != `excludingType` (dropping
  the current `byType` map that keeps only the last entry per type). Also change the
  "excluding" test to compare entry identity (`entry.id != group.primaryEntry.id`) rather than
  entry *type*, so a day with two entries of the *same* type (e.g. two breathing sessions)
  shows both, and the primary card's own entry is excluded by id, not by blanket type.
- **Rationale**: This is the literal bug the spec's User Story 3 describes — today, if a day
  has two same-type activities, the current type-keyed dedup silently drops one (or, if the
  primary card entry shares that type, drops all of them since it excludes by type). Comparing
  by id instead of type is the minimal fix: it removes the accidental dedup without touching
  the widget's public API (`dayEntries`/`excludingType` stay, only fed by `entries.last.id`-
  style comparisons internally is not needed — see data-model.md for the exact signature
  change) or its layout/measurement logic (the worst-case-height `Visibility` ghost trick is
  unaffected, since it already renders one ghost row per known type, which remains an upper
  bound heuristic rather than an exact match — acceptable since it only over-reserves space in
  the rare multi-same-type-activity case, never under-reserves).
- **Alternatives considered**: Grouping same-type entries into one summarized line ("played 2
  puzzles") — rejected: harder to make each individually tappable back to its own activity
  (FR-006), and the spec explicitly asks for every activity to be visible, not summarized.

## Summary of resolved unknowns

No `[NEEDS CLARIFICATION]` markers existed in the spec; all four decisions above were
architecture-fit judgment calls resolved directly against the existing codebase, matching the
constitution's Minimal Footprint principle (reuse existing getters/widgets/params over adding
new ones).
