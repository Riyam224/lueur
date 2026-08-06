import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/animation.dart';
import 'package:lueur/features/plant/domain/entities/streak_milestone.dart';

/// Bundles and drives every animation used by the streak celebration
/// screen's staged entrance: bloom → Luna fade-in → progress fill →
/// confetti, plus a one-shot burst (halo pulse + sparkle twinkle + Luna
/// bob) that plays once and settles rather than looping.
class StreakCelebrationAnimations {
  StreakCelebrationAnimations({
    required TickerProvider vsync,
    required int streakDays,
  })  : bloomController =
            AnimationController(vsync: vsync, duration: bloomDuration),
        lunaController =
            AnimationController(vsync: vsync, duration: lunaDuration),
        progressController =
            AnimationController(vsync: vsync, duration: progressDuration),
        burstController =
            AnimationController(vsync: vsync, duration: burstDuration),
        confettiController =
            ConfettiController(duration: const Duration(seconds: 2)) {
    bloomScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: bloomController, curve: Curves.elasticOut),
    );
    lunaFade = CurvedAnimation(parent: lunaController, curve: Curves.easeOut);
    progressFraction = Tween<double>(
      begin: 0,
      end: StreakMilestone.progressToNext(streakDays),
    ).animate(
      CurvedAnimation(parent: progressController, curve: Curves.easeOutCubic),
    );
    // Plays once — one full sine cycle takes the halo pulse, sparkle
    // twinkle, and Luna bob through a single "alive" flourish and back to
    // their resting values, then holds there (no repeat()).
    unawaited(burstController.forward());
  }

  static const bloomDuration = Duration(milliseconds: 500);
  static const lunaDelay = Duration(milliseconds: 300);
  static const lunaDuration = Duration(milliseconds: 500);
  static const progressDuration = Duration(milliseconds: 700);
  static const confettiDelay = Duration(milliseconds: 200);
  static const burstDuration = Duration(milliseconds: 2400);

  final AnimationController bloomController;
  final AnimationController lunaController;
  final AnimationController progressController;
  final AnimationController burstController;
  final ConfettiController confettiController;
  late final Animation<double> bloomScale;
  late final Animation<double> lunaFade;
  late final Animation<double> progressFraction;

  Future<void> runEntranceSequence({
    required bool Function() isMounted,
  }) async {
    unawaited(bloomController.forward());
    await Future<void>.delayed(lunaDelay);
    if (!isMounted()) return;
    unawaited(lunaController.forward());
    unawaited(progressController.forward());
    await Future<void>.delayed(lunaDuration + confettiDelay);
    if (!isMounted()) return;
    confettiController.play();
  }

  void dispose() {
    bloomController.dispose();
    lunaController.dispose();
    progressController.dispose();
    burstController.dispose();
    confettiController.dispose();
  }
}
