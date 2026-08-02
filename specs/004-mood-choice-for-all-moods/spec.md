# Feature Specification: Mood Choice Menu for All Moods

**Feature Branch**: `004-mood-choice-for-all-moods`

**Created**: 2026-08-02

**Status**: Draft

**Input**: User description: "Make the fourth set of choices (sudoku, drawing, breathing, talk to Luna) appear for all mood entries, not just negative moods (angry, tired, etc.). Keep the same UI/UX vibe as existing behavior. Ensure clean code following best practices, and keep each screen file under 140 lines."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choose a coping activity after any mood check-in (Priority: P1)

Today, after logging a mood and thoughts, only users who picked a distressing mood (angry, anxious, scared, burnout) see the "how would you like to feel better?" chooser (Talk to Luna, Breathe, Draw, Sudoku). Users who log a positive or neutral mood (happy, calm, grateful, excited, hopeful, sad, lonely, neutral, content/peaceful) are sent straight to the AI response screen and never see this chooser. This story makes the chooser appear for every mood, so any user — regardless of how they're feeling — can choose how they want to spend the next moment.

**Why this priority**: This is the entire scope of the requested change; without it there is no feature.

**Independent Test**: Log a mood entry with a positive mood (e.g. "happy") and thoughts text, submit, and confirm the same chooser dialog appears as it currently does for "angry" — offering Talk to Luna, Breathe, Draw, and Sudoku — before proceeding to the affirmation screen.

**Acceptance Scenarios**:

1. **Given** the user is on the home mood entry screen, **When** they select a positive/neutral mood (e.g. happy, calm, grateful) and submit their thoughts, **Then** the mood-choice dialog appears offering Talk to Luna, Breathe, Draw, and Sudoku, exactly as it already does for distressing moods.
2. **Given** the user is on the home mood entry screen, **When** they select a distressing mood (angry, anxious, scared, burnout) and submit their thoughts, **Then** the existing chooser behavior is unchanged.
3. **Given** the mood-choice dialog is shown for any mood, **When** the user taps "Talk to Luna", **Then** they proceed to the same affirmation → AI response flow used today, unaffected by which mood was selected.
4. **Given** the mood-choice dialog is shown for a mood that previously skipped it, **When** the user picks Breathe, Draw, or Sudoku, **Then** the same downstream screens and navigation used today for distressing moods are used identically.

### Edge Cases

- What happens when a user dismisses the mood-choice dialog (tap outside) after logging a positive mood? Same as today for distressing moods: the mood entry is already saved locally; no further navigation occurs until the user acts again.
- Does the "Talk to Luna" path still route straight to breathing first for distressing moods, or does it now behave identically for every mood? Existing routing nuances tied to `MoodType.isLowMood` (e.g. any breathing pre-step) are preserved — only the visibility of the chooser dialog changes, not what each choice does once picked.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST show the mood-choice dialog (Talk to Luna, Breathe, Draw, Sudoku) after every mood + thoughts submission, regardless of which mood was selected.
- **FR-002**: System MUST NOT change the dialog's visual design, copy, ordering, or animation — the "same vibe" as the existing low-mood dialog is preserved exactly for all moods.
- **FR-003**: System MUST NOT change what happens after a choice is picked (Talk to Luna / Breathe / Draw / Sudoku navigation targets and data passed) — only when the dialog is shown changes, not its behavior once shown.
- **FR-004**: System MUST continue to save the mood entry locally before showing the dialog, matching current behavior for distressing moods.
- **FR-005**: Code implementing this change MUST follow the project's Clean Architecture layering and existing conventions (see `CLAUDE.md`), and no screen/widget file touched or added MUST exceed 140 lines.

### Key Entities

- **Mood entry**: An existing entity (emoji + thoughts) that triggers the chooser; no new fields are introduced by this feature.
- **Mood choice destination**: The existing enum (`talkToLuna`, `breathing`, `freeDraw`, `sudoku`) is unchanged in values or behavior — only which mood entries can reach it changes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of mood submissions (any of the 13 mood types), not just the 4 distressing ones, result in the mood-choice dialog being shown.
- **SC-002**: The dialog's appearance and the behavior of each of its 4 choices are visually and functionally indistinguishable from the current distressing-mood experience, for any mood.
- **SC-003**: No regression in the distressing-mood flow — users logging angry/anxious/scared/burnout see no behavior change.

## Assumptions

- "The fourth choices" refers to the existing 4-option mood-choice dialog (Talk to Luna, Breathe, Draw, Sudoku) defined in `mood_choice_dialog.dart`, currently gated by `MoodType.isLowMood` in `mood_input_section.dart`.
- "Same vibe" means no visual/UX redesign — reuse the existing dialog unchanged, just broaden when it's invoked.
- The direct-to-response-screen path (bypassing the chooser) for non-distressing moods is being removed as the explicit intent of this request; no alternate condition for skipping the dialog is introduced.
- The 140-line guidance applies to screen/widget files this feature touches or adds, consistent with existing project file sizes in this codebase.
