
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      isDarkMode ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

// Agar ThemeProvider bisa diakses dari seluruh halaman
class ThemeProviderScope extends InheritedNotifier<ThemeProvider> {
  const ThemeProviderScope({
    super.key,
    required ThemeProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static ThemeProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<
        ThemeProviderScope>();

    assert(scope != null, 'ThemeProviderScope tidak ditemukan');

    return scope!.notifier!;
  }
}
