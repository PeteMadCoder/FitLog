import 'package:fitlog_app/app/main_navigation_shell.dart';
import 'package:fitlog_app/features/analytics/providers/analytics_providers.dart';
import 'package:fitlog_app/features/diary/providers/diary_providers.dart';
import 'package:fitlog_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App initialization smoke test renders Navigation Shell', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame, wrapping it in a ProviderScope
    // since the root scope is defined inside main().
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          latestWorkoutProvider.overrideWith((ref) => Stream.value(null)),
          weeklyActivitySummaryProvider.overrideWith(
            (ref) => Stream.value(WeeklyActivitySummary(statsBySport: {})),
          ),
          workoutHistoryProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const FitLogApp(),
      ),
    );

    await tester.pump(); // Start the streams
    await tester.pump(const Duration(milliseconds: 100)); // Process the first emission

    // Verify that the MainNavigationShell is rendered.
    expect(find.byType(MainNavigationShell), findsOneWidget);

    // Verify that we are on the Home screen initially.
    // There are two "Home" texts: one in the AppBar and one in the BottomNavigationBar.
    expect(find.text('Home'), findsNWidgets(2));
  });
}
