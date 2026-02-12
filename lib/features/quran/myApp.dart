import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart' as state_provider;

import 'package:alslat_aalnabi/features/quran/core/services/languages/localization_controller.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/theme_controller.dart' as quran_theme;
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';
import 'package:alslat_aalnabi/features/settings/presentation/widgets/settings_provider.dart';

class QuranAppWrapper extends StatelessWidget {
  const QuranAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = state_provider.Provider.of<SettingsProvider>(
      context,
    );
    final localizationCtrl = Get.find<LocalizationController>();

    // Sync Language only (theme sync is now handled automatically)
    if (localizationCtrl.locale.languageCode != settingsProvider.language) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        localizationCtrl.setLanguage(Locale(settingsProvider.language));
      });
    }

    final TextScaler fixedScaler = const TextScaler.linear(1.0);

    return GetBuilder<quran_theme.ThemeController>(
      builder: (themeCtrl) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: fixedScaler),
          child: Theme(
            data: themeCtrl.currentThemeData.copyWith(
              // Ensure inversePrimary is readable
              colorScheme: themeCtrl.currentThemeData.colorScheme.copyWith(
                inversePrimary: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black, // Always black for all light themes
              ),
            ),
            child: Directionality(
              textDirection: _getTextDirection(localizationCtrl.locale),
              child: Scaffold(body: QuranHome()),
            ),
          ),
        );
      },
    );
  }

  TextDirection _getTextDirection(Locale locale) {
    return (locale.languageCode == 'ar' || locale.languageCode == 'ur')
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
