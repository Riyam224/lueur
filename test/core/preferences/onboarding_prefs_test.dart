import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';

void main() {
  late Directory tempDir;
  late Box<bool> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('onboarding_prefs_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<bool>('onboarding');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('OnboardingPrefs.hasSeen(null)', () {
    test('returns false on a fresh install', () async {
      expect(await OnboardingPrefs.hasSeen(null), isFalse);
    });

    test('returns true while a completion is pending', () async {
      await OnboardingPrefs.markSeen();

      expect(await OnboardingPrefs.hasSeen(null), isTrue);
    });

    test('returns true when only the legacy device flag is set', () async {
      await box.put('seen', true);

      expect(await OnboardingPrefs.hasSeen(null), isTrue);
    });

    test('returns true when only a per-account record exists', () async {
      await box.put('seen_uid-1', true);

      expect(await OnboardingPrefs.hasSeen(null), isTrue);
    });

    test('still returns true after pending was converted for a new account',
        () async {
      await OnboardingPrefs.markSeen();
      await OnboardingPrefs.hasSeen('uid-1');

      expect(await OnboardingPrefs.hasSeen(null), isTrue);
    });
  });

  group('OnboardingPrefs.hasSeen(uid)', () {
    test('converts a pending completion into the account record', () async {
      await OnboardingPrefs.markSeen();

      expect(await OnboardingPrefs.hasSeen('uid-1'), isTrue);
      expect(box.get('seen_uid-1'), isTrue);
      expect(box.containsKey('pending'), isFalse);
    });

    test('removes a leftover pending when the account record already exists',
        () async {
      await box.put('seen_uid-1', true);
      await OnboardingPrefs.markSeen();

      expect(await OnboardingPrefs.hasSeen('uid-1'), isTrue);
      expect(box.containsKey('pending'), isFalse);
    });

    test('a leftover pending cannot leak to a second account', () async {
      await box.put('seen_uid-1', true);
      await OnboardingPrefs.markSeen();
      await OnboardingPrefs.hasSeen('uid-1');

      expect(await OnboardingPrefs.hasSeen('uid-2'), isFalse);
    });

    test('never writes the legacy device flag', () async {
      await OnboardingPrefs.markSeen();
      await OnboardingPrefs.hasSeen('uid-1');

      expect(box.containsKey('seen'), isFalse);
    });
  });
}
