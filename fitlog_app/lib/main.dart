import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/app/app_theme.dart';
import 'package:fitlog_app/app/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Required so the main isolate can receive data from the background service isolate.
  FlutterForegroundTask.initCommunicationPort();
  runApp(const ProviderScope(child: FitLogApp()));
}

class FitLogApp extends StatelessWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLog',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationShell(),
    );
  }
}
