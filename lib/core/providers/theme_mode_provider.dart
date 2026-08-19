import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/services/theme_preferences_service.dart';

final themePreferencesServiceProvider = Provider<ThemePreferencesService>((ref) {
  return ThemePreferencesService();
});

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSavedThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadSavedThemeMode() async {
    final service = ref.read(themePreferencesServiceProvider);
    final saved = await service.getThemeMode();
    if (saved != null) {
      state = _fromString(saved);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final service = ref.read(themePreferencesServiceProvider);
    await service.setThemeMode(_toString(mode));
  }

  String _toString(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  ThemeMode _fromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}