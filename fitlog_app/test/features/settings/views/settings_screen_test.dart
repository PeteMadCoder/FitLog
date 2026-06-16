import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/settings/views/settings_screen.dart';
import 'package:fitlog_app/features/settings/models/user_settings.dart';
import 'package:fitlog_app/features/settings/providers/settings_provider.dart';

class FakeSettingsState extends SettingsState {
  UserSettings _value;

  FakeSettingsState(this._value);

  @override
  Future<UserSettings> build() async {
    return _value;
  }

  @override
  Future<void> updateSettings({
    String? gender,
    double? height,
    double? weight,
  }) async {
    _value = _value.copyWith(
      gender: gender,
      height: height,
      weight: weight,
    );
    state = AsyncValue.data(_value);
  }
}

void main() {
  testWidgets('SettingsScreen displays profile fields and backup options', (tester) async {
    final initialSettings = UserSettings(
      gender: 'Male',
      height: 175.0,
      weight: 70.0,
    );

    final fakeNotifier = FakeSettingsState(initialSettings);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStateProvider.overrideWith(() => fakeNotifier),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pump(); // Start provider loading
    await tester.pumpAndSettle(); // Resolve build

    // 1. Verify profile fields are populated
    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('175.0'), findsOneWidget);
    expect(find.text('70.0'), findsOneWidget);

    // 2. Verify Backup section is visible
    expect(find.text('Data Management & Backup'), findsOneWidget);
    expect(find.text('Export Data to JSON'), findsOneWidget);
    expect(find.text('Import Data from JSON'), findsOneWidget);
    expect(find.text('Full Database Export'), findsOneWidget);
    expect(find.text('Full Database Import'), findsOneWidget);
    expect(find.text('Import Workout (GPX / TCX)'), findsOneWidget);
  });

  testWidgets('SettingsScreen validates form input and saves profile data', (tester) async {
    final initialSettings = UserSettings(
      gender: 'Male',
      height: 175.0,
      weight: 70.0,
    );

    final fakeNotifier = FakeSettingsState(initialSettings);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStateProvider.overrideWith(() => fakeNotifier),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Change Height to an invalid value
    await tester.enterText(find.widgetWithText(TextFormField, 'Height (cm)'), '-10');
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    // Check validation error
    expect(find.text('Please enter a valid height'), findsOneWidget);

    // Change height and weight to valid values
    await tester.enterText(find.widgetWithText(TextFormField, 'Height (cm)'), '182.5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Weight (kg)'), '79.3');
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    // Verify it saved successfully (shown by snackbar)
    expect(find.text('Profile saved successfully!'), findsOneWidget);
    
    // Verify updated state in notifier
    final updated = await fakeNotifier.future;
    expect(updated.height, equals(182.5));
    expect(updated.weight, equals(79.3));
  });
}
