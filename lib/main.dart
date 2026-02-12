import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alslat_aalnabi/features/quran/quran_init.dart';
import 'package:alslat_aalnabi/features/quran/myApp.dart';
import 'package:alslat_aalnabi/features/quran/core/services/languages/messages.dart';
import 'package:alslat_aalnabi/core/theme/app_theme.dart';
import 'package:alslat_aalnabi/core/services/notification_service.dart';
import 'package:alslat_aalnabi/core/services/storage_service.dart';
import 'package:alslat_aalnabi/core/services/audio_service.dart';
import 'package:alslat_aalnabi/core/services/supabase_service.dart';
import 'package:alslat_aalnabi/core/services/sync_manager_service.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';
import 'package:alslat_aalnabi/core/providers/sync_provider.dart';
import 'package:alslat_aalnabi/features/salawat_counter/presentation/widgets/salawat_counter_provider.dart';
import 'package:alslat_aalnabi/features/settings/presentation/widgets/settings_provider.dart';
import 'package:alslat_aalnabi/features/admin/presentation/providers/admin_provider.dart';
import 'package:alslat_aalnabi/features/admin/presentation/pages/admin_login_page.dart';
import 'package:alslat_aalnabi/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:alslat_aalnabi/features/home/presentation/pages/home_page.dart';
import 'package:alslat_aalnabi/features/info/presentation/providers/info_provider.dart';
import 'package:alslat_aalnabi/features/audio/presentation/providers/audio_provider.dart';
import 'package:alslat_aalnabi/features/virtues/presentation/providers/virtues_provider.dart';
import 'package:alslat_aalnabi/features/virtues/presentation/providers/download_provider.dart';
import 'package:alslat_aalnabi/features/splash/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Quran feature and get languages
  Map<String, Map<String, String>> quranLanguages = await initQuranFeature();

  await SupabaseService().initialize();
  await StorageService().initialize();
  await NotificationService().initialize();
  await AudioService().initialize();

  await SyncManagerService().initialize();

  runApp(MyApp(quranLanguages: quranLanguages));
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> quranLanguages;
  const MyApp({super.key, required this.quranLanguages});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => SalawatCounterProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => InfoProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => VirtuesProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return GetMaterialApp(
                title: 'الصلاة على النبي',
                debugShowCheckedModeBanner: false,
                scrollBehavior: AppScrollBehavior(),

                theme: AppTheme.getTheme(settingsProvider.quranTheme).copyWith(
                  useMaterial3: false,
                ),

                darkTheme: AppTheme.darkTheme,

                themeMode: settingsProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: const SplashPage(),
                locale: Locale(settingsProvider.language),
                fallbackLocale: const Locale('en'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,

                // Inject Quran translations into GetX
                translations: Messages(languages: quranLanguages),

                // BotToast integration
                builder: BotToastInit(),
                navigatorObservers: [BotToastNavigatorObserver()],

                routes: {
                  '/admin-login': (context) => const AdminLoginPage(),
                  '/admin-dashboard': (context) => const AdminDashboardPage(),
                  '/home': (context) => const HomePage(),
                  '/quran': (context) => const QuranAppWrapper(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
