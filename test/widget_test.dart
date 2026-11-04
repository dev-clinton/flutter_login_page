import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/main.dart';

void main() {
  testWidgets('CEE app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CeeApp());

    expect(find.text('CEE'), findsOneWidget);
  });
}
