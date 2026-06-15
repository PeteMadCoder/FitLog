import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/diary/providers/diary_providers.dart';

void main() {
  group('CalendarMonth Provider', () {
    test('initial state should be current month and year', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final now = DateTime.now();
      final currentMonth = container.read(calendarMonthProvider);

      expect(currentMonth.year, equals(now.year));
      expect(currentMonth.month, equals(now.month));
      expect(currentMonth.day, equals(1));
    });

    test('nextMonth should increment month correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialMonth = DateTime(2026, 1);
      container.read(calendarMonthProvider.notifier).setMonth(initialMonth);
      
      container.read(calendarMonthProvider.notifier).nextMonth();
      final nextMonth = container.read(calendarMonthProvider);

      expect(nextMonth.year, equals(2026));
      expect(nextMonth.month, equals(2));
    });

    test('nextMonth should roll over year', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialMonth = DateTime(2026, 12);
      container.read(calendarMonthProvider.notifier).setMonth(initialMonth);
      
      container.read(calendarMonthProvider.notifier).nextMonth();
      final nextMonth = container.read(calendarMonthProvider);

      expect(nextMonth.year, equals(2027));
      expect(nextMonth.month, equals(1));
    });

    test('previousMonth should decrement month correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialMonth = DateTime(2026, 2);
      container.read(calendarMonthProvider.notifier).setMonth(initialMonth);
      
      container.read(calendarMonthProvider.notifier).previousMonth();
      final prevMonth = container.read(calendarMonthProvider);

      expect(prevMonth.year, equals(2026));
      expect(prevMonth.month, equals(1));
    });

    test('previousMonth should roll back year', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialMonth = DateTime(2026, 1);
      container.read(calendarMonthProvider.notifier).setMonth(initialMonth);
      
      container.read(calendarMonthProvider.notifier).previousMonth();
      final prevMonth = container.read(calendarMonthProvider);

      expect(prevMonth.year, equals(2025));
      expect(prevMonth.month, equals(12));
    });
  });

  group('DiaryViewMode Provider', () {
    test('initial state should be false (List view)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(diaryViewModeProvider), isFalse);
    });

    test('toggle should change state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(diaryViewModeProvider.notifier).toggle();
      expect(container.read(diaryViewModeProvider), isTrue);

      container.read(diaryViewModeProvider.notifier).toggle();
      expect(container.read(diaryViewModeProvider), isFalse);
    });
  });
}
