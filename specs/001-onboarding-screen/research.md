# Research: Onboarding Screen

**Feature**: `specs/001-onboarding-screen`
**Date**: 2026-06-27

## Decision 1 — Flag Storage: Hive (not SharedPreferences)

- **Decision**: Use Hive to persist the onboarding completion flag.
- **Rationale**: `shared_preferences` is not in `pubspec.yaml`. Hive is already a
  project dependency (`hive: ^2.2.3`, `hive_flutter: ^1.1.0`). A `Box<bool>` opened
  with `Hive.openBox('onboarding')` and a single `put('seen', true)` / `get('seen')`
  covers the requirement with zero new dependencies.
- **Alternatives considered**: SharedPreferences was discussed in clarification but is
  not a current dependency. Adding it would violate the constitution's "no new packages
  without justification" rule when an equivalent mechanism already exists.

## Decision 2 — Flag Accessor Location: `core/preferences/`

- **Decision**: Create `lib/core/preferences/onboarding_prefs.dart` — a thin static
  helper wrapping the Hive box.
- **Rationale**: Onboarding is presentation-only (no data layer). Placing data access
  directly in `SplashScreen` or `OnboardingScreen` would violate the constitution's
  layer-purity principle. A `core/` utility keeps the concern isolated and reusable
  without the overhead of a full repository chain for one boolean.
- **Alternatives considered**: Full repository + use-case chain — rejected as
  over-engineering for a single flag. Direct Hive read inside the screen — rejected as
  a constitution violation (data access in presentation layer).

## Decision 3 — Splash Modification Strategy

- **Decision**: Modify `_navigate()` in `SplashScreen` to read the Hive flag before
  deciding the route. If unseen → `AppRoutes.onBoarding`; if seen → `AppRoutes.loginScreen`.
- **Rationale**: The splash is already the routing decision point. Minimal change —
  one `await` and one conditional. No structural refactor required.
- **Alternatives considered**: Redirects in go_router — more complex, requires a
  refreshListenable or redirect function; disproportionate to the scope.

## Decision 4 — Illustrations: CustomPainter

- **Decision**: Three dedicated `CustomPainter` subclasses:
  `OnboardingLunaPainter` (screen 1), `OnboardingChatPainter` (screen 2),
  `OnboardingPlantPainter` (screen 3).
- **Rationale**: No new packages (no SVG renderer); full control over geometry; keeps
  all visual logic in Dart; consistent with the existing `OnboardingWavePainter` pattern.
- **Alternatives considered**: SVG assets — would require `flutter_svg` (new package).
  Lottie — already in project but adds animation coupling; no animation is wanted here.

## Decision 6 — Blink Animation Without Named SVG Layers

- **Decision**: Use a `LunaBlinkOverlay` `CustomPainter` stacked on top of the `SvgPicture` inside an `AnimatedSwitcher`. When a blink is triggered, the `AnimatedSwitcher` swaps to a `Stack` that renders the SVG plus the overlay; after 150 ms it reverts.
- **Rationale**: `luna.svg` is a 1 MB complex rasterised-style SVG with no named element IDs or layers. `flutter_svg` cannot toggle layer visibility at runtime. A second `luna_eyes_closed.svg` does not exist. The `CustomPainter` overlay draws two filled semi-circular arcs at the eye positions calibrated to the 180 × 180 rendered canvas, reusing the existing `onboardingLunaDetail` colour. This approach adds zero new dependencies and zero new assets.
- **Alternatives considered**: Second SVG asset (`luna_eyes_closed.svg`) with `AnimatedSwitcher` — clean but requires a new asset. Full cross-fade opacity pulse — no actual eye movement, visually weak.
- **Eye position calibration**: The SVG viewBox is 1 024 × 1 024; displayed at 180 × 180 (scale ≈ 0.176). The eye centre positions in the overlay are set to approximately `(81, 66)` left and `(99, 66)` right on the 180 × 180 canvas. These values may need a one-time visual calibration pass after initial implementation.

## Decision 7 — Float Animation Driver

- **Decision**: `AnimationController(duration: 3 s)` + `CurvedAnimation(curve: Curves.easeInOut)` + `repeat(reverse: true)`. The animated value (0.0 → 1.0 → 0.0) drives `Transform.translate(offset: Offset(0, animation.value * -8.0))`.
- **Rationale**: `repeat(reverse: true)` produces a smooth sine-like float without a jump at cycle end. `easeInOut` gives the natural slow-at-extremes feel. `-8 px` displacement is subtle on all target screen sizes (360–430 dp wide).
- **Alternatives considered**: `SlideTransition` — requires `Animation<Offset>` in fractional units, more boilerplate for pixel-value control. `Tween` + `animate` inline — equivalent but more verbose.

## Decision 8 — Blink Timer

- **Decision**: `dart:async Timer` with a random interval drawn from `2 500 + Random().nextInt(1 500)` ms (range 2.5–4.0 s). After each blink fires, a new `Timer` is scheduled with a fresh random interval.
- **Rationale**: A one-shot `Timer` with self-scheduling is the simplest pattern for random-interval events. An `AnimationController` looping at a fixed interval would require manual randomisation at each cycle end — same logic, more overhead.
- **Alternatives considered**: `Stream.periodic` — fixed interval only, no built-in randomisation.

## Decision 9 — Asset Path Correction

- **Decision**: Use `assets/illustrations/luna.svg` throughout all code and documentation.
- **Rationale**: The file exists at `assets/illustrations/luna.svg` and is declared under the `assets/illustrations/` glob in `pubspec.yaml`. The path `assets/images/luna.svg` does not exist.

## Decision 5 — New Colors Needed

The design spec introduces colors not in `AppColors`:
- `#E8825A` — active dot / CTA / skip text (close to existing `primary` `#E8621A` but
  distinct — add as `onboardingAccent`)
- `#D4C5BC` — inactive dot (add as `onboardingDotInactive`)
- `#FFF8F5` — skip button background (same as `lightBackground` — reuse)
- `#3B2A1A` — headline color (add as `onboardingHeadline`)
- `#6B5B4E` — subtitle color (add as `onboardingSubtitle`)
- `#C9C3F0` — Luna eyes/smile (add as `onboardingLunaDetail`)
- `#A8D5C2` — chat bubble detail (add as `onboardingChatDetail`)
