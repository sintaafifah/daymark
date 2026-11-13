
import 'package:flutter_test/flutter_test.dart';
import 'package:daymark/main.dart';

void main() {
  testWidgets('Daymark app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DaymarkApp());

    expect(find.byType(DaymarkApp), findsOneWidget);
  });
}
