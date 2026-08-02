import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/widgets/mood_input_section.dart';
import 'package:lueur/l10n/app_localizations.dart';

class _FakeMoodRepository implements MoodRepository {
  @override
  Future<Either<Failure, MoodEntryEntity>> addLocalEntry({
    required String emoji,
    required String thoughts,
  }) async =>
      Right(
        MoodEntryEntity(
          id: 1,
          userId: 'u1',
          emoji: emoji,
          thoughts: thoughts,
          aiResponse: '',
          createdAt: DateTime(2026),
        ),
      );

  @override
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteEntry(int id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteAllEntries() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> setCardColor(
    int id,
    String cardColor,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> setPinned(
    int id,
    bool pinned,
  ) async =>
      throw UnimplementedError();
}

void main() {
  late MoodCubit cubit;

  setUp(() => cubit = MoodCubit(_FakeMoodRepository()));
  tearDown(() => cubit.close());

  Widget buildApp() {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(body: SingleChildScrollView(child: MoodInputSection())),
        ),
      ),
    );
  }

  Future<void> submitMood(WidgetTester tester, String emoji) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey(emoji)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'feeling good today');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'submitting a positive mood shows the mood-choice dialog, same as a distressing one',
    (tester) async {
      await submitMood(tester, '😊'); // happy — not a low mood

      // The chooser dialog's 4 destinations are all present.
      expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement_rounded), findsOneWidget);
      expect(find.byIcon(Icons.brush_rounded), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'submitting a distressing mood still shows the mood-choice dialog (no regression)',
    (tester) async {
      await submitMood(tester, '😠'); // angry — a low mood

      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    },
  );
}
