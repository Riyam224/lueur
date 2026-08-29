# Implementation Plan: Journal Card Shows Latest Activity Only; Timeline Shows Full Day

**Branch**: `005-journal-card-latest-activity` | **Date**: 2026-08-29 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/005-journal-card-latest-activity/spec.md`

## Summary

Journal's "recent memories" cards currently show a day's mood check-in as the card face even
when a later activity (breathing/sudoku/drawing) happened that same day, with the other
activities hinted at via small dots. This feature simplifies the Journal card to show only the
single most recent entry for that day, moves navigation on tap from a direct chat-continuation
screen to the existing Timeline screen (scrolled to that day), and strengthens Timeline's
per-day rendering so it lists literally every entry logged that day (not deduped by type),
since Timeline is now the only place a busy day's full story is visible.

## Technical Context

**Language/Version**: Dart 3+ / Flutter (existing app toolchain, no version change)

**Primary Dependencies**: `flutter_bloc` (Cubit), `go_router`, `dartz` (`Either`) — all
already in use; no new packages required

**Storage**: N/A for this feature — reads existing `MoodEntryEntity` data already produced by
`JournalGridCubit`/`MoodRepositoryImpl`; no schema, model, or Hive changes

**Testing**: `flutter_test` widget tests (existing `test/features/journal/` convention)

**Target Platform**: iOS + Android (Flutter app, unchanged)

**Project Type**: mobile-app (single Flutter project, Clean Architecture: presentation → domain → data)

**Performance Goals**: No new perf targets — this is a presentation-layer rendering/navigation
change against already-loaded in-memory entries; must not introduce visible jank on the
Journal/Timeline scroll views

**Constraints**: Zero new dependencies (constitution IV — Minimal Footprint); zero domain/data
layer changes (existing `MoodEntryEntity`, `DayGroup`, `JournalGridCubit` already expose
everything needed); presentation-only change

**Scale/Scope**: Touches 4 existing presentation-layer files
(`journal_recent_memories_section.dart`, `timeline_activity_description_row.dart`,
`timeline_screen.dart`, `router_generation_config.dart`) plus one small addition
(`DayGroup` gains no new fields — `representative` already exists and is reused)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|---|---|---|
| I. Clean Architecture | Change is presentation-only: which entry a card renders, what a footer lists, and where a tap navigates. No business logic, no data access added to widgets. | ✅ PASS |
| II. Domain Layer Purity | No domain files touched. `MoodEntryEntity`/`DayGroup` (presentation model) already expose `representative`, `entries`, `activityTypes` — reused as-is. | ✅ PASS |
| III. Cubit/Bloc State Management | No new state needed. `JournalGridCubit` already loads all entries; Timeline's "scroll to day" is local UI state (a `ScrollController` + `GlobalKey`), which is exactly what `setState`/local state is for — not business logic. | ✅ PASS |
| IV. Minimal Footprint | No new package. Reuses `DayGroup.representative` (already exists) instead of adding a new getter. Fixes the existing `TimelineActivityDescriptionRow` per-type dedup in place rather than introducing a parallel widget. | ✅ PASS |
| V. Test Coverage | Widget tests added/updated for: Journal card entry selection (latest, not mood-biased), footer removal on Journal cards, and Timeline's per-day row no longer deduping same-type entries. | ✅ PASS (planned in tasks) |

No violations — Complexity Tracking table is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/005-journal-card-latest-activity/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── routing/
│       ├── app_routes.dart                        # unchanged (AppRoutes.timeline exists)
│       └── router_generation_config.dart           # MODIFIED: timeline route reads state.extra
├── features/
│   └── journal/
│       └── presentation/
│           ├── models/
│           │   └── day_group.dart                  # unchanged — `representative` already exists
│           ├── screens/
│           │   └── timeline_screen.dart             # MODIFIED: accept initial focus date, scroll to it
│           └── widgets/
│               ├── journal_recent_memories_section.dart   # MODIFIED: use `representative`, drop footer, push Timeline
│               └── timeline_activity_description_row.dart # MODIFIED: list every entry, not deduped by type

test/
└── features/
    └── journal/
        ├── journal_recent_memories_section_test.dart      # NEW (or extended)
        └── timeline_activity_description_row_test.dart    # NEW (or extended)
```

**Structure Decision**: Single Flutter project, existing `features/journal/presentation/`
structure — no new feature folder, no domain/data changes. This is a targeted presentation
change inside an already-scaffolded feature.

## Complexity Tracking

*No violations — table not applicable.*
