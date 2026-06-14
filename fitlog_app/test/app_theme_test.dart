import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitlog_app/app/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('darkTheme configurations are correct', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppTheme.darkPrimary));
      expect(theme.scaffoldBackgroundColor, equals(AppTheme.darkBackground));
    });

    test('lightTheme configurations are correct', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppTheme.lightPrimary));
      expect(theme.scaffoldBackgroundColor, equals(AppTheme.lightBackground));
    });
  });
}
