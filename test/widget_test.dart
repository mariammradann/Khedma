import 'package:flutter_test/flutter_test.dart';
import 'package:khedma/main.dart';

void main() {
  testWidgets('welcome -> login -> validation', (tester) async {
    await tester.pumpWidget(const KhedmaApp());
    expect(find.text('Lets get started'), findsOneWidget);

    await tester.tap(find.text('Lets get started'));
    await tester.pumpAndSettle();
    expect(find.text('Enter E-mail or Phone'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter your e-mail or phone'), findsOneWidget);
  });
}
