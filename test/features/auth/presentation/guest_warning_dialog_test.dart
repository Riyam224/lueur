import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/auth/presentation/widgets/guest_warning_dialog.dart';
import 'package:lueur/l10n/app_localizations.dart';

void main() {
  Widget buildApp(ValueChanged<GuestWarningChoice?> onResult) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => onResult(
                await GuestWarningDialog.show(context),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Continue as guest returns the guest choice', (tester) async {
    GuestWarningChoice? result;
    await tester.pumpWidget(buildApp((choice) => result = choice));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(result, GuestWarningChoice.continueAsGuest);
  });

  testWidgets('Register instead returns the registration choice',
      (tester) async {
    GuestWarningChoice? result;
    await tester.pumpWidget(buildApp((choice) => result = choice));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register instead'));
    await tester.pumpAndSettle();

    expect(result, GuestWarningChoice.registerInstead);
  });
}
