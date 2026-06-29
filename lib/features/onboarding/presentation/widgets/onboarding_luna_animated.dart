import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Luna SVG displayed at 180×180 with a gentle float and random blink.
///
/// Float: 3 s easeInOut oscillation, ±8 px vertical.
/// Blink: random 2.5–4 s interval, eyes-closed overlay shown for 150 ms.
class OnboardingLunaAnimated extends StatefulWidget {
  const OnboardingLunaAnimated({super.key});

  @override
  State<OnboardingLunaAnimated> createState() => _OnboardingLunaAnimatedState();
}

class _OnboardingLunaAnimatedState extends State<OnboardingLunaAnimated>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;
  Timer? _blinkTimer;
  bool _isBlinking = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );
    _scheduleBlink();
  }

  void _scheduleBlink() {
    final ms = 2500 + _rng.nextInt(1500);
    _blinkTimer = Timer(Duration(milliseconds: ms), () async {
      if (!mounted) return;
      setState(() => _isBlinking = true);
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() => _isBlinking = false);
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value * -8.0),
        child: child,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 80),
        child: _isBlinking
            ? Stack(
                key: const ValueKey(true),
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/illustrations/luna.svg',
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(painter: _LunaBlinkOverlay()),
                  ),
                ],
              )
            : SvgPicture.asset(
                'assets/illustrations/luna.svg',
                key: const ValueKey(false),
                width: 180,
                height: 180,
              ),
      ),
    );
  }
}

/// Draws white filled eyelid arcs over Luna's eyes on a 180×180 canvas.
/// Initial positions derived from the SVG viewBox (1024×1024 → 180×180 scale).
/// Adjust centre coordinates after visual calibration (quickstart Scenario 7 / T023).
class _LunaBlinkOverlay extends CustomPainter {
  const _LunaBlinkOverlay();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _drawEyelid(canvas, const Offset(81, 61), 3.6, paint);
    _drawEyelid(canvas, const Offset(99, 61), 3.6, paint);
  }

  // Draws a filled upper semi-ellipse to simulate a closed eyelid.
  void _drawEyelid(Canvas canvas, Offset centre, double r, Paint paint) {
    canvas.drawArc(
      Rect.fromCenter(center: centre, width: r * 2, height: r * 2),
      0,    // start at 3 o'clock
      -pi,  // sweep counter-clockwise through top to 9 o'clock
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LunaBlinkOverlay old) => false;
}
