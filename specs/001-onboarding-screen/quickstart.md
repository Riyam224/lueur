# Quickstart Validation: Onboarding Screen

**Feature**: `specs/001-onboarding-screen`
**Date**: 2026-06-27

## Prerequisites

- Flutter SDK installed, `flutter doctor` clean.
- Simulator/emulator running (or physical device connected).
- Clean app install (no prior Hive data for the `'onboarding'` box).

## Setup

```bash
flutter pub get
flutter run
```

## Scenario 1 — P1: Full first-launch walkthrough

**Goal**: Verify all three onboarding pages render and navigation works.

1. Launch the app on a clean install.
2. **Expected**: Onboarding page 1 appears (lavender wave, Luna illustration,
   headline "A gentle space, just for you").
3. Tap the Next button (arrow icon).
4. **Expected**: Page 2 appears with animation (mint wave, chat bubbles).
5. Tap the Next button again.
6. **Expected**: Page 3 appears (peach wave, plant illustration). Next button
   shows a check icon. Skip button is **absent**.
7. Tap the check button.
8. **Expected**: App navigates to the Login screen.

**Pass criteria**: All three pages visible; page indicator updates on each transition;
no errors in console.

---

## Scenario 2 — P2: Skip button visibility

**Goal**: Skip is shown on pages 1–2 and hidden on page 3.

1. Launch app on a clean install.
2. On page 1: confirm Skip button visible top-right.
3. Advance to page 2: confirm Skip button visible.
4. Advance to page 3: confirm Skip button **not visible**.

**Pass criteria**: Visibility toggling matches expected state on all three pages.

---

## Scenario 3 — P2: Skip button navigates to login

**Goal**: Tapping Skip from any eligible page ends the flow.

1. Launch app on a clean install.
2. On page 1, tap Skip.
3. **Expected**: App navigates immediately to Login screen.
4. Repeat from page 2.

**Pass criteria**: Login screen appears; no onboarding pages remain in stack.

---

## Scenario 4 — P3: Show-once behaviour

**Goal**: Onboarding does not reappear after first dismissal.

1. Launch app, complete or skip onboarding (Scenario 1 or 3).
2. Force-quit the app.
3. Relaunch the app.
4. **Expected**: Splash screen routes directly to Login — onboarding screen does
   **not** appear.

**Pass criteria**: Onboarding skipped entirely on second launch.

---

## Scenario 5 — Edge: Swipe past last page

**Goal**: PageView does not crash or produce blank page when swiping right on page 3.

1. Navigate to page 3.
2. Attempt to swipe left (further).
3. **Expected**: Nothing happens — view stays on page 3 with no error.

**Pass criteria**: No crash, no blank frame, no console error.

---

---

## Scenario 6 — Luna SVG Float Animation (`onboarding_screen_2.dart`)

**Goal**: Verify the Luna SVG oscillates smoothly.

1. Navigate to `OnboardingScreen2` (route it temporarily or run in isolation).
2. Observe the Luna SVG illustration on page 2.
3. **Expected**: Luna slowly floats up ~8 px then back down on a ~3 s cycle.
4. Let it run for 10 seconds.
5. **Expected**: Motion is smooth with no jank; easeInOut gives slow-at-extremes feel.

**Pass criteria**: Continuous oscillation, no jump at cycle reversal, no console errors.

---

## Scenario 7 — Luna SVG Blink Animation

**Goal**: Verify the blink fires randomly and closes eyes briefly.

1. On the same screen as Scenario 6, watch the Luna illustration for up to 10 seconds.
2. **Expected**: Within 2.5–4 s, Luna's eyes close briefly (~150 ms) then reopen.
3. **Expected**: The transition is a soft cross-fade (80 ms), not a hard cut.
4. Watch for 30 seconds total — blink should fire 7–12 times.

**Pass criteria**: Eyes-closed overlay aligns with the SVG eye positions; no layout shift; no console errors.

---

## Teardown / Reset

To re-test first-launch behaviour, uninstall the app (clears Hive data) and reinstall.
