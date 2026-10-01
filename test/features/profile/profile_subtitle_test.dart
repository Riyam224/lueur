import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';

import 'profile_test_harness.dart';

void main() {
  late ProfileHarness h;

  setUp(() => h = ProfileHarness());
  tearDown(() => h.close());

  Future<void> pumpProfile(WidgetTester tester) async {
    usePhoneSurface(tester);
    final router = h.router();
    addTearDown(router.dispose);
    await tester.pumpWidget(testApp(router: router));
    await tester.pumpAndSettle();
  }

  testWidgets('a guest never sees "Lueur member"', (tester) async {
    await h.auth.enterGuestMode();
    await pumpProfile(tester);

    expect(find.text('Lueur member'), findsNothing);
    expect(find.text('Just visiting as a guest'), findsOneWidget);
  });

  testWidgets('a signed-in account sees "Lueur member"', (tester) async {
    h.authRepo.sessionUser =
        const UserEntity(id: 'uid-1', email: 'user@example.com');
    await h.auth.checkSession();
    await pumpProfile(tester);

    expect(find.text('Lueur member'), findsOneWidget);
    expect(find.text('Just visiting as a guest'), findsNothing);
  });
}
