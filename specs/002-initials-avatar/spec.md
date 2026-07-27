# Feature Specification: Initials-Based Profile Avatar

**Feature Branch**: `002-initials-avatar`

**Created**: 2026-07-27

**Status**: Draft

**Input**: User description: "Add a simple initials-based profile avatar to Lueur — no image assets needed, no persona picker. This replaces/precedes any human-avatar persona feature. Displayed on the home screen greeting area and profile screen. Shows the user's first initial, uppercase, with a background color assigned deterministically per user from a small on-brand palette, readable text contrast, and a graceful fallback to a generic icon when no name is available. Consolidates the two existing ad-hoc avatar implementations (home header, profile screen) into one reusable component."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See my own initial on the home screen (Priority: P1)

As a returning user, when I open the home screen, I see a small circular avatar showing the first letter of my name in the header, so the app feels personalized without needing a photo.

**Why this priority**: The home greeting is the first thing every user sees on every app open — it's the highest-visibility, highest-frequency touchpoint for this feature.

**Independent Test**: Log in as a user with a display name, land on home, confirm the header shows a circle with the correct uppercase first letter and a consistent background color across app restarts.

**Acceptance Scenarios**:

1. **Given** a logged-in user with display name "Maria", **When** the home screen loads, **Then** the header avatar shows "M" in a circle with on-brand background and readable text.
2. **Given** the same user closes and reopens the app (new session), **When** the home screen loads again, **Then** the avatar's background color is identical to the previous session.

---

### User Story 2 - See my initial avatar on the profile screen (Priority: P2)

As a user viewing my profile, I see the same style of initials avatar (larger) above my name and join date, consistent with the one on home.

**Why this priority**: Reinforces a single consistent identity element across the app; lower frequency than home but still a core screen.

**Independent Test**: Navigate to profile screen, confirm the avatar shows the correct initial, same background-color-per-user rule, and a larger diameter appropriate to the profile layout.

**Acceptance Scenarios**:

1. **Given** a logged-in user, **When** they open the profile screen, **Then** the avatar circle shows their initial with the same deterministic color as seen elsewhere in the app.

---

### User Story 3 - No name available yet (Priority: P3)

As a user whose name/email hasn't loaded yet (or is genuinely absent), I see a neutral person icon instead of a blank or broken circle, so the UI never looks empty or erroneous.

**Why this priority**: Edge case that prevents a visibly broken state (empty string crash or blank circle) during loading or for edge-case accounts; important for robustness but affects fewer sessions than P1/P2.

**Independent Test**: Render the avatar widget with an empty/null name-or-email input and confirm a generic person icon renders inside the circle instead of throwing or showing blank space.

**Acceptance Scenarios**:

1. **Given** no display name or email is yet available for the user, **When** the avatar is rendered, **Then** a generic person icon is shown in the circle instead of an initial.
2. **Given** a name/email becomes available after a loading state, **When** the widget rebuilds, **Then** it switches from the person icon to the correct initial.

---

### Edge Cases

- What happens when the name/email string is empty, whitespace-only, or starts with a non-letter character (e.g., a digit, emoji, or symbol)? → Treat as "no name available" and fall back to the person icon, OR uppercase whatever the first character is (see FR-002 for the chosen default).
- What happens when only an email is available (no display name)? → Use the first character of the email's local part (before the `@`).
- How is color consistency maintained for the same user across light/dark theme switches? → The background color choice is independent of theme mode; only text contrast is theme-aware if needed.
- What happens if two different users hash to the same color? → Acceptable; the palette is small and shared, collisions are expected and not a correctness issue.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a circular avatar showing the user's first initial, uppercased, wherever an avatar currently appears (home screen header greeting, profile screen) or is planned to appear.
- **FR-002**: System MUST derive the initial from the user's display name if available, falling back to the local part of their email address if no display name is set. If neither yields a usable alphabetic first character, the system MUST fall back per FR-003.
- **FR-003**: System MUST show a generic person icon inside the circle (not a blank circle, not a crash) when no usable name or email is available.
- **FR-004**: System MUST assign the avatar's background color deterministically per user, computed from a stable per-user identifier (user ID if available, otherwise email), by hashing the identifier and mapping it to one color from a small fixed on-brand palette. The same user MUST always map to the same color across sessions and app restarts.
- **FR-005**: System MUST render the initial's text color with sufficient contrast against whichever background color was assigned, for every color in the fixed palette.
- **FR-006**: System MUST render the initial using a bold weight of the app's primary UI font, sized proportionally to the circle's diameter (approximately 40–45% of the diameter).
- **FR-007**: The avatar MUST be implemented as a single reusable widget accepting a name/email string and a diameter, used by both the home screen header and the profile screen — replacing their current independent, duplicated avatar implementations rather than adding a third one.
- **FR-008**: System MUST NOT introduce any new backend fields, API calls, or local persistence to support this feature — the avatar is computed entirely client-side from data already available in existing auth/profile state.
- **FR-009**: The avatar's visual style (flat circle, no gradients, no shadows) MUST match the existing design system's treatment of circular elements; a border is only added if consistent with how other circular elements in the app are already styled.

### Key Entities

- **User display identity**: The subset of the existing user/profile data relevant here — display name and/or email and a stable identifier (user ID) — already available via existing auth/profile state. No new entity or persisted field is introduced.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of screens that previously showed an ad-hoc avatar (home header, profile screen) now render through the single shared avatar component, with zero duplicated avatar-rendering logic remaining in those screens.
- **SC-002**: A given user's avatar background color is identical across 100% of repeat app sessions (no session-to-session flicker or randomness).
- **SC-003**: 0 crashes or blank-circle renders occur when the underlying name/email is empty, null, or non-alphabetic across all screens using the widget.
- **SC-004**: Text-to-background contrast for every palette color meets a minimum readability bar (WCAG AA, ≥4.5:1) as verified for each of the fixed palette colors.

## Assumptions

- The fixed background color palette is: `journalCardLavender`, `journalCardMint`, `journalCardPeach`, `journalCardCoral`, `pastelPeriwinkle` (existing `AppColors` values named in the request), cycled via a deterministic hash of the user's stable identifier.
- "Stable identifier" preference order is: user ID (if exposed on the current user/auth model) → email → display name, using whichever is available and consistent across sessions.
- Text color is a single fixed dark/light tone chosen per the app's existing text-on-color conventions (not computed per-color at runtime), confirmed to have adequate contrast against each of the five palette colors during implementation.
- This feature only replaces the two existing inline avatar implementations found in `home_header.dart` and `profile_avatar_widget.dart`; it does not touch the separate "Luna" mascot avatars used in auth screens or chat/response screens, which are a different, unrelated visual element.
- No persona picker, image upload, or avatar customization UI is in scope — this is a fixed, computed-only visual, matching the request that this feature "replaces/precedes any human-avatar persona feature."
