
import 'package:flutter_test/flutter_test.dart';
import 'package:daymark/main.dart';
import 'package:daymark/providers/theme_provider.dart';

void main() {
  testWidgets('Daymark app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      DaymarkApp(
        themeProvider: ThemeProvider(),
      ),
    );

    expect(find.byType(DaymarkApp), findsOneWidget);
  });
}
