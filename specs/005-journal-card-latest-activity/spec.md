# Feature Specification: Journal Card Shows Latest Activity Only; Timeline Shows Full Day

**Feature Branch**: `005-journal-card-latest-activity`

**Created**: 2026-08-29

**Status**: Draft

**Input**: User description: "in the journal cards i want the card to show only the latest activity and when click on the card or on the timeline .. show the timeline screen and make the cards show all the activities related to specific date."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Journal card shows only the day's latest activity (Priority: P1)

Today, a Journal card for a day with multiple activities (e.g. a mood check-in plus a breathing session) shows the mood check-in as the card face and lists the *other* activities underneath it as small extra lines. This is visually busy for what Journal is meant to be — a quick, uncluttered taste of recent memories. Instead, each Journal card should represent a single day simply and cleanly: whichever activity happened most recently that day, with nothing else crowded onto the card face.

**Why this priority**: This is the visual simplification the whole request is built around — without it, Journal cards keep their current cluttered look.

**Independent Test**: Log a mood check-in, then complete a breathing session on the same day. Open Journal and confirm that day's card shows only the breathing session (the latest activity) — no mood emoji, reason text, or extra activity line for the earlier check-in appears on the card face.

**Acceptance Scenarios**:

1. **Given** a day with only one activity (a mood check-in), **When** the user views Journal, **Then** the card shows that check-in exactly as it does today (mood, reason, date).
2. **Given** a day with a mood check-in followed later by a breathing/puzzle/drawing session, **When** the user views Journal, **Then** the card face shows only the later activity — its own icon/label and date — and no longer shows the earlier check-in's mood or reason, nor a list of other same-day activities.
3. **Given** a day with several non-mood activities logged in sequence (e.g. breathing, then a puzzle), **When** the user views Journal, **Then** the card shows only the most recent of them.

---

### User Story 2 - Tapping a Journal card opens the full Timeline (Priority: P1)

Today, tapping a Journal card jumps straight into a chat continuation screen for that day's mood conversation. Since the Journal card face no longer tells the full story of the day (per User Story 1), tapping it should instead take the user to the Timeline screen — the existing full, searchable, filterable history — landed on that same day, so they can see everything that happened and drill in from there.

**Why this priority**: Without this, simplifying the card face (US1) would hide information with no way to recover it, which is a regression rather than an improvement.

**Independent Test**: From Journal, tap any recent-memory card and confirm the Timeline screen opens, scrolled to the tapped day's entry.

**Acceptance Scenarios**:

1. **Given** the user is on the Journal screen, **When** they tap any of the recent-memory cards, **Then** the Timeline screen opens.
2. **Given** the user taps a Journal card for a specific day, **When** the Timeline screen opens, **Then** it is scrolled/positioned so that day's entry is visible without additional searching.
3. **Given** the user taps Journal's existing "view full timeline" link, **When** the Timeline screen opens, **Then** behavior is unchanged from today (opens at the top/most recent, as it already does).

---

### User Story 3 - Timeline day cards show every activity from that date (Priority: P1)

Within the Timeline screen, a day that had multiple activities should make that fully visible — not just short hint phrases about "other" activities. The user wants to see everything that happened on that date: the mood and the reason they wrote for it, and each activity they did afterward, so the Timeline (unlike the simplified Journal) remains the complete, detailed record.

**Why this priority**: Timeline is where users go for full detail; if it also hides information, there's no place left in the app where a busy day's full story is visible.

**Independent Test**: Log a mood check-in with a reason, then complete two different activities the same day. Open Timeline, find that day, and confirm the mood, the written reason, and both activities are all visibly listed for that single day's entry.

**Acceptance Scenarios**:

1. **Given** a day with a mood check-in and one or more activities, **When** the user views that day in Timeline, **Then** the mood, the written reason, and every activity done that day are all shown for that day's entry.
2. **Given** a day with only a single activity and no mood check-in, **When** the user views that day in Timeline, **Then** the entry shows that one activity (unchanged from today).
3. **Given** the user taps one of the listed activities for a day in Timeline, **When** the tap is handled, **Then** the user is taken to that specific activity (its own screen) or its detail, consistent with how activity taps already work today.

### Edge Cases

- A day with zero activities never produces a card in either Journal or Timeline (unchanged — cards only exist for days with at least one logged entry).
- A day whose only entries are activities (no mood check-in at all) shows the latest activity on the Journal card face (US1) and all of that day's activities in Timeline (US3), with no mood/reason section since none was logged.
- If a Journal card is tapped for a day that, by the time of the tap, has scrolled out of Timeline's loaded range (e.g. very old entry in a long history), Timeline still opens and best-effort scrolls as close as possible rather than failing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST render each Journal card face using only the single most recently logged entry for that day (mood check-in or activity, whichever is later), regardless of how many entries exist for that day.
- **FR-002**: The system MUST NOT show any indicator, dot, or description of other same-day activities on the Journal card face — that information moves entirely to Timeline (per FR-004).
- **FR-003**: The system MUST navigate to the Timeline screen when a user taps a Journal card, replacing today's behavior of opening a chat continuation directly from Journal.
- **FR-003a**: The system MUST position the Timeline screen so the tapped day's entry is visible when opened this way.
- **FR-004**: The system MUST render each Timeline day entry so that the mood (if logged that day), the written reason for that mood, and every activity logged that day are all visible — not summarized as a single "other activities" hint.
- **FR-005**: The system MUST preserve existing Timeline behavior for search, mood filter, and month filter — this feature only changes what a day's entry displays and how Journal cards are reached, not Timeline's browsing controls.
- **FR-006**: The system MUST preserve the existing ability to tap into an individual activity (breathing/sudoku/drawing) from Timeline to open that activity's own screen.

### Key Entities

- **Day Group**: All journal entries sharing one calendar day — already exists as the app's model for grouping mood check-ins and activities together. This feature changes which entry within a Day Group represents the *Journal* card face (the latest one, not the mood check-in) and expands what the *Timeline* rendering of a Day Group shows (all entries, not a same-day hint).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A Journal card for a day with multiple activities visually shows exactly one activity (the latest), with zero other-activity indicators present on the card.
- **SC-002**: 100% of Journal card taps land the user on the Timeline screen scrolled to the tapped day, with no chat screen opening directly from a Journal card tap.
- **SC-003**: For any day with a mood check-in plus one or more activities, a user viewing that day in Timeline can identify the mood, the written reason, and every activity done that day without any additional tap or navigation.
- **SC-004**: Existing Timeline search/filter and activity-tap navigation continue to work exactly as before this change, with no regressions.

## Assumptions

- "Latest activity" is ordered by each entry's logged timestamp; ties are not expected in practice (entries are logged sequentially with second-level timestamps).
- The Journal card's own actions unrelated to card *content* (long-press options: pin, recolor, delete) continue to act on the day's entries as they do today — this feature does not change that menu, only what the card face shows and what a plain tap does.
- Timeline's per-day rendering already has the underlying data (all of a day's entries) available; this feature is a change in what's displayed and how it's reached, not a new data source.
- "Scrolled to the tapped day" means Timeline auto-scrolls/positions to that day's section on open; it does not require a distinct highlight animation, though one MAY be added for polish.
