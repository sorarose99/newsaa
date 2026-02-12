class AppConstants {
  static const String appName = 'الصلاة على النبي';
  static const String appNameEn = 'Salawat Reminder';

  static const int defaultReminderInterval = 15;
  static const int maxReminderInterval = 1440;
  static const int minReminderInterval = 1;

  static const List<String> salawatFormats = [
    'اللهم صل وسلم على نبينا محمد ﷺ',
    'صلى الله عليه وسلم',
    'اللهم صل على محمد وعلى آل محمد كما صليت على إبراهيم وعلى آل إبراهيم إنك حميد مجيد',
    'اللهم بارك على محمد وعلى آل محمد كما باركت على إبراهيم وعلى آل إبراهيم إنك حميد مجيد',
    'صل على النبي ',
    'اللهم صل على سيدنا محمد  ',
    'صلى الله عليه وسلم  ',
    'اللهم صل على سيدنا محمد عبدك ورسولك  ',
  ];

  static const String hiveBoxName = 'salawat_box';
  static const String settingsBoxName = 'settings_box';
}
