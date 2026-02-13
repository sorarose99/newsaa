import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alslat_aalnabi/core/services/audio_service.dart';
import 'package:alslat_aalnabi/features/admin/data/services/content_service.dart';
import 'package:alslat_aalnabi/features/admin/data/models/content_model.dart';
import 'package:alslat_aalnabi/features/settings/presentation/widgets/settings_provider.dart';

class AudioLibraryPage extends StatefulWidget {
  const AudioLibraryPage({super.key});

  @override
  State<AudioLibraryPage> createState() => _AudioLibraryPageState();
}

class _AudioLibraryPageState extends State<AudioLibraryPage> {
  final AudioService _audioService = AudioService();
  final ContentService _contentService = ContentService();
  double _volume = 0.5;

  late Future<List<PrayerFormulaSound>> _soundsFuture;
  String? _selectedSoundId;
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _volume = _audioService.volume;
    _soundsFuture = _loadSounds();

    // Initialize selected ID from provider
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    _selectedSoundId =
        settingsProvider.selectedReminderSoundId ?? 'default_sound';

    _audioService.setOnPlaybackComplete(() {
      if (mounted) {
        setState(() {
          _playingId = null;
        });
      }
    });
  }

  Future<List<PrayerFormulaSound>> _loadSounds() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final remoteSounds = await _contentService.getPrayerFormulaSounds();

    // Add default sound at the beginning
    final defaultSound = PrayerFormulaSound(
      id: 'default_sound',
      title: 'الصوت الافتراضي',
      url: 'assets/audio/default.mp3', // Special marker
      language: 'ar',
      isActive: true,
      soundBinary: null,
    );

    // Filter out any remote sound that tries to be "default" to avoid duplicates/confusion
    // This specifically targets the issue where a second "default" sound appears
    final filteredRemoteSounds = remoteSounds.where((sound) {
      return sound.id != 'default' &&
          sound.title.toLowerCase() != 'default' &&
          sound.title !=
              'الصوت الافتراضي'; // Also filter if it has the same Arabic title
    }).toList();

    return [defaultSound, ...filteredRemoteSounds];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مكتبة الأصوات')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مستوى الصوت',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.volume_down),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        label: '${(_volume * 100).toInt()}%',
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                          });
                          _audioService.setVolume(value);
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
                Text(
                  'المستوى الحالي: ${(_volume * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<PrayerFormulaSound>>(
              future: _soundsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ في تحميل الأصوات: ${snapshot.error}'),
                  );
                }

                final sounds = snapshot.data ?? [];
                if (sounds.isEmpty) {
                  return const Center(child: Text('لا توجد أصوات متاحة'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sounds.length,
                  itemBuilder: (context, index) {
                    final sound = sounds[index];
                    final isSelected = _selectedSoundId == sound.id;

                    final settingsProvider = context.read<SettingsProvider>();
                    final isReminderSound =
                        settingsProvider.selectedReminderSoundId == sound.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Icons.check : Icons.music_note,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                            title: Text(
                              sound.title,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(sound.language),
                            trailing: IconButton(
                              icon: Icon(
                                _playingId == sound.id
                                    ? Icons.stop_circle
                                    : Icons.play_circle_filled,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                              onPressed: () => _playSound(sound, context),
                            ),
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  _selectedSoundId = sound.id;
                                });
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم اختيار: ${sound.title}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                if (isReminderSound)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF00695C,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFF00695C),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.notifications_active,
                                            size: 16,
                                            color: Color(0xFF00695C),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'صوت التذكير المعتمد',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF00695C),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        final settingsProvider = context
                                            .read<SettingsProvider>();

                                        await settingsProvider
                                            .setSelectedReminderSoundId(
                                              sound.id,
                                            );

                                        final soundDataMap = {
                                          'id': sound.id,
                                          'title': sound.title,
                                          'language': sound.language,
                                          'sound_binary': sound.soundBinary,
                                          'created_at': sound.createdAt
                                              ?.toIso8601String(),
                                        };

                                        await settingsProvider
                                            .setSavedReminderSound(
                                              soundDataMap,
                                            );

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'تم تعيين "${sound.title}" كصوت التذكير',
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.notifications,
                                        size: 16,
                                      ),
                                      label: const Text('عيّن كصوت تذكير'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF00695C,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playSound(
    PrayerFormulaSound sound,
    BuildContext context,
  ) async {
    if (_playingId == sound.id) {
      await _audioService.stop();
      if (mounted) setState(() => _playingId = null);
    } else {
      if (sound.id != 'default_sound' &&
          (sound.soundBinary == null || sound.soundBinary!.isEmpty)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ملف الصوت فارغ: ${sound.title} (${sound.language})',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _playingId = sound.id;
        });
      }

      try {
        if (sound.id == 'default_sound') {
          await _audioService.playAssetSound('assets/audio/default.mp3');
        } else if (sound.soundBinary != null && sound.soundBinary!.isNotEmpty) {
          if (sound.soundBinary!.length < 50) {
            throw Exception(
              'بيانات الصوت صغيرة جداً - قد تكون تالفة (${sound.soundBinary!.length} بايت فقط)',
            );
          }
          await _audioService.playBinarySound(sound.soundBinary!);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _playingId = null;
          });
        }
        if (context.mounted) {
          String errorMessage = 'خطأ في تشغيل الصوت: ${sound.title}';
          final errorStr = e.toString().toLowerCase();

          if (errorStr.contains('binary is empty')) {
            errorMessage =
                'البيانات الصوتية فارغة - لم يتم تحميل الملف بشكل صحيح';
          } else if (errorStr.contains('media_error')) {
            errorMessage = 'صيغة الصوت غير مدعومة أو الملف تالف';
          } else if (errorStr.contains('failed to set source') ||
              errorStr.contains('source object is invalid')) {
            errorMessage = 'فشل في تحميل ملف الصوت - تأكد من سلامة البيانات';
          } else if (errorStr.contains('permission')) {
            errorMessage = 'تنقص أذونات الوصول للصوت';
          } else if (errorStr.contains('صغيرة جداً')) {
            errorMessage = 'ملف الصوت تالف - حجمه صغير جداً';
          } else if (errorStr.contains('failed to create temporary')) {
            errorMessage = 'فشل في حفظ ملف الصوت مؤقتاً';
          } else if (errorStr.contains('decode')) {
            errorMessage = 'خطأ في فك تشفير بيانات الصوت';
          } else {
            errorMessage = 'خطأ: ${e.toString().split('\n').first}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }
}
