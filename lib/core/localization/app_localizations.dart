import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ru'),
    Locale('sw'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Salawat Reminder'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @virtues.
  ///
  /// In en, this message translates to:
  /// **'Virtues'**
  String get virtues;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Salawat Count'**
  String get counter;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tapToPray.
  ///
  /// In en, this message translates to:
  /// **'Tap to Pray'**
  String get tapToPray;

  /// No description provided for @totalSalawat.
  ///
  /// In en, this message translates to:
  /// **'Total Salawat'**
  String get totalSalawat;

  /// No description provided for @todaySalawat.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Salawat'**
  String get todaySalawat;

  /// No description provided for @weeklyStats.
  ///
  /// In en, this message translates to:
  /// **'Weekly Statistics'**
  String get weeklyStats;

  /// No description provided for @monthlyStats.
  ///
  /// In en, this message translates to:
  /// **'Monthly Statistics'**
  String get monthlyStats;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enableDark.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get enableDark;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminders'**
  String get enableReminders;

  /// No description provided for @reminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular reminders to send Salawat'**
  String get reminderDesc;

  /// No description provided for @reminderInterval.
  ///
  /// In en, this message translates to:
  /// **'Repeat Interval'**
  String get reminderInterval;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @salawatFormat.
  ///
  /// In en, this message translates to:
  /// **'Salawat Format'**
  String get salawatFormat;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get urdu;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @ukrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get ukrainian;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get version;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @selectInterval.
  ///
  /// In en, this message translates to:
  /// **'Select Interval'**
  String get selectInterval;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @peaceBe.
  ///
  /// In en, this message translates to:
  /// **'Peace be upon him'**
  String get peaceBe;

  /// No description provided for @soundLibrary.
  ///
  /// In en, this message translates to:
  /// **'Sound Library'**
  String get soundLibrary;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @virtueInfo.
  ///
  /// In en, this message translates to:
  /// **'Virtues of Salawat'**
  String get virtueInfo;

  /// No description provided for @resetToday.
  ///
  /// In en, this message translates to:
  /// **'Reset Today'**
  String get resetToday;

  /// No description provided for @resetWeek.
  ///
  /// In en, this message translates to:
  /// **'Reset Week'**
  String get resetWeek;

  /// No description provided for @resetMonth.
  ///
  /// In en, this message translates to:
  /// **'Reset Month'**
  String get resetMonth;

  /// No description provided for @resetCounter.
  ///
  /// In en, this message translates to:
  /// **'Reset Counter'**
  String get resetCounter;

  /// No description provided for @confirmReset.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the counter?'**
  String get confirmReset;

  /// No description provided for @resetCounterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Counter reset successfully'**
  String get resetCounterSuccess;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get lastSevenDays;

  /// No description provided for @lastThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get lastThirtyDays;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highest;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @selectLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language to continue'**
  String get selectLanguageDescription;

  /// No description provided for @pauseRemindersInTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Pause reminders during time range'**
  String get pauseRemindersInTimeRange;

  /// No description provided for @pauseRemindersInTimeRangeDesc.
  ///
  /// In en, this message translates to:
  /// **'Disable notifications during a specific time range'**
  String get pauseRemindersInTimeRangeDesc;

  /// No description provided for @stopDuringCalls.
  ///
  /// In en, this message translates to:
  /// **'Pause reminders during calls'**
  String get stopDuringCalls;

  /// No description provided for @stopDuringCallsDesc.
  ///
  /// In en, this message translates to:
  /// **'Disable notifications when a call is active'**
  String get stopDuringCallsDesc;

  /// No description provided for @notifyInSilent.
  ///
  /// In en, this message translates to:
  /// **'Notify in silent mode'**
  String get notifyInSilent;

  /// No description provided for @notifyInSilentDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders even when the device is silent'**
  String get notifyInSilentDesc;

  /// No description provided for @notificationVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder volume level'**
  String get notificationVolumeLabel;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareVia.
  ///
  /// In en, this message translates to:
  /// **'Share via'**
  String get shareVia;

  /// No description provided for @shareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsapp;

  /// No description provided for @shareFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get shareFacebook;

  /// No description provided for @shareInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get shareInstagram;

  /// No description provided for @shareTwitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get shareTwitter;

  /// No description provided for @shareMessenger.
  ///
  /// In en, this message translates to:
  /// **'Messenger'**
  String get shareMessenger;

  /// No description provided for @languageSupportNote.
  ///
  /// In en, this message translates to:
  /// **'Supports 11 languages: Arabic, English, Indonesian, Russian, French, Urdu, Turkish, Chinese, Ukrainian, Swahili, Spanish'**
  String get languageSupportNote;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @timeRangeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Time Range Schedule'**
  String get timeRangeSchedule;

  /// No description provided for @timeRangeScheduleDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a time range to stop notifications'**
  String get timeRangeScheduleDesc;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Daily goal message
  ///
  /// In en, this message translates to:
  /// **'Your current goal: {currentGoal} Salawat on the Prophet, peace be upon him'**
  String dailyGoal(int currentGoal);

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @defaultNotificationSound.
  ///
  /// In en, this message translates to:
  /// **'Default Notification Sound'**
  String get defaultNotificationSound;

  /// No description provided for @soundSelected.
  ///
  /// In en, this message translates to:
  /// **'A sound has been selected for reminders'**
  String get soundSelected;

  /// No description provided for @noSoundSelected.
  ///
  /// In en, this message translates to:
  /// **'No reminder sound has been selected yet'**
  String get noSoundSelected;

  /// No description provided for @additionalOptions.
  ///
  /// In en, this message translates to:
  /// **'Additional Options'**
  String get additionalOptions;

  /// No description provided for @countingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Counting Speed'**
  String get countingSpeed;

  /// No description provided for @countingSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the counting speed when holding down'**
  String get countingSpeedDesc;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Salawat Reminder App - Regular reminders to send Salawat on Prophet Muhammad'**
  String get shareText;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Salawat Reminder App'**
  String get appTitle;

  /// No description provided for @versionText.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get versionText;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'A dedicated app to remind you to send Salawat on Prophet Muhammad, peace be upon him, regularly.'**
  String get appDescription;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyContent.
  ///
  /// In en, this message translates to:
  /// **'We care about your privacy. Our app does not collect sensitive personal data and does not share user data with third parties.'**
  String get privacyContent;

  /// No description provided for @dataUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsageTitle;

  /// No description provided for @dataUsageContent.
  ///
  /// In en, this message translates to:
  /// **'All saved data remains on your device and is not sent to our servers except in very limited cases.'**
  String get dataUsageContent;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Salawat Reminder'**
  String get notificationTitle;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Salawat Reminder'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular reminders to send Salawat on Prophet Muhammad, peace be upon him'**
  String get notificationChannelDesc;

  /// No description provided for @notificationTicker.
  ///
  /// In en, this message translates to:
  /// **'Salawat Reminder'**
  String get notificationTicker;

  /// No description provided for @notificationSubtext.
  ///
  /// In en, this message translates to:
  /// **'Send Salawat on the Prophet ﷺ'**
  String get notificationSubtext;

  /// No description provided for @goalAchievementTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉'**
  String get goalAchievementTitle;

  /// No description provided for @goalAchievementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your goal! 🌟'**
  String get goalAchievementSubtitle;

  /// No description provided for @tier1_name.
  ///
  /// In en, this message translates to:
  /// **'Blessed Beginning'**
  String get tier1_name;

  /// No description provided for @tier1_message.
  ///
  /// In en, this message translates to:
  /// **'Blessed beginning, O one who sends Salawat on the Prophet, you have reached 100 Salawat'**
  String get tier1_message;

  /// No description provided for @tier2_name.
  ///
  /// In en, this message translates to:
  /// **'Rememberer of the Prophet'**
  String get tier2_name;

  /// No description provided for @tier2_message.
  ///
  /// In en, this message translates to:
  /// **'Rememberer of the Prophet, may Allah bless you, you have reached 500 Salawat'**
  String get tier2_message;

  /// No description provided for @tier3_name.
  ///
  /// In en, this message translates to:
  /// **'The Sincere Lover'**
  String get tier3_name;

  /// No description provided for @tier3_message.
  ///
  /// In en, this message translates to:
  /// **'Sincere love, continue, may Allah bless you, you have reached 1000 Salawat'**
  String get tier3_message;

  /// No description provided for @tier4_name.
  ///
  /// In en, this message translates to:
  /// **'Warrior in the Remembrance of the Prophet'**
  String get tier4_name;

  /// No description provided for @tier4_message.
  ///
  /// In en, this message translates to:
  /// **'Warrior in the remembrance of the Prophet, may Allah bless you, you have reached 5000 Salawat'**
  String get tier4_message;

  /// No description provided for @tier5_name.
  ///
  /// In en, this message translates to:
  /// **'Crown (For the Aware)'**
  String get tier5_name;

  /// No description provided for @tier5_message.
  ///
  /// In en, this message translates to:
  /// **'Crown (For the aware), may Allah bless you, you have reached 10000 Salawat'**
  String get tier5_message;

  /// No description provided for @tier6_name.
  ///
  /// In en, this message translates to:
  /// **'Friend of the Messenger'**
  String get tier6_name;

  /// No description provided for @tier6_message.
  ///
  /// In en, this message translates to:
  /// **'Friend of the Messenger, may Allah bless you, you have reached 30000 Salawat'**
  String get tier6_message;

  /// No description provided for @tier7_name.
  ///
  /// In en, this message translates to:
  /// **'The Foremost in Good Deeds'**
  String get tier7_name;

  /// No description provided for @tier7_message.
  ///
  /// In en, this message translates to:
  /// **'The foremost in good deeds, may Allah bless you, you have reached 50000 Salawat'**
  String get tier7_message;

  /// No description provided for @tier8_name.
  ///
  /// In en, this message translates to:
  /// **'The Diver in Remembrance of the Prophet'**
  String get tier8_name;

  /// No description provided for @tier8_message.
  ///
  /// In en, this message translates to:
  /// **'The diver in remembrance of the Prophet, may Allah bless you, you have reached 100000 Salawat'**
  String get tier8_message;

  /// No description provided for @tier9_name.
  ///
  /// In en, this message translates to:
  /// **'The Righteous Friend of Allah'**
  String get tier9_name;

  /// No description provided for @tier9_message.
  ///
  /// In en, this message translates to:
  /// **'The righteous friend of Allah, may Allah bless you, you have reached 200000 Salawat'**
  String get tier9_message;

  /// No description provided for @tier10_name.
  ///
  /// In en, this message translates to:
  /// **'Crescent in the Sky (Lover of the Prophet)'**
  String get tier10_name;

  /// No description provided for @tier10_message.
  ///
  /// In en, this message translates to:
  /// **'Crescent in the sky (Lover of the Prophet), may Allah bless you, you have reached 500000 Salawat'**
  String get tier10_message;

  /// No description provided for @tier11_name.
  ///
  /// In en, this message translates to:
  /// **'Lover of the Prophet'**
  String get tier11_name;

  /// No description provided for @tier11_message.
  ///
  /// In en, this message translates to:
  /// **'Lover of the Prophet, may Allah bless you, you have reached 750000 Salawat'**
  String get tier11_message;

  /// No description provided for @tier12_name.
  ///
  /// In en, this message translates to:
  /// **'Those Who Reached the Merciful'**
  String get tier12_name;

  /// No description provided for @tier12_message.
  ///
  /// In en, this message translates to:
  /// **'Those who reached the Merciful, may Allah bless you, you have reached 1000000 Salawat'**
  String get tier12_message;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Holy Quran'**
  String get quran;

  /// No description provided for @quranDesc.
  ///
  /// In en, this message translates to:
  /// **'Read and listen to the Holy Quran'**
  String get quranDesc;

  /// No description provided for @quranAppearance.
  ///
  /// In en, this message translates to:
  /// **'Quran Appearance'**
  String get quranAppearance;

  /// No description provided for @quranColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get quranColorGreen;

  /// No description provided for @quranColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue (Default)'**
  String get quranColorBlue;

  /// No description provided for @quranColorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get quranColorBrown;

  /// No description provided for @quranColorOld.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get quranColorOld;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @translationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translation Language'**
  String get translationLanguage;

  /// No description provided for @nothing.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get nothing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'id',
    'ru',
    'sw',
    'tr',
    'uk',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ru':
      return AppLocalizationsRu();
    case 'sw':
      return AppLocalizationsSw();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
