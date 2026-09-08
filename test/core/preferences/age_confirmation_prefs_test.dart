import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/preferences/age_confirmation_prefs.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('age_confirmation_prefs_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('AgeConfirmationPrefs', () {
    test('hasConfirmedAge defaults to false for an unknown uid', () async {
      expect(await AgeConfirmationPrefs.hasConfirmedAge('uid-1'), isFalse);
    });

    test('markAgeConfirmed persists true for subsequent reads of that uid', () async {
      await AgeConfirmationPrefs.markAgeConfirmed('uid-1');

      expect(await AgeConfirmationPrefs.hasConfirmedAge('uid-1'), isTrue);
    });

    test('markAgeConfirmed is idempotent', () async {
      await AgeConfirmationPrefs.markAgeConfirmed('uid-1');
      await AgeConfirmationPrefs.markAgeConfirmed('uid-1');

      expect(await AgeConfirmationPrefs.hasConfirmedAge('uid-1'), isTrue);
    });

    test('confirmation is scoped per-uid, not shared across accounts', () async {
      await AgeConfirmationPrefs.markAgeConfirmed('uid-1');

      expect(await AgeConfirmationPrefs.hasConfirmedAge('uid-2'), isFalse);
    });
  });
}
