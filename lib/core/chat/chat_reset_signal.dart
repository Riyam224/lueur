import 'package:flutter_bloc/flutter_bloc.dart';

/// "The user's journal data was wiped or the account changed — forget any
/// open chat" signal. Kept separate from [MoodCubit] so chats don't depend on
/// it; [MoodCubit] calls [bump] and every open [ChatCubit] listens.
class ChatResetSignal extends Cubit<int> {
  ChatResetSignal() : super(0);

  void bump() => emit(state + 1);
}
