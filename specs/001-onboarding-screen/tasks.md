---
description: "Task list for onboarding screen implementation"
---

# Tasks: Onboarding Screen

**Input**: Design documents from `specs/001-onboarding-screen/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story to enable independent implementation
and testing of each story.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Exact file paths included in all descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Colors and strings used by all three user stories — complete before any widget work.

- [x] T001 [P] Add 6 onboarding colors (`onboardingAccent`, `onboardingDotInactive`, `onboardingHeadline`, `onboardingSubtitle`, `onboardingLunaDetail`, `onboardingChatDetail`) to `lib/core/styling/app_colors.dart`
- [x] T002 [P] Replace all 6 onboarding strings (3 titles + 3 subtitles) in `lib/core/utils/app_strings.dart` with new copy per design spec

**Checkpoint**: Colors and strings ready — widget tasks can begin.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Constant values consumed by multiple widgets — must be done before widget tasks.

- [x] T003 Replace fraction-based spacing/dot constants in `lib/features/onboarding/presentation/constants/onboarding_constants.dart` with fixed logical-pixel values per design spec (wave-to-headline 36 px, headline-to-subtitle 12 px, subtitle-to-dots 24 px, dots-to-button 20 px, button-to-bottom 40 px; active dot 24×8 px, inactive dot 8×8 px, dot gap 8 px; button size 64 px)

**Checkpoint**: Constants ready — all widget tasks can now proceed in parallel.

---

## Phase 3: User Story 1 — First-Launch Walkthrough (Priority: P1) 🎯 MVP

**Goal**: All three pages render with custom illustrations, updated copy, correct
typography, and refined bottom-section spacing.

**Independent Test**: Launch on a clean install. All three pages show correct
illustrations, copy, fonts, dot indicator, Skip button (pages 1–2), and Next/check
button. Page transitions animate. No console errors.

### Implementation for User Story 1

- [x] T004 [P] [US1] Create `OnboardingLunaPainter` (`CustomPainter`) — white irregular blob body, dot eyes, curved smile, nub arms, 3 star sparkles — in `lib/features/onboarding/presentation/widgets/onboarding_luna_painter.dart`
- [x] T005 [P] [US1] Create `OnboardingChatPainter` (`CustomPainter`) — two speech bubbles (Luna 180×52 with typing dots, user 140×52 with text line), 14 px gap — in `lib/features/onboarding/presentation/widgets/onboarding_chat_painter.dart`
- [x] T006 [P] [US1] Create `OnboardingPlantPainter` (`CustomPainter`) — soil mound, stem, two leaves, bud — in `lib/features/onboarding/presentation/widgets/onboarding_plant_painter.dart`
- [x] T007 [US1] Rewrite `OnboardingIllustration` to render `CustomPaint` with the matching painter per `OnboardingIllustrationVariant`; rename enum values to `luna` / `chat` / `sprout` (was `glow` / `speechBubble` / `sprout`) in `lib/features/onboarding/presentation/widgets/onboarding_illustration.dart` and `lib/features/onboarding/presentation/models/onboarding_page_data.dart` (depends on T004, T005, T006)
- [x] T008 [P] [US1] Update `_OnboardingText` in `lib/features/onboarding/presentation/widgets/onboarding_page_view.dart`: headline → DM Serif Display italic 28 sp color `#3B2A1A`; subtitle → DM Sans Regular 14 sp line-height 1.6 color `#6B5B4E`; top padding 36 px from wave bottom; headline-to-subtitle gap 12 px; horizontal padding 36 px each side (depends on T001, T002, T003)
- [x] T009 [P] [US1] Update `OnboardingPageIndicator` in `lib/features/onboarding/presentation/widgets/onboarding_page_indicator.dart`: active pill 24×8 px color `onboardingAccent`; inactive circle 8×8 px color `onboardingDotInactive`; gap 8 px fixed; remove fraction-based sizing (depends on T001, T003)
- [x] T010 [P] [US1] Update `OnboardingSkipButton` in `lib/features/onboarding/presentation/widgets/onboarding_skip_button.dart`: background `#FFF8F5`; text DM Sans Medium 14 sp color `onboardingAccent`; padding 16 px top 20 px right; no border; remove fraction-based padding (depends on T001, T002)
- [x] T011 [P] [US1] Update `OnboardingNextButton` in `lib/features/onboarding/presentation/widgets/onboarding_next_button.dart`: fixed 64×64 px circle color `onboardingAccent`; wrap `InkWell` in `AnimatedScale` (scale 0.95, duration 150 ms) on tap; remove fraction-based sizing (depends on T001, T003)
- [x] T012 [US1] Replace fraction-based bottom section layout in `lib/features/onboarding/presentation/screens/onboarding_screen.dart` with fixed pixel `SizedBox` spacings: subtitle-to-dots 24 px, dots-to-button 20 px, button-to-safe-area 40 px (depends on T007, T008, T009, T010, T011)

**Checkpoint**: All three pages fully styled and functional. US1 independently testable.

---

## Phase 4: User Story 2 — Skip Hidden on Last Page (Priority: P2)

**Goal**: Skip button absent from page 3, present on pages 1 and 2.

**Independent Test**: Navigate to each page and verify Skip visibility matches
expected state. No other UI changes.

### Implementation for User Story 2

- [x] T013 [US2] Wrap `OnboardingSkipButton` in `lib/features/onboarding/presentation/screens/onboarding_screen.dart` with `if (!_isLastPage)` guard (depends on T012)

**Checkpoint**: Skip button absent on page 3, visible on pages 1 and 2. US2 independently testable.

---

## Phase 5: User Story 3 — Show Once Per Install (Priority: P3)

**Goal**: Onboarding shown only on first launch; splash routes directly to login on
subsequent launches.

**Independent Test**: Complete or skip onboarding, force-quit, relaunch — splash goes
directly to login screen. No onboarding pages appear.

### Implementation for User Story 3

- [x] T014 [P] [US3] Create `OnboardingPrefs` static helper with `hasSeen()` and `markSeen()` using Hive box `'onboarding'` key `'seen'`; include error-safe fallback (return `false` on exception) in `lib/core/preferences/onboarding_prefs.dart`
- [x] T015 [US3] Call `OnboardingPrefs.markSeen()` before `context.go(AppRoutes.loginScreen)` in both `_finishOnboarding()` and `_onSkipPressed()` in `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (depends on T013, T014)
- [x] T016 [US3] Update `SplashScreen._navigate()` in `lib/features/splash/presentation/screens/splash_screen.dart` to open Hive box `'onboarding'`, call `OnboardingPrefs.hasSeen()`, and route to `AppRoutes.loginScreen` if `true`, else `AppRoutes.onBoarding` (depends on T014)

**Checkpoint**: Show-once behaviour verified. All three user stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T017 Run `flutter analyze` and fix any warnings or lint issues across all modified files
- [ ] T018 Validate all five scenarios in `specs/001-onboarding-screen/quickstart.md` on simulator (iOS or Android)

---

## Phase 7: User Story 4 — Luna SVG Animated Illustration (Extension)

**Goal**: A new alternative screen (`onboarding_screen_2.dart`) where page 2's
`OnboardingChatPainter` is replaced by an animated Luna SVG: gentle float (±8 px, 3 s)
and random blink (every 2.5–4 s, 150 ms closed). All other layout, text, colors,
and navigation are unchanged from the original screen.

**Independent Test**: Navigate to `OnboardingScreen2`. Page 2 shows `luna.svg` at
180×180 px, centred in the lavender blob area. Luna floats up and down smoothly.
Within 10 s, eyes close briefly and reopen. No layout shifts, no console errors.
Pages 1 and 3 are unaffected (still use their original CustomPainter illustrations).

### Implementation for User Story 4

- [x] T019 [P] [US4] Create `LunaBlinkOverlay` `CustomPainter` (draws two filled `onboardingLunaDetail`-coloured semi-circular arcs at left eye centre (81, 66) and right eye centre (99, 66), radius 3.6 px, on a 180×180 canvas; `shouldRepaint` returns `false`) inside `lib/features/onboarding/presentation/widgets/onboarding_luna_animated.dart`
- [x] T020 [US4] Create `OnboardingLunaAnimated` `StatefulWidget` with `TickerProviderStateMixin` in `lib/features/onboarding/presentation/widgets/onboarding_luna_animated.dart`: `_floatController` (`AnimationController`, duration 3 s, `repeat(reverse: true)`); `CurvedAnimation(curve: Curves.easeInOut)`; `build` wraps `SvgPicture.asset('assets/illustrations/luna.svg', width: 180, height: 180)` in `Transform.translate(offset: Offset(0, _floatAnim.value * -8.0))`; init and dispose in `initState`/`dispose` (depends on T019)
- [x] T021 [US4] Add blink animation to `OnboardingLunaAnimated` in `lib/features/onboarding/presentation/widgets/onboarding_luna_animated.dart`: `bool _isBlinking`; `Timer? _blinkTimer`; `_scheduleBlink()` draws random interval `2500 + Random().nextInt(1500)` ms then sets `_isBlinking = true`, waits 150 ms, sets `_isBlinking = false`, calls `_scheduleBlink()` again; wrap the `SvgPicture` in `AnimatedSwitcher(duration: 80 ms)` — key `ValueKey(_isBlinking)` — showing plain SVG when `false`, `Stack([SvgPicture, CustomPaint(painter: LunaBlinkOverlay())])` when `true`; cancel `_blinkTimer` in `dispose` (depends on T020)
- [x] T022 [US4] Create `OnboardingScreen2` `StatefulWidget` in `lib/features/onboarding/presentation/screens/onboarding_screen_2.dart`: copy `OnboardingScreen` structure exactly; override page-2 illustration by passing a flag or creating a variant `OnboardingPageView` that substitutes `OnboardingLunaAnimated()` for `OnboardingIllustration` when `index == 1`; all other pages, text, colors, buttons, and `_finishOnboarding`/skip navigation remain identical (depends on T021)
- [ ] T023 [US4] Visual calibration pass in running app: launch `OnboardingScreen2`, navigate to page 2, observe blink overlay alignment; adjust `LunaBlinkOverlay` eye centre coords in `lib/features/onboarding/presentation/widgets/onboarding_luna_animated.dart` if arcs do not cover the SVG eyes (depends on T022)

**Checkpoint**: `OnboardingScreen2` page 2 shows animated Luna SVG. Float and blink verified per Scenarios 6–7 in `quickstart.md`. US4 independently testable.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately; T001 and T002 run in parallel
- **Foundational (Phase 2)**: No hard dependency on Phase 1 — can overlap
- **User Story 1 (Phase 3)**: T004–T006 depend on T001; T008–T011 depend on T001/T002/T003; T007 depends on T004–T006; T012 depends on T007–T011
- **User Story 2 (Phase 4)**: T013 depends on T012
- **User Story 3 (Phase 5)**: T014 has no deps; T015 depends on T013 + T014; T016 depends on T014
- **Polish (Phase 6)**: Depends on US1–US3 complete
- **User Story 4 (Phase 7)**: T019 has no deps; T020 depends on T019; T021 depends on T020; T022 depends on T021; T023 depends on T022. **Can start in parallel with Phase 3** — touches only new files.

### Parallel Opportunities

```
Phase 1+2 (run together):
  T001 — app_colors.dart
  T002 — app_strings.dart (lib/core/utils/)
  T003 — onboarding_constants.dart

Phase 3 painter group (after T001):
  T004 — onboarding_luna_painter.dart
  T005 — onboarding_chat_painter.dart
  T006 — onboarding_plant_painter.dart

Phase 3 widget group (after T001, T002, T003):
  T008 — onboarding_page_view.dart
  T009 — onboarding_page_indicator.dart
  T010 — onboarding_skip_button.dart
  T011 — onboarding_next_button.dart

Phase 5 + Phase 7 can start in parallel (after Phase 1):
  T014 — onboarding_prefs.dart        (US3, no deps)
  T019 — LunaBlinkOverlay painter     (US4, no deps)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) + Phase 2 (Foundational) ✅
2. Complete Phase 3 (User Story 1) ✅
3. **STOP and VALIDATE**: run app, check all three pages visually match design spec
4. Proceed to US2, US3, US4

### Incremental Delivery

1. Setup + Foundational → shared infrastructure ready ✅
2. US1 → visual redesign complete, all pages testable ✅
3. US2 → Skip hidden on last page (T013, one-liner)
4. US3 → Show-once persistence wired up end-to-end (T014–T016)
5. US4 → Luna SVG animation in alternative screen (T019–T023)
6. Polish → analyze + quickstart validation (T017–T018)

---

## Notes

- [P] tasks = different files, no blocking dependencies between them
- T014 (`OnboardingPrefs`) and T019 (`LunaBlinkOverlay`) can both start as soon as Phase 1 is done
- T013 and T015 both modify `onboarding_screen.dart` — apply sequentially in that file
- T019, T020, T021 all write to `onboarding_luna_animated.dart` — apply sequentially in that file
- All painter dimensions are in logical pixels; `CustomPaint` canvas is sized via `SizedBox` at the call site
- **Storage**: Hive box `'onboarding'` key `'seen'` — `shared_preferences` is not in pubspec.yaml (research.md Decision 1)
- **SVG asset path**: `assets/illustrations/luna.svg` — the path `assets/images/luna.svg` does not exist (research.md Decision 9)
- **Blink eye positions**: initial values (81, 66) left / (99, 66) right are estimates; T023 is the calibration pass
- Commit after each phase checkpoint to enable easy bisect if needed
