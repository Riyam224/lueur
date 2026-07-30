import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/cubits/theme_cubit.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/presentation/cubit/language_cubit.dart';
import 'package:lueur/features/language/presentation/widgets/language_toggle_widget.dart';
import 'package:lueur/features/profile/presentation/widgets/profile_settings_section_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Avoids touching Hive/shared_preferences (real [ThemeCubit] and
/// [LanguageCubit] both persist on construction/change) — this widget test
/// only cares about layout, not persistence.
class _FakeThemeCubit extends Cubit<ThemeMode> implements ThemeCubit {
  _FakeThemeCubit(super.initial);

  @override
  bool get isDark => state == ThemeMode.dark;

  @override
  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

class _FakeLanguageCubit extends Cubit<Locale> implements LanguageCubit {
  _FakeLanguageCubit(super.initial);

  @override
  Future<void> changeLanguage(AppLanguage language) async {}
}

void main() {
  Future<void> pumpSection(WidgetTester tester, {required Locale locale}) {
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
                value: _FakeThemeCubit(ThemeMode.dark),
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

  testWidgets(
      'appearance Switch is shrink-wrapped so it sits close to its row, '
      'matching the language toggle\'s visual rhythm, under RTL',
      (tester) async {
    await pumpSection(tester, locale: const Locale('ar'));
    await tester.pump();

    expect(
      Directionality.of(tester.element(find.byType(ProfileSettingsSectionWidget))),
      TextDirection.rtl,
    );

    final switchSize = tester.getSize(find.byType(Switch));
    // Material 3's Switch track exactly fills switchWidth (52=52); the
    // default `padding` (4px each side) is what inflates the box to 60px,
    // reading as a gap between the label and the visible track. With
    // `padding: EdgeInsets.zero` the box should measure exactly 52px.
    expect(switchSize.width, 52);

    // Both trailing controls are the last Row child, so under RTL they sit
    // flush against the row's leading (left) edge — same x for both rows.
    final switchLeft = tester.getTopLeft(find.byType(Switch)).dx;
    final languageToggleLeft =
        tester.getTopLeft(find.byType(LanguageToggleWidget)).dx;
    expect((switchLeft - languageToggleLeft).abs(), lessThan(1));
  });

  testWidgets('appearance Switch stays shrink-wrapped under LTR too',
      (tester) async {
    await pumpSection(tester, locale: const Locale('en'));
    await tester.pump();

    expect(
      Directionality.of(tester.element(find.byType(ProfileSettingsSectionWidget))),
      TextDirection.ltr,
    );
    expect(tester.getSize(find.byType(Switch)).width, 52);
  });
}
