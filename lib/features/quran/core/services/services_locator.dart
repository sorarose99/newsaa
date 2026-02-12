import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:alslat_aalnabi/features/quran/presentation/controllers/general/general_controller.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/theme_controller.dart';
import 'package:alslat_aalnabi/features/quran/presentation/controllers/settings_controller.dart';
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/quran.dart';
import 'package:alslat_aalnabi/features/quran/presentation/screens/quran_page/widgets/search/controller/quran_search_controller.dart';
import 'package:alslat_aalnabi/features/quran/core/widgets/local_notification/controller/local_notifications_controller.dart';

final sl = GetIt.instance;

class ServicesLocator {
  Future<void> init() async {
    // Controllers
    sl.registerLazySingleton<ThemeController>(
      () => Get.put<ThemeController>(ThemeController(), permanent: true),
    );

    sl.registerLazySingleton<GeneralController>(
      () => Get.put<GeneralController>(GeneralController(), permanent: true),
    );

    sl.registerLazySingleton<AudioController>(
      () => Get.put<AudioController>(AudioController(), permanent: true),
    );

    sl.registerSingleton<QuranController>(
      Get.put<QuranController>(QuranController(), permanent: true),
    );

    sl.registerLazySingleton<TranslateController>(
      () =>
          Get.put<TranslateController>(TranslateController(), permanent: true),
    );

    sl.registerLazySingleton<BookmarksController>(
      () =>
          Get.put<BookmarksController>(BookmarksController(), permanent: true),
    );

    sl.registerLazySingleton<QuranSearchController>(
      () => Get.put<QuranSearchController>(
        QuranSearchController(),
        permanent: true,
      ),
    );

    sl.registerLazySingleton<SettingsController>(
      () => Get.put<SettingsController>(SettingsController(), permanent: true),
    );

    sl.registerLazySingleton<ShareController>(
      () => Get.put<ShareController>(ShareController(), permanent: true),
    );

    sl.registerLazySingleton<PlayListController>(
      () => Get.put<PlayListController>(PlayListController(), permanent: true),
    );

    sl.registerLazySingleton<KhatmahController>(
      () => Get.put<KhatmahController>(KhatmahController(), permanent: true),
    );

    sl.registerLazySingleton<LocalNotificationsController>(
      () => Get.put<LocalNotificationsController>(
        LocalNotificationsController(),
        permanent: true,
      ),
    );

    tz.initializeTimeZones();
  }
}
