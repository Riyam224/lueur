import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide "something journal-relevant changed, refetch" signal — activity
/// flows and mood-chat writes call [bump]; kept separate from [MoodCubit] so activity completions don't flicker unrelated UI (Home's entry count).
class JournalRefreshSignal extends Cubit<int> {
  JournalRefreshSignal() : super(0);

  void bump() => emit(state + 1);
}
