import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/chat/chat_reset_signal.dart';

void main() {
  test('every bump emits a new value, so listeners always fire', () async {
    final signal = ChatResetSignal();
    final seen = <int>[];
    final sub = signal.stream.listen(seen.add);

    signal.bump();
    signal.bump();
    await Future<void>.delayed(Duration.zero);

    expect(seen, [1, 2]);
    await sub.cancel();
    await signal.close();
  });
}
