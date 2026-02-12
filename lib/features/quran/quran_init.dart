import 'dart:developer' as developer;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:get_storage/get_storage.dart';
import 'package:quran_library/quran_library.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/theme_controller.dart';
import 'package:alslat_aalnabi/features/quran/core/services/languages/localization_controller.dart';
import 'package:alslat_aalnabi/features/quran/core/services/languages/dependency_inj.dart'
    as dep;
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';
import 'package:alslat_aalnabi/features/quran/core/utils/constants/shared_preferences_constants.dart';

import 'package:alslat_aalnabi/features/quran/core/services/services_locator.dart';

Future<Map<String, Map<String, String>>> initQuranFeature() async {
  developer.log('Starting Quran feature initialization...', name: 'QuranInit');

  // Initialize Service Locator for GetIt
  try {
    await ServicesLocator().init();
    developer.log('✓ ServicesLocator initialized', name: 'QuranInit');
  } catch (e) {
    developer.log(
      '✗ ServicesLocator init failed: $e',
      name: 'QuranInit',
      error: e,
    );
  }

  Map<String, Map<String, String>> languages = {};

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  try {
    languages = await dep.init();
    developer.log('✓ Languages initialized', name: 'QuranInit');
  } catch (e) {
    developer.log('✗ Language init failed: $e', name: 'QuranInit', error: e);
  }

  try {
    await GetStorage.init();
    developer.log('✓ GetStorage initialized', name: 'QuranInit');
  } catch (e) {
    developer.log('✗ GetStorage init failed: $e', name: 'QuranInit', error: e);
  }

  try {
    await QuranLibrary.init().timeout(const Duration(seconds: 10));
    QuranLibrary().setFontsSelected = 1;

    // Filter Tafsir list to only include desired ones
    final desiredTafsirNames = [
      'بن كثير',
      'ابن كثير',
      'تفسير القرآن العظيم',
      'Ibn Kathir',
      'السعدي',
      'تيسير الكريم الرحمن',
      'As Saadi',
      'Saadi',
      'الطبري',
      'جامع البيان عن تأويل آي القرآن',
      'Tabari',
      'أضواء البيان',
      'اضواء البيان',
      'اضاواء البيان',
      'أضواء البيان في إيضاح القرآن بالقرآن',
      'Adwa',
      'فتح القدير',
      'فتح القدير للشوكاني',
      'Qadir',
      'ابن القيم',
      'Ibn al-Qayyim',
      'Qayyim',
      'بدائع التفسير',
      'الميسر',
      'الميسر - مجمع الملك فهد',
      'Muyassar',
      'Fahd',
      'King Fahd',
      'التفسير الميسر',
      'المختصر',
      'المختصر في التفسير',
      'مركز تفسير',
      'المختصر في التفسير - مركز تفسير',
      'Mukhtasar',
      'Tafsir Center',
      'عثيمين',
      'ابن عثيمين',
      'تفسير ابن عثيمين',
      'Uthaymeen',
      'العثيمين',
      'ابن القيم الجوزية',
    ];

    developer.log(
      'All available Tafsirs: ${QuranLibrary().tafsirAndTraslationsCollection.map((e) => e.bookName).toList()}',
      name: 'QuranInit',
    );

    developer.log(
      'Tafsir collection size before: ${QuranLibrary().tafsirAndTraslationsCollection.length}',
      name: 'QuranInit',
    );

    QuranLibrary().tafsirAndTraslationsCollection.removeWhere((tafsir) {
      bool isDesired = desiredTafsirNames.any(
        (name) => tafsir.bookName.toLowerCase().contains(name.toLowerCase()),
      );
      if (!isDesired) {
        developer.log('Removing tafsir: ${tafsir.bookName}', name: 'QuranInit');
      } else {
        developer.log('Keeping tafsir: ${tafsir.bookName}', name: 'QuranInit');
      }
      return !isDesired;
    });

    developer.log(
      'Tafsir collection size after: ${QuranLibrary().tafsirAndTraslationsCollection.length}',
      name: 'QuranInit',
    );

    // Reset stored tafsir index if it's out of bounds after filtering
    final box = GetStorage();
    final storedTafsirIndex = box.read(TAFSEER_VAL) ?? 0;
    if (storedTafsirIndex >=
        QuranLibrary().tafsirAndTraslationsCollection.length) {
      developer.log(
        'Resetting tafseer_val from $storedTafsirIndex to 0',
        name: 'QuranInit',
      );
      box.write(TAFSEER_VAL, 0);
    }

    // Sync data to app controller after library is ready
    QuranController.instance.loadQuran();
    developer.log('✓ QuranLibrary initialized and filtered', name: 'QuranInit');
  } catch (e) {
    developer.log(
      '✗ QuranLibrary init failed: $e',
      name: 'QuranInit',
      error: e,
    );
  }

  try {
    tz.initializeTimeZones();
    developer.log('✓ Timezones initialized', name: 'QuranInit');
  } catch (e) {
    developer.log('✗ Timezones init failed: $e', name: 'QuranInit', error: e);
  }

  // Initialize GetX controllers needed by Quran
  try {
    Get.put(ThemeController());
    // LocalizationController is lazyPut in dep.init, but we can ensure it here if needed
    if (!Get.isRegistered<LocalizationController>()) {
      Get.put(LocalizationController());
    }
    developer.log('✓ Quran controllers initialized', name: 'QuranInit');
  } catch (e) {
    developer.log('✗ Controller init failed: $e', name: 'QuranInit', error: e);
  }

  developer.log('Quran feature initialization complete', name: 'QuranInit');
  return languages;
}
