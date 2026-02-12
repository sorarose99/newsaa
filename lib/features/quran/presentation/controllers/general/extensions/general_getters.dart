import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:alslat_aalnabi/features/quran/core/utils/constants/shared_preferences_constants.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/string_constants.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/general/general_controller.dart';

extension GeneralGetters on GeneralController {
  /// -------- [Getters] ----------

  Future<Uri> getCachedArtUri() async {
    if (StringConstants.appsIcon1024.isEmpty) {
      return Uri.parse('about:blank');
    }
    try {
      final file = await DefaultCacheManager().getSingleFile(
        StringConstants.appsIcon1024,
      );
      return await file.exists()
          ? file.uri
          : Uri.parse(StringConstants.appsIcon1024);
    } catch (e) {
      print('Error getting cached art URI: $e');
      return Uri.parse('about:blank');
    }
  }

  Future<void> getLastPageAndFontSize() async {
    try {
      double fontSizeFromPref = state.box.read(FONT_SIZE) ?? 24.0;
      if (fontSizeFromPref != 0.0 && fontSizeFromPref > 0) {
        state.fontSizeArabic.value = fontSizeFromPref;
      } else {
        state.fontSizeArabic.value = 24.0;
      }
    } catch (e) {
      print('Failed to load last page: $e');
    }
  }
}
