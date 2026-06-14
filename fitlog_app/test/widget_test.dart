import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/main.dart';
import 'package:fitlog_app/app/main_navigation_shell.dart';

void main() {
  testWidgets('App initialization smoke test renders Navigation Shell', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame, wrapping it in a ProviderScope
    // since the root scope is defined inside main().
    await tester.pumpWidget(const ProviderScope(child: FitLogApp()));

    // Verify that the MainNavigationShell is rendered.
    expect(find.byType(MainNavigationShell), findsOneWidget);

    // Verify that we are on the Home screen initially.
    expect(find.text('Home Dashboard Screen'), findsOneWidget);
  });
}
