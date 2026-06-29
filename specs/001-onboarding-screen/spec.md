# Feature Specification: Onboarding Screen

**Feature Branch**: `001-onboarding-screen`

**Created**: 2026-06-27

**Status**: Draft

**Input**: User description: "working on onboarding screen"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — First-Launch Walkthrough (Priority: P1)

A new user opens the app for the first time and is guided through three onboarding pages
before reaching the login/register screen. Each page presents a calming illustration,
a headline, and a short subtitle describing a core app capability. The user can swipe
forward, tap the next button, or skip the entire flow at any time.

**Why this priority**: This is the entry point of the entire user experience. Every new
user must pass through it, and a broken or jarring onboarding kills first impressions
before the core product is even seen.

**Independent Test**: Launch the app on a clean install. Three pages appear in sequence.
Swiping or tapping Next advances pages. On the last page, tapping the CTA navigates
to the login screen. The flow delivers a complete, self-contained introduction.

**Acceptance Scenarios**:

1. **Given** the app is launched for the first time, **When** the onboarding screen
   loads, **Then** the first page (mood check-in, lavender blob) is shown with the
   Skip button visible and the Next button showing a forward arrow.
2. **Given** the user is on page 1 or 2, **When** they tap Next or swipe left,
   **Then** the view animates to the next page and the page indicator updates to
   reflect the new active position.
3. **Given** the user is on the last page (page 3), **When** they tap the CTA button,
   **Then** the app navigates to the login screen.
4. **Given** the user is on any page, **When** they tap Skip, **Then** the app
   navigates immediately to the login screen.
5. **Given** the user is on the last page, **When** the page loads, **Then** the CTA
   button shows a check/done icon (not a forward arrow) indicating completion.

---

### User Story 2 — "Skip Intro" on Last Page (Priority: P2)

The Skip button should not be visible on the last page, because the CTA button already
completes the flow. Showing Skip alongside a "done" CTA is redundant and creates
visual noise on the most important page of the flow.

**Why this priority**: Minor UX polish — the core flow still works without this, but
it creates a confusing double-exit on the final page.

**Independent Test**: Navigate to page 3. Confirm the Skip button is absent. Navigate
back to pages 1 and 2. Confirm the Skip button is present.

**Acceptance Scenarios**:

1. **Given** the user is on page 1 or 2, **When** the page is visible,
   **Then** the Skip button is shown in the top-right corner.
2. **Given** the user is on page 3 (last page), **When** the page is visible,
   **Then** the Skip button is hidden.

---

### User Story 3 — "Show Once" on First Launch Only (Priority: P3)

Once a user completes or skips the onboarding flow, subsequent app launches must go
directly to the login/home screen. The onboarding screen must never appear again
after its first dismissal.

**Why this priority**: Without this, every cold start forces the user through a flow
they've already seen, which is a frustrating regression in app quality.

**Independent Test**: Complete or skip the onboarding flow, then restart the app.
Onboarding does not appear; the splash screen routes directly to login/home.

**Acceptance Scenarios**:

1. **Given** the user has completed or skipped onboarding in a prior session,
   **When** the app is relaunched, **Then** the splash screen routes to login/home,
   bypassing the onboarding screen entirely.
2. **Given** the user has never launched the app before, **When** the app starts,
   **Then** the splash screen routes to the onboarding screen.
3. **Given** onboarding completion is persisted, **When** the app is force-closed and
   reopened, **Then** the persisted state is respected and onboarding is not shown.

---

### Edge Cases

- What happens if the device is rotated mid-flow? The layout must remain correct on
  all orientations (fraction-based sizing already handles this).
- What happens if the user swipes past the last page? The `PageView` must clamp at
  page 3 and not create an out-of-bounds error.
- What happens if onboarding persistence storage is unavailable or corrupted?
  Default to showing onboarding (safe fallback — user sees it one extra time at worst).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The onboarding flow MUST present exactly 3 pages in fixed order:
  mood check-in (lavender), AI companion (mint), breathing & affirmations (peach).
- **FR-002**: Each page MUST display a colored wave blob illustration, a headline,
  and a subtitle.
- **FR-003**: The user MUST be able to advance pages by swiping left or tapping the
  Next button.
- **FR-004**: The Next button on pages 1–2 MUST show a forward arrow icon.
- **FR-005**: The Next button on page 3 MUST show a done/check icon.
- **FR-006**: A Skip button MUST be visible on pages 1 and 2 and MUST be hidden on
  page 3.
- **FR-007**: Tapping Skip or the page-3 CTA MUST navigate the user to the
  login screen.
- **FR-008**: A page indicator (animated pill-dot row) MUST reflect the current page
  and animate on page change.
- **FR-009**: Onboarding completion MUST be persisted locally so the flow is shown
  only once per install.
- **FR-010**: The splash screen MUST be modified to read the SharedPreferences flag
  before its existing auth routing — if the flag is unset, route to onboarding first;
  otherwise proceed with normal auth routing.

### Key Entities

- **OnboardingPageData**: Title, subtitle, illustration icon, blob color, illustration
  variant (glow / speechBubble / sprout). Presentation-only — no persistence.
- **Onboarding completion flag**: Boolean persisted via SharedPreferences, keyed to
  whether the user has previously seen and dismissed onboarding.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time user can complete or skip the onboarding flow in under
  20 seconds.
- **SC-002**: All three pages are reachable via swipe and via the Next button with
  no navigation errors.
- **SC-003**: On a second launch after completion, the onboarding screen is never
  shown — the splash routes to login within its normal transition time.
- **SC-004**: The Skip button is absent from page 3 and present on pages 1 and 2,
  verified on both iOS and Android.
- **SC-005**: The layout remains visually correct on screen sizes from 360×640 dp to
  430×932 dp (compact to large phone).

---

## Clarifications

### Session 2026-06-27

- Q: Which local storage mechanism should the onboarding completion flag use? → A: SharedPreferences — a single boolean flag is too lightweight for a Hive box.
- Q: Does the splash screen need to be modified to add the onboarding flag check? → A: Yes — modify splash to add a SharedPreferences read before the existing auth routing; onboarding is shown first if unseen, then auth routing proceeds normally.
- Q: Should the onboarding flag persist across app updates or reset on upgrade? → A: Persist — once dismissed, never shown again regardless of version; SharedPreferences survives upgrades by default.

---

## Assumptions

- The app is a mobile-only product (iOS + Android); no tablet-optimised layout is
  required for the onboarding flow.
- "First launch" is defined per install, not per user account — re-installing the app
  resets the onboarding flag. App updates do **not** reset the flag; SharedPreferences
  persists across upgrades and the flag is respected indefinitely once set.
- The login screen already exists and is reachable via `AppRoutes.loginScreen`
  (confirmed in current code).
- Local persistence for the completion flag uses **SharedPreferences** (not Hive) —
  a single boolean flag is too lightweight to warrant a Hive box, and SharedPreferences
  is idiomatic for this pattern. No new package is required (`shared_preferences` is
  already a transitive dependency via Flutter).
- Onboarding is presentation-only: no domain or data layer sub-folders are needed
  per the project constitution.
- All sizing uses `MediaQuery.sizeOf(context)` multiplied by fraction constants —
  not `flutter_screenutil` — consistent with the existing onboarding implementation.
