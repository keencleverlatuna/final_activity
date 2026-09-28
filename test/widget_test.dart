import 'package:flutter_test/flutter_test.dart';
import 'package:final_activity/main.dart';

void main() {
  testWidgets('SchoolMail app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FinalActivityApp());

    expect(find.text('SchoolMail'), findsOneWidget);
  });
}