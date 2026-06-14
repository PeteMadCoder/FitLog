import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitLogApp());

    // Verify that our app initializes showing the welcome text.
    expect(find.text('FitLog Initialized'), findsOneWidget);
  });
}
