import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/constants/shared_preferences_constants.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/helpers/app_themes.dart';

enum AppTheme { green, blue, brown, old, dark }

class ThemeController extends GetxController {
  static ThemeController get instance =>
      GetInstance().putOrFind(() => ThemeController());
  AppTheme? initialTheme;
  ThemeData? initialThemeData;
  Rx<AppTheme> _currentTheme = AppTheme.green.obs;
  final box = GetStorage();

  @override
  void onInit() async {
    var theme = await loadThemePreference();
    setTheme(theme);
    super.onInit();
  }

  void checkTheme() {
    switch (initialTheme) {
      case AppTheme.green:
        initialThemeData = greenTheme;
        break;
      case AppTheme.blue:
        initialThemeData = blueTheme;
        break;
      case AppTheme.brown:
        initialThemeData = brownTheme;
        break;
      case AppTheme.old:
        initialThemeData = oldTheme;
        break;
      case AppTheme.dark:
        initialThemeData = darkTheme;
        break;
      default:
        initialThemeData = greenTheme;
    }
  }

  Future<AppTheme> loadThemePreference() async {
    String themeString = box.read(SET_THEME) ?? AppTheme.green.toString();
    return initialTheme = AppTheme.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => AppTheme.green,
    );
  }

  void setTheme(AppTheme theme) {
    _currentTheme.value = theme;

    // Save theme preference
    box.write(SET_THEME, theme.toString());
    update(); // Notify GetBuilder listeners without triggering global app update
  }

  ThemeData get currentThemeData {
    switch (_currentTheme.value) {
      case AppTheme.green:
        return greenTheme;
      case AppTheme.blue:
        return blueTheme;
      case AppTheme.brown:
        return brownTheme;
      case AppTheme.old:
        return oldTheme;
      case AppTheme.dark:
        return darkTheme;
    }
  }

  AppTheme get currentTheme => _currentTheme.value;

  bool get isGreenMode => _currentTheme.value == AppTheme.green;
  bool get isBlueMode => _currentTheme.value == AppTheme.blue;
  bool get isBrownMode => _currentTheme.value == AppTheme.brown;
  bool get isOldMode => _currentTheme.value == AppTheme.old;
  bool get isDarkMode => _currentTheme.value == AppTheme.dark;
}
