import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_settings.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsState extends _$SettingsState {
  File? _settingsFile;

  @override
  Future<UserSettings> build() async {
    final dir = await getApplicationDocumentsDirectory();
    _settingsFile = File('${dir.path}/user_settings.json');
    if (await _settingsFile!.exists()) {
      try {
        final content = await _settingsFile!.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return UserSettings.fromJson(json);
      } catch (e) {
        // Fallback to empty settings
      }
    }
    return UserSettings();
  }

  Future<void> updateSettings({
    String? gender,
    double? height,
    double? weight,
    double? weeklyGoalHours,
  }) async {
    final current = state.value ?? UserSettings();
    final updated = current.copyWith(
      gender: gender,
      height: height,
      weight: weight,
      weeklyGoalHours: weeklyGoalHours,
    );
    state = AsyncValue.data(updated);

    if (_settingsFile != null) {
      await _settingsFile!.writeAsString(jsonEncode(updated.toJson()));
    }
  }

  Future<void> importSettings(UserSettings settings) async {
    state = AsyncValue.data(settings);
    if (_settingsFile != null) {
      await _settingsFile!.writeAsString(jsonEncode(settings.toJson()));
    }
  }
}
