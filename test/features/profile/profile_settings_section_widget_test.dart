import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/presentation/cubit/language_cubit.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_settings_section_widget.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:lueur/features/theme/presentation/widgets/theme_selector_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Avoids touching Hive/shared_preferences (real [ThemeCubit] and
/// [LanguageCubit] both persist on construction/change) — this widget test
/// only cares about layout, not persistence.
class _FakeThemeCubit extends Cubit<ThemeModeOption> implements ThemeCubit {
  _FakeThemeCubit(super.initial);

  @override
  Future<void> setThemeMode(ThemeModeOption mode) async {
    emit(mode);
  }
}

class _FakeLanguageCubit extends Cubit<Locale> implements LanguageCubit {
  _FakeLanguageCubit(super.initial);

  @override
  Future<void> changeLanguage(AppLanguage language) async {}
}

void main() {
  Future<void> pumpSection(
    WidgetTester tester, {
    required Locale locale,
    ThemeModeOption initialThemeMode = ThemeModeOption.system,
  }) {
    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>.value(
                value: _FakeThemeCubit(initialThemeMode),
              ),
              BlocProvider<LanguageCubit>.value(
                value: _FakeLanguageCubit(locale),
              ),
            ],
            child: const Scaffold(body: ProfileSettingsSectionWidget()),
          ),
        ),
      ),
    );
  }

  testWidgets('renders all three theme options and the language toggle',
      (tester) async {
    await pumpSection(tester, locale: const Locale('en'));
    await tester.pump();

    final selector = find.byType(ThemeSelectorWidget);
    expect(
      find.descendant(
        of: selector,
        matching: find.byIcon(Icons.light_mode_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: selector,
        matching: find.byIcon(Icons.dark_mode_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: selector,
        matching: find.byIcon(Icons.brightness_auto_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping the Dark option switches the theme cubit to dark',
      (tester) async {
    await pumpSection(tester, locale: const Locale('en'));
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byType(ThemeSelectorWidget),
        matching: find.byIcon(Icons.dark_mode_rounded),
      ),
    );
    await tester.pump();

    final cubit = tester
        .element(find.byType(ProfileSettingsSectionWidget))
        .read<ThemeCubit>();
    expect(cubit.state, ThemeModeOption.dark);
  });

  testWidgets('renders correctly under RTL', (tester) async {
    await pumpSection(tester, locale: const Locale('ar'));
    await tester.pump();

    expect(
      Directionality.of(
        tester.element(find.byType(ProfileSettingsSectionWidget)),
      ),
      TextDirection.rtl,
    );
    expect(find.byIcon(Icons.brightness_auto_rounded), findsOneWidget);
  });
}
