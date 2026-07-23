import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/journal/domain/usecases/delete_journal_entry_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/get_journal_entries_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/set_journal_card_color_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/toggle_journal_pin_usecase.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';

import 'journal_grid_cubit_test.dart' show FakeMoodRepository, buildTestEntry;

void main() {
  late FakeMoodRepository repo;
  late JournalGridCubit cubit;

  setUp(() {
    repo = FakeMoodRepository([
      buildTestEntry(1),
      buildTestEntry(2),
    ]);
    cubit = JournalGridCubit(
      getEntriesUseCase: GetJournalEntriesUseCase(repo),
      setCardColorUseCase: SetJournalCardColorUseCase(repo),
      togglePinUseCase: ToggleJournalPinUseCase(repo),
      deleteEntryUseCase: DeleteJournalEntryUseCase(repo),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  Widget buildApp() {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider.value(
          value: cubit,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      showJournalCardOptionsSheet(context, entryId: 1),
                  child: const Text('open sheet'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('tapping a color swatch updates that entry\'s color',
      (tester) async {
    await cubit.loadEntries();
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('card color'), findsOneWidget);

    // 4 swatch circles rendered.
    final swatchFinder = find.byWidgetPredicate(
      (w) => w is Container && w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).shape == BoxShape.circle,
    );
    expect(swatchFinder, findsNWidgets(4));

    await tester.tap(swatchFinder.first);
    await tester.pumpAndSettle();

    final state = cubit.state as JournalGridLoaded;
    final entry1 = state.entries.firstWhere((e) => e.id == 1);
    final entry2 = state.entries.firstWhere((e) => e.id == 2);
    expect(entry1.cardColor, isNotNull);
    expect(entry2.cardColor, isNull);
  });

  testWidgets('delete requires confirmation before removing from the list',
      (tester) async {
    await cubit.loadEntries();
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('open sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('delete entry'));
    await tester.pumpAndSettle();

    // Confirmation dialog is showing; entry must still be present.
    expect(find.text('Delete this entry?'), findsOneWidget);
    expect((cubit.state as JournalGridLoaded).entries.length, 2);

    // Cancel — nothing should be removed.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((cubit.state as JournalGridLoaded).entries.length, 2);

    // Delete again, this time confirm.
    await tester.tap(find.text('delete entry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    final state = cubit.state as JournalGridLoaded;
    expect(state.entries.map((e) => e.id), [2]);
  });
}
