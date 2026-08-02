import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/preferences/auth_prefs.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auth_prefs_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('AuthPrefs', () {
    test('hasEverAuthenticated defaults to false when nothing is stored', () async {
      expect(await AuthPrefs.hasEverAuthenticated(), isFalse);
    });

    test('markAuthenticated persists true for subsequent reads', () async {
      await AuthPrefs.markAuthenticated();

      expect(await AuthPrefs.hasEverAuthenticated(), isTrue);
    });

    test('markAuthenticated is idempotent', () async {
      await AuthPrefs.markAuthenticated();
      await AuthPrefs.markAuthenticated();

      expect(await AuthPrefs.hasEverAuthenticated(), isTrue);
    });
  });
}
