# Contract: OnboardingLunaAnimated

**Location**: `lib/features/onboarding/presentation/widgets/onboarding_luna_animated.dart`
**Type**: Stateful presentation widget (no DI registration needed)

---

## Interface

```dart
class OnboardingLunaAnimated extends StatefulWidget {
  const OnboardingLunaAnimated({super.key});
}
```

No public parameters — the widget is self-contained. All animation state is internal.

---

## Behaviour

### Float animation

| Property | Value |
|---|---|
| Controller duration | 3 000 ms |
| Curve | `Curves.easeInOut` |
| Mode | `repeat(reverse: true)` |
| Effect | `Transform.translate(offset: Offset(0, value * -8.0))` |
| Range | 0 px (resting) → -8 px (top of float) → 0 px |

### Blink animation

| Property | Value |
|---|---|
| Trigger | Random `Timer` — interval = 2 500 + Random().nextInt(1 500) ms |
| Blink duration | 150 ms |
| Eyes-open state | `SvgPicture.asset('assets/illustrations/luna.svg')` alone |
| Eyes-closed state | `Stack` of `SvgPicture` + `CustomPaint(painter: LunaBlinkOverlay())` |
| Transition | `AnimatedSwitcher(duration: Duration(milliseconds: 80))` |

### LunaBlinkOverlay (CustomPainter)

Draws two filled semi-circular arcs (eyelid shapes) at the eye positions on a
180 × 180 canvas. Uses `AppColors.onboardingLunaDetail` fill colour.

| Eye | Centre (approx.) | Arc radius |
|---|---|---|
| Left | (81.0, 66.0) | 3.6 px |
| Right | (99.0, 66.0) | 3.6 px |

> **Calibration note**: Eye positions are derived from the 1 024 × 1 024 SVG viewBox
> scaled to 180 × 180 (factor ≈ 0.176). A one-time visual check in the running app
> is required to confirm alignment. Adjust centre coords if needed.

`shouldRepaint` returns `false` — overlay is static once shown.

---

## SVG display

```dart
SvgPicture.asset(
  'assets/illustrations/luna.svg',
  width: 180,
  height: 180,
)
```

Centred inside the wave blob area of the parent page view.

---

## Lifecycle

| Event | Action |
|---|---|
| `initState` | Start `_floatController`; schedule first `_blinkTimer` |
| `dispose` | `_floatController.dispose()`; `_blinkTimer.cancel()` |
| Blink fires | `setState(() => _isBlinking = true)`; after 150 ms `setState(() => _isBlinking = false)`; schedule next timer |

---

## Error handling

- No error states — both animations degrade gracefully if the asset is missing
  (`SvgPicture` shows an empty box; `LunaBlinkOverlay` draws over empty space).
- `_blinkTimer.cancel()` in `dispose` prevents timer callbacks after widget removal.
