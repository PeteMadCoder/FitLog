import 'package:fitlog_app/features/home/views/home_screen.dart';
import 'package:fitlog_app/features/tracking/views/tracker_screen.dart';
import 'package:fitlog_app/features/diary/views/diary_screen.dart';
import 'package:fitlog_app/features/analytics/views/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

/// The main application shell hosting the bottom navigation bar and
/// orchestrating swaps between the four core features.
class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    TrackerScreen(),
    DiaryScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(navigationIndexProvider.notifier).setIndex(index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
