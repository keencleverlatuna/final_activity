import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  light,
  dark,
}

final themeProvider =
AsyncNotifierProvider<ThemeNotifier, AppTheme>(
  ThemeNotifier.new,
);

class ThemeNotifier extends AsyncNotifier<AppTheme> {
  static const String themeKey = 'app_theme';

  @override
  Future<AppTheme> build() async {
    final preferences = await SharedPreferences.getInstance();

    final savedTheme = preferences.getString(themeKey);

    if (savedTheme == 'dark') {
      return AppTheme.dark;
    }

    return AppTheme.light;
  }

  Future<void> setTheme(AppTheme theme) async {
    state = AsyncData(theme);

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      themeKey,
      theme == AppTheme.dark ? 'dark' : 'light',
    );
  }
}