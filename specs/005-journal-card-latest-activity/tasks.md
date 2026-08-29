# Tasks: Journal Card Shows Latest Activity Only; Timeline Shows Full Day

**Input**: Design documents from `/specs/005-journal-card-latest-activity/`

**Prerequisites**: plan.md, research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested in spec.md, but widget tests are included per the
project's existing `test/features/journal/` convention and the constitution's test-coverage
principle, and because research.md identifies a real pre-existing bug (type-based dedup in
`TimelineActivityDescriptionRow`) that needs a regression test.

**Organization**: Tasks are grouped by the spec's 3 user stories (all P1). US1 (Journal card
face) and US3 (Timeline shows every activity) touch disjoint files and are independently
implementable/testable; US2 (tap → Timeline, scrolled) depends on US1's navigation call site
but not on US3.

## Phase 1: Setup

- [X] T001 Confirm `flutter analyze` and `flutter test test/features/journal/` run clean on
      `main` before changes, as a baseline (no file changes; verification only)

## Phase 2: Foundational

*No shared/blocking infrastructure — `DayGroup.representative` already exists (see
data-model.md), and no new routes, models, or DI registrations are needed before user stories
can start.*

## Phase 3: User Story 1 - Journal card shows only the day's latest activity (Priority: P1) 🎯 MVP

**Goal**: Journal's recent-memories cards render `group.representative` (the day's single most
recent entry) instead of `group.primaryEntry` (mood-biased), with no footer/activity hints on
the card face.

**Independent Test**: Log a mood check-in, then complete a breathing session same day. Open
Journal and confirm the card shows only the breathing activity — no mood/reason, no dots.

### Tests for User Story 1

- [X] T002 [P] [US1] Write widget test in
      `test/features/journal/journal_recent_memories_section_test.dart` asserting that for a
      `DayGroup` with a `mood_chat` entry followed by a later `breathing` entry, the rendered
      card shows the `breathing` entry (via `JournalActivityChoiceCard`, keyed off its
      `entry.entryType`) and that no `JournalDayActivityDots`/footer widget is present in the
      tree

### Implementation for User Story 1

- [X] T003 [US1] In
      `lib/features/journal/presentation/widgets/journal_recent_memories_section.dart`,
      replace every `group.primaryEntry` reference used to pick the rendered card's entry/type
      with `group.representative`, and remove the `footer:` argument passed to
      `JournalGridCardWidget`/`JournalActivityChoiceCard` (omit entirely so it defaults to
      `null`)
- [X] T004 [US1] In the same file, update `showJournalCardOptionsSheet`'s `entryId:` argument
      (long-press options — pin/recolor/delete) from `group.primaryEntry.id` to
      `group.representative.id`, so the options sheet acts on the entry the card now visually
      represents
- [X] T005 [US1] Remove the now-unused `JournalDayActivityDots` import from
      `journal_recent_memories_section.dart` (confirm no other usage in the file first)

**Checkpoint**: Journal cards now show only the latest entry per day, with zero footer
clutter — independently testable via `flutter test` and quickstart.md Scenario 1.

---

## Phase 4: User Story 2 - Tapping a Journal card opens Timeline, scrolled to that day (Priority: P1)

**Goal**: Replace Journal card's tap-to-chat behavior with tap-to-Timeline, landing on the
tapped day.

**Independent Test**: From Journal, tap a recent-memory card and confirm Timeline opens
scrolled to that day, with no chat screen involved.

**Depends on**: T003 (same file/call site) should land first to avoid touching `onTap` twice.

### Tests for User Story 2

- [X] T006 [P] [US2] Write widget test in
      `test/features/journal/journal_recent_memories_section_test.dart` (same file as T002)
      asserting that tapping a rendered card calls `context.push(AppRoutes.timeline, extra:
      <that day's DateTime>)` and does **not** push `AppRoutes.chat`

### Implementation for User Story 2

- [X] T007 [US2] In `lib/core/routing/router_generation_config.dart`, update the
      `AppRoutes.timeline` `GoRoute`'s `pageBuilder` to read `state.extra as DateTime?` and
      pass it to `TimelineScreen(initialFocusDate: extra)`
- [X] T008 [US2] In `lib/features/journal/presentation/screens/timeline_screen.dart`, add an
      optional `initialFocusDate` constructor parameter to `TimelineScreen`, threaded down to
      `_TimelineView`; add a `final Map<DateTime, GlobalKey> _dayKeys = {}` and a
      `GlobalKey _keyFor(DateTime date) => _dayKeys.putIfAbsent(date, () => GlobalKey())`
      helper in `_TimelineViewState`; in `initState`, schedule
      `WidgetsBinding.instance.addPostFrameCallback` that, if `initialFocusDate` is set and a
      matching key with a mounted `currentContext` exists, calls `Scrollable.ensureVisible`
      on it (alignment near the top, not dead-center)
- [X] T009 [US2] Thread `_keyFor` down through `buildTimelineBodySlivers` (new required
      parameter, e.g. `required Key Function(DateTime date) keyForDate`) in
      `lib/features/journal/presentation/widgets/timeline_body_slivers.dart`, forwarding it to
      each `TimelineMonthSectionWidget`
- [X] T010 [US2] In
      `lib/features/journal/presentation/widgets/timeline_month_section_widget.dart`, accept
      the new `keyForDate` parameter and wrap each day-group's `Transform.translate` in a
      `KeyedSubtree(key: keyForDate(group.date), ...)` so the day's rendered widget is
      reachable by key once built
- [X] T011 [US2] In
      `lib/features/journal/presentation/widgets/journal_recent_memories_section.dart`,
      change each card's `onTap` from calling the file's `_openDay` helper to
      `context.push(AppRoutes.timeline, extra: group.date)`
- [X] T012 [US2] Delete the now-unused top-level `_openDay` function and its now-unused
      `AppRoutes`/`go_router` imports (if no longer referenced) from
      `journal_recent_memories_section.dart` — check remaining usages in the file first since
      `context.push` may still be needed for the tap's Timeline navigation itself

**Checkpoint**: Tapping any Journal card opens Timeline scrolled to that day; the existing
"view full timeline" link (no `extra` passed) is unaffected — independently testable via
quickstart.md Scenario 2.

---

## Phase 5: User Story 3 - Timeline day cards show every activity from that date (Priority: P1)

**Goal**: `TimelineActivityDescriptionRow` lists every same-day entry (not deduped by type),
excluding only the one entry already shown as the card's own face (by id, not by type).

**Independent Test**: Log a mood check-in + two different activities same day; confirm all
three show in Timeline for that day, each tappable.

### Tests for User Story 3

- [X] T013 [P] [US3] Write widget test in
      `test/features/journal/timeline_activity_description_row_test.dart` asserting that for
      `dayEntries` containing two entries of the *same* `entryType` (e.g. two `breathing`
      entries) plus one entry matching `excludingId`, both same-type entries render as
      separate rows and only the entry matching `excludingId` is omitted

### Implementation for User Story 3

- [X] T014 [US3] In
      `lib/features/journal/presentation/widgets/timeline_activity_description_row.dart`,
      replace the `excludingType` parameter with `excludingId` (an `int`), and replace the
      `byType` last-entry-wins map in `build()` with a plain chronological filter/map over
      `dayEntries` that renders one row per entry whose `id != excludingId` (keep
      `_phraseFor`/`_row`/`_ghostEntries`/the `Visibility` worst-case-height trick unchanged —
      only the selection logic changes)
- [X] T015 [US3] In
      `lib/features/journal/presentation/widgets/timeline_month_section_widget.dart`, update
      the `TimelineActivityDescriptionRow(...)` call site from `excludingType:
      group.primaryEntry.entryType` to `excludingId: group.primaryEntry.id`

**Checkpoint**: Every logged activity for a day is visible in Timeline, including duplicate
same-type activities that were previously silently dropped — independently testable via
quickstart.md Scenarios 3 and 4.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T016 [P] Run `flutter analyze` and confirm no new lint issues were introduced
- [X] T017 [P] Manually validate all 4 scenarios from `quickstart.md` on a simulator/device
- [X] T018 Re-run the full `flutter test test/features/journal/` suite to confirm no
      regressions in `journal_bubble_content_font_consistency_test.dart` or
      `journal_card_options_sheet_test.dart` (both touch code adjacent to these changes)

## Dependencies & Execution Order

- **Phase 1 (Setup)** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 6 (Polish)**.
  **Phase 5 (US3)** has no dependency on US1/US2 (different files —
  `timeline_activity_description_row.dart`/`timeline_month_section_widget.dart` vs.
  `journal_recent_memories_section.dart`/`router_generation_config.dart`/`timeline_screen.dart`)
  and can run any time after Phase 1, in parallel with US1/US2 work.
- Within US1: T003 must land before T004/T005 (same file, sequential edits on top of each
  other). T002 (test) can be written before or alongside T003 per TDD preference.
- Within US2: T007–T010 (routing/scroll plumbing) have no file overlap with T011/T012 (Journal
  tap wiring) and can be done in parallel; T011 must land before T012 (T012 deletes code T011
  stops referencing).
- Within US3: T014 must land before T015 (T015's call site depends on T014's new parameter
  name existing).
- T016–T018 run last, after all three stories land.

## Parallel Example: Cross-Story

```text
# US1 and US3 touch entirely disjoint files and can be implemented in parallel:
Task T003: "Edit journal_recent_memories_section.dart (US1: representative + no footer)"
Task T014: "Edit timeline_activity_description_row.dart (US3: excludingId, no type dedup)"

# Within US2, routing/scroll plumbing and Journal's tap wiring are independent until T011:
Task T007: "Edit router_generation_config.dart (US2: read state.extra)"
Task T008: "Edit timeline_screen.dart (US2: initialFocusDate + scroll)"
```

## Implementation Strategy

### MVP = User Story 1

US1 alone (Phase 1 → Phase 3) already delivers the core visual simplification and is safely
shippable on its own — Journal cards show only the latest activity, with the existing
tap-to-chat behavior temporarily still in place until US2 lands. US2 and US3 are both
necessary to avoid a net loss of information (per spec.md's Edge Cases/Assumptions), so ship
all three together in practice, but they remain independently implementable and testable in
any order after Phase 1.
