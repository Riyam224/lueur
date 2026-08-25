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
import 'package:lueur/features/profile/presentation/widgets/profile_journal_data_section_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

class _FakeMoodRepository implements MoodRepository {
  bool deleteAllCalled = false;

  @override
  Future<Either<Failure, void>> deleteAllEntries() async {
    deleteAllCalled = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, MoodEntryEntity>> addLocalEntry({
    required String emoji,
    required String thoughts,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteEntry(int id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> setCardColor(
    int id,
    String cardColor,
  ) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> setPinned(int id, bool pinned) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> logActivity({
    required String entryType,
    required Map<String, dynamic> payload,
  }) =>
      throw UnimplementedError();
}

void main() {
  Widget buildApp(MoodCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const ProfileJournalDataSectionWidget(),
          ),
        ),
      ),
    );
  }

  testWidgets('canceling the confirmation does not delete entries',
      (tester) async {
    final repo = _FakeMoodRepository();
    final cubit = MoodCubit(repo);
    await tester.pumpWidget(buildApp(cubit));

    await tester.tap(find.text('Delete all journal entries'));
    await tester.pumpAndSettle();

    expect(find.text('Delete all entries?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repo.deleteAllCalled, isFalse);
  });

  testWidgets('confirming deletes all entries', (tester) async {
    final repo = _FakeMoodRepository();
    final cubit = MoodCubit(repo);
    await tester.pumpWidget(buildApp(cubit));

    await tester.tap(find.text('Delete all journal entries'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete all'));
    await tester.pumpAndSettle();

    expect(repo.deleteAllCalled, isTrue);
  });
}
