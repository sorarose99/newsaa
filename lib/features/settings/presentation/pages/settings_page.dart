import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';
import 'package:alslat_aalnabi/core/widgets/secret_admin_access_widget.dart';
import 'package:alslat_aalnabi/features/settings/presentation/widgets/settings_provider.dart';
import 'package:alslat_aalnabi/features/audio/presentation/pages/audio_library_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: SecretAdminAccessWidget(
          onSecretGestureDetected: () {
            Navigator.pushNamed(context, '/admin-login');
          },
          child: Text(localizations.settings),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          final languageLabels = {
            'ar': '${localizations.arabic} (Arabic)',
            'en': '${localizations.english} (English)',
            'id': '${localizations.indonesian} (Bahasa Indonesia)',
            'ru': '${localizations.russian} (Русский)',
            'fr': '${localizations.french} (Français)',
            'ur': '${localizations.urdu} (اردو)',
            'tr': '${localizations.turkish} (Türkçe)',
            'zh': '${localizations.chinese} (Chinese)',
            'uk': '${localizations.ukrainian} (Ukrainian)',
            'sw': '${localizations.swahili} (Swahili)',
            'es': '${localizations.spanish} (Spanish)',
          };
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          localizations.appearance,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildAppearanceOption(
                                context,
                                provider,
                                'green',
                                const Color(0xFF388E3C),
                                localizations.quranColorGreen,
                              ),
                              const SizedBox(width: 16),
                              _buildAppearanceOption(
                                context,
                                provider,
                                'blue',
                                const Color(0xff404C6E),
                                localizations.quranColorBlue,
                              ),
                              const SizedBox(width: 16),
                              _buildAppearanceOption(
                                context,
                                provider,
                                'brown',
                                const Color(0xff583623),
                                localizations.quranColorBrown,
                              ),
                              const SizedBox(width: 16),
                              _buildAppearanceOption(
                                context,
                                provider,
                                'old',
                                const Color(0xff232c13),
                                localizations.quranColorOld,
                              ),
                              const SizedBox(width: 16),
                              _buildAppearanceOption(
                                context,
                                provider,
                                'dark',
                                const Color(0xff121212),
                                localizations.darkMode,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          localizations.notifications,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: Text(localizations.enableReminders),
                        subtitle: Text(localizations.reminderDesc),
                        value: provider.isReminderEnabled,
                        onChanged: (_) => provider.toggleReminder(),
                        secondary: const Icon(Icons.notifications),
                      ),
                      ListTile(
                        leading: const Icon(Icons.timer),
                        title: Text(localizations.reminderInterval),
                        subtitle: Text(
                          '${localizations.every} ${provider.reminderInterval} ${localizations.minutes}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showIntervalDialog(
                          context,
                          provider,
                          localizations,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(localizations.soundLibrary),
                        subtitle: Text(localizations.notificationSound),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AudioLibraryPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: Text(localizations.defaultNotificationSound),
                        subtitle: Text(
                          provider.selectedReminderSoundId != null
                              ? localizations.soundSelected
                              : localizations.noSoundSelected,
                        ),
                        trailing: provider.selectedReminderSoundId != null
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const Icon(
                                Icons.circle_outlined,
                                color: Colors.grey,
                              ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AudioLibraryPage(),
                            ),
                          );
                        },
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.schedule),
                        title: Text(localizations.pauseRemindersInTimeRange),
                        subtitle: Text(
                          localizations.pauseRemindersInTimeRangeDesc,
                        ),
                        value: provider.pauseRemindersInTimeRange,
                        onChanged: (_) =>
                            provider.togglePauseRemindersInTimeRange(),
                      ),
                      if (provider.pauseRemindersInTimeRange)
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(localizations.timeRangeSchedule),
                          subtitle: Text(
                            '${provider.timeRangeStart.format(context)} - ${provider.timeRangeEnd.format(context)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showTimeRangeScheduleDialog(
                            context,
                            provider,
                            localizations,
                          ),
                        ),
                      SwitchListTile(
                        secondary: const Icon(Icons.phone_disabled),
                        title: Text(localizations.stopDuringCalls),
                        subtitle: Text(localizations.stopDuringCallsDesc),
                        value: provider.stopDuringCalls,
                        onChanged: (_) => provider.toggleStopDuringCalls(),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.volume_off),
                        title: Text(localizations.notifyInSilent),
                        subtitle: Text(localizations.notifyInSilentDesc),
                        value: provider.notifyInSilent,
                        onChanged: (_) => provider.toggleNotifyInSilent(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.volume_up, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.notificationVolumeLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.volume_down, size: 20),
                                Expanded(
                                  child: Slider(
                                    value: provider.notificationVolume,
                                    min: 0,
                                    max: 1,
                                    divisions: 10,
                                    label:
                                        '${(provider.notificationVolume * 100).toInt()}%',
                                    onChanged: (value) =>
                                        provider.setVolume(value),
                                  ),
                                ),
                                const Icon(Icons.volume_up, size: 20),
                              ],
                            ),
                            Center(
                              child: Text(
                                '${(provider.notificationVolume * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.language, color: Colors.grey),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                localizations.language,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: provider.language,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  provider.setLanguage(newValue);
                                  provider.setNotificationTitle(
                                    localizations.notificationTitle,
                                  );
                                }
                              },
                              items: languageLabels.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value.split('(')[0].trim()),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          localizations.languageSupportNote,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          localizations.additionalOptions,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: Text(localizations.shareApp),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          SharePlus.instance.share(
                            ShareParams(text: localizations.shareText),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(localizations.rateApp),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localizations.rateApp)),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(localizations.aboutUs),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showAboutDialog(context, localizations);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: Text(localizations.privacyPolicy),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showPrivacyPolicyDialog(context, localizations);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_mail),
                        title: Text(localizations.contactUs),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showContactDialog(context, localizations);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: Text(localizations.admin),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/admin-login');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showIntervalDialog(
    BuildContext context,
    SettingsProvider provider,
    AppLocalizations localizations,
  ) {
    final intervals = [1, 5, 10, 20, 30, 60, 120, 360, 1440];
    final intervalLabels = [
      '1 ${localizations.minutes}',
      '5 ${localizations.minutes}',
      '10 ${localizations.minutes}',
      '20 ${localizations.minutes}',
      '30 ${localizations.minutes}',
      '1 ${localizations.hour}',
      '2 ${localizations.hour}',
      '6 ${localizations.hour}',
      '24 ${localizations.hour}',
    ];

    showDialog(
      context: context,
      builder: (context) {
        int tempInterval = provider.reminderInterval;
        return AlertDialog(
          title: Text(localizations.selectInterval),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${localizations.every} ${tempInterval >= 60 ? tempInterval ~/ 60 : tempInterval} ${tempInterval >= 60 ? localizations.hour : localizations.minutes}',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: GridView.count(
                          physics: const AlwaysScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: List.generate(intervals.length, (index) {
                            final interval = intervals[index];
                            final isSelected = tempInterval == interval;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  tempInterval = interval;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.1)
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    intervalLabels[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setReminderInterval(tempInterval);
                Navigator.pop(context);
              },
              child: Text(localizations.save),
            ),
          ],
        );
      },
    );
  }

  void _showTimeRangeScheduleDialog(
    BuildContext context,
    SettingsProvider provider,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        TimeOfDay tempStart = provider.timeRangeStart;
        TimeOfDay tempEnd = provider.timeRangeEnd;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.timeRangeSchedule),
              content: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.from,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: tempStart,
                              );
                              if (time != null) {
                                setState(() {
                                  tempStart = time;
                                });
                              }
                            },
                            child: Text(tempStart.format(context)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.to,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: tempEnd,
                              );
                              if (time != null) {
                                setState(() {
                                  tempEnd = time;
                                });
                              }
                            },
                            child: Text(tempEnd.format(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.setTimeRangeStartTime(tempStart);
                    provider.setTimeRangeEndTime(tempEnd);
                    Navigator.pop(context);
                  },
                  child: Text(localizations.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.aboutUs),
          content: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.appTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(localizations.versionText),
                const SizedBox(height: 16),
                Text(
                  localizations.appDescription,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.close),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.privacyPolicy),
          content: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.privacyPolicyTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.privacyContent,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.dataUsageTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.dataUsageContent,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.close),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.contactUs),
          content: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildContactOption(
                  context,
                  localizations.whatsapp,
                  '+966558756280',
                  Icons.chat,
                  () {
                    Navigator.pop(context);
                    _launchWhatsApp('+966558756280');
                  },
                ),
                const SizedBox(height: 12),
                _buildContactOption(
                  context,
                  localizations.email,
                  'jr7ah2020@gmail.com',
                  Icons.email,
                  () {
                    Navigator.pop(context);
                    _launchEmail('jr7ah2020@gmail.com');
                  },
                ),
                const SizedBox(height: 12),
                _buildContactOption(
                  context,
                  localizations.telegram,
                  '@Yahya_2040',
                  Icons.send,
                  () {
                    Navigator.pop(context);
                    _launchTelegram('@Yahya_2040');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactOption(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchTelegram(String username) async {
    final url = 'https://t.me/${username.replaceFirst('@', '')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAppearanceOption(
    BuildContext context,
    SettingsProvider provider,
    String styleValue,
    Color color,
    String label,
  ) {
    final isSelected = provider.quranTheme == styleValue;
    return InkWell(
      onTap: () => provider.setAppearanceStyle(styleValue),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 30)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
