import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/auth/presentation/utils/auth_validators.dart';
import 'package:lueur/l10n/app_localizations.dart';

void main() {
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return capturedContext;
  }

  group('AuthValidators.email', () {
    testWidgets('returns an error for an empty value', (tester) async {
      final context = await pumpContext(tester);
      expect(AuthValidators.email(context, ''), isNotNull);
    });

    testWidgets('returns an error for a malformed address', (tester) async {
      final context = await pumpContext(tester);
      expect(AuthValidators.email(context, 'not-an-email'), isNotNull);
    });

    testWidgets('returns null for a valid address', (tester) async {
      final context = await pumpContext(tester);
      expect(AuthValidators.email(context, 'luna@lueur.app'), isNull);
    });
  });

  group('AuthValidators.password', () {
    testWidgets('returns an error when shorter than the minimum length',
        (tester) async {
      final context = await pumpContext(tester);
      expect(AuthValidators.password(context, 'abc'), isNotNull);
    });

    testWidgets('returns null when at least the minimum length',
        (tester) async {
      final context = await pumpContext(tester);
      expect(AuthValidators.password(context, 'abcdef'), isNull);
    });
  });

  group('AuthValidators.confirmPassword', () {
    testWidgets('returns an error when the confirmation does not match',
        (tester) async {
      final context = await pumpContext(tester);
      expect(
        AuthValidators.confirmPassword(context, 'password1', 'password2'),
        isNotNull,
      );
    });

    testWidgets('returns null when the confirmation matches', (tester) async {
      final context = await pumpContext(tester);
      expect(
        AuthValidators.confirmPassword(context, 'password1', 'password1'),
        isNull,
      );
    });
  });
}
