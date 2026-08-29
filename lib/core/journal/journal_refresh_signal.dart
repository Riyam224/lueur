import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide "something journal-relevant changed, refetch" signal.
///
/// Activity flows (breathing/sudoku/drawing) and mood-chat writes call
/// [bump] after a successful write; Journal/Timeline listen for any change
/// and reload their entry list. Kept separate from [MoodCubit] so that
/// activity completions — which have nothing to do with mood-chat's
/// loading/entry-count state — can't cause unrelated UI (Home, the entry
/// count header) to flicker or recompute.
class JournalRefreshSignal extends Cubit<int> {
  JournalRefreshSignal() : super(0);

  void bump() => emit(state + 1);
}
