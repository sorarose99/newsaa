import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:alslat_aalnabi/features/admin/data/models/content_model.dart';
import 'package:alslat_aalnabi/features/admin/presentation/providers/admin_provider.dart';
import 'package:alslat_aalnabi/core/services/audio_service.dart';
import 'dart:io';
import 'dart:developer' as developer;

class PrayerFormulaSoundsManagementPage extends StatefulWidget {
  const PrayerFormulaSoundsManagementPage({super.key});

  @override
  State<PrayerFormulaSoundsManagementPage> createState() =>
      _PrayerFormulaSoundsManagementPageState();
}

class _PrayerFormulaSoundsManagementPageState
    extends State<PrayerFormulaSoundsManagementPage> {
  static const List<String> _languages = [
    'ar',
    'en',
    'fr',
    'id',
    'ru',
    'tr',
    'ur',
  ];

  static const Map<String, String> _languageNames = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'id': 'Bahasa Indonesia',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'ur': 'اردو',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPrayerFormulaSounds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة صيغ الصلاة الصوتية')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          final colorScheme = Theme.of(context).colorScheme;
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sounds = adminProvider.prayerFormulaSounds;

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: sounds.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddSoundDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة صيغة صلاة صوتية'),
                  ),
                );
              }

              final sound = sounds[index - 1];
              final hasValidId = sound.id != null && sound.id!.isNotEmpty;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: GestureDetector(
                    onTap: () async {
                      if (!hasValidId) return;
                      if (sound.url == null && sound.soundBinary == null) {
                        return;
                      }
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جاري تشغيل الصوت...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        if (sound.soundBinary != null &&
                            sound.soundBinary!.isNotEmpty) {
                          await AudioService().playBinarySound(
                            sound.soundBinary!,
                          );
                        } else if (sound.url != null && sound.url!.isNotEmpty) {
                          if (sound.url!.startsWith('http')) {
                            await AudioService().playFromUrl(sound.url!);
                          } else {
                            await AudioService().playNotificationSound(
                              sound.url!,
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فشل تشغيل الصوت: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getLanguageColor(sound.language),
                            _getLanguageColor(
                              sound.language,
                            ).withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getLanguageColor(
                              sound.language,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          hasValidId
                              ? Icons.play_arrow_rounded
                              : Icons.error_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    sound.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getLanguageColor(
                              sound.language,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _languageNames[sound.language] ?? sound.language,
                            style: TextStyle(
                              color: _getLanguageColor(sound.language),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          sound.isActive
                              ? Icons.check_circle
                              : Icons.pause_circle_filled,
                          size: 14,
                          color: sound.isActive ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sound.isActive ? "مفعل" : "معطل",
                          style: TextStyle(
                            fontSize: 12,
                            color: sound.isActive
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: hasValidId
                            ? () => _showEditSoundDialog(context, sound)
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'لا يمكن تعديل هذا الصوت - بدون معرف صحيح',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: hasValidId
                            ? () => _showDeleteConfirmation(context, sound.id)
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'لا يمكن حذف هذا الصوت - بدون معرف صحيح',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
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

  Color _getLanguageColor(String language) {
    final colors = {
      'ar': const Color(0xFF00695C),
      'en': const Color(0xFF1565C0),
      'fr': const Color(0xFFC41C3B),
      'id': const Color(0xFFFF0000),
      'ru': const Color(0xFF0039A6),
      'tr': const Color(0xFFE30613),
      'ur': const Color(0xFF006622),
    };
    return colors[language] ?? const Color(0xFF666666);
  }

  void _showAddSoundDialog(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String selectedLanguage = 'ar';
    String? selectedFileName;
    String? selectedFilePath;
    Uint8List? selectedAudioBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة صيغة صلاة صوتية'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الصيغة',
                    hintText: 'مثال: الصلاة الإبراهيمية',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'اللغة',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  initialValue: selectedLanguage,
                  isExpanded: true,
                  items: _languages
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(_languageNames[lang] ?? lang),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الملف الصوتي (URL)',
                    hintText: 'https://example.com/audio.mp3',
                    prefixIcon: Icon(Icons.link),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        selectedAudioBytes = null;
                        selectedFilePath = null;
                        selectedFileName = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'أو اختر ملف صوتي من الجهاز:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedFileName!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            withData: kIsWeb,
                            allowedExtensions: [
                              'mp3',
                              'wav',
                              'aac',
                              'm4a',
                              'ogg',
                            ],
                          );
                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          selectedAudioBytes = result.files.single.bytes;
                          selectedFilePath = result.files.single.path;
                          selectedFileName = result.files.single.name;
                          urlController.clear();
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                      }
                    }
                  },
                  icon: const Icon(Icons.audio_file),
                  label: const Text('اختر ملف صوتي'),
                ),
                if (selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton.icon(
                      onPressed:
                          (selectedAudioBytes != null ||
                              (selectedFilePath != null && !kIsWeb))
                          ? () async {
                              try {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'جاري اختبار الملف الصوتي...',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                if (selectedAudioBytes != null) {
                                  await AudioService().playBinarySound(
                                    selectedAudioBytes!,
                                  );
                                } else if (selectedFilePath != null) {
                                  await AudioService().playNotificationSound(
                                    selectedFilePath!,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('فشل الاختبار: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('اختبر الملف'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    (selectedAudioBytes != null ||
                        urlController.text.isNotEmpty ||
                        (selectedFilePath != null && !kIsWeb))) {
                  final provider = Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  );

                  if (selectedAudioBytes != null) {
                    await provider.addPrayerFormulaSoundWithBytes(
                      selectedAudioBytes!,
                      PrayerFormulaSound(
                        language: selectedLanguage,
                        title: titleController.text,
                        isActive: true,
                      ),
                    );
                  } else if (selectedFilePath != null) {
                    await provider.addPrayerFormulaSoundWithFile(
                      File(selectedFilePath!),
                      PrayerFormulaSound(
                        language: selectedLanguage,
                        title: titleController.text,
                        isActive: true,
                      ),
                    );
                  } else {
                    await provider.addPrayerFormulaSound(
                      PrayerFormulaSound(
                        language: selectedLanguage,
                        title: titleController.text,
                        isActive: true,
                        url: urlController.text,
                      ),
                    );
                  }

                  if (context.mounted) {
                    if (provider.errorMessage.isEmpty) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'يجب ملء العنوان واختيار ملف صوتي أو وضع رابط',
                      ),
                    ),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSoundDialog(BuildContext context, PrayerFormulaSound sound) {
    final titleController = TextEditingController(text: sound.title);
    final urlController = TextEditingController(text: sound.url ?? '');
    String selectedLanguage = sound.language;
    String? selectedFileName;
    String? selectedFilePath;
    Uint8List? selectedAudioBytesToUpload;
    bool isActive = sound.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل صيغة الصلاة الصوتية'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان الصيغة'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'اللغة',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  initialValue: selectedLanguage,
                  isExpanded: true,
                  items: _languages
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(_languageNames[lang] ?? lang),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value ?? true;
                    });
                  },
                  title: const Text('مفعل'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الملف الصوتي (URL)',
                    hintText: 'https://example.com/audio.mp3',
                    prefixIcon: Icon(Icons.link),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        selectedAudioBytesToUpload = null;
                        selectedFilePath = null;
                        selectedFileName = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'أو استبدال الملف الصوتي (اختياري):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedFileName!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            withData: kIsWeb,
                            allowedExtensions: [
                              'mp3',
                              'wav',
                              'aac',
                              'm4a',
                              'ogg',
                            ],
                          );
                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          selectedAudioBytesToUpload =
                              result.files.single.bytes;
                          selectedFilePath = result.files.single.path;
                          selectedFileName = result.files.single.name;
                          urlController.clear();
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطأ في اختيار الملف: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.audio_file),
                  label: const Text('اختر ملف صوتي جديد'),
                ),
                if (selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton.icon(
                      onPressed:
                          (selectedAudioBytesToUpload != null ||
                              (selectedFilePath != null && !kIsWeb))
                          ? () async {
                              try {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'جاري اختبار الملف الصوتي...',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                if (selectedAudioBytesToUpload != null) {
                                  await AudioService().playBinarySound(
                                    selectedAudioBytesToUpload!,
                                  );
                                } else if (selectedFilePath != null) {
                                  await AudioService().playNotificationSound(
                                    selectedFilePath!,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('فشل الاختبار: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('اختبر الملف الجديد'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يجب ملء العنوان')),
                  );
                  return;
                }

                final provider = Provider.of<AdminProvider>(
                  context,
                  listen: false,
                );

                if (selectedAudioBytesToUpload != null) {
                  await provider.updatePrayerFormulaSoundWithBytes(
                    selectedAudioBytesToUpload!,
                    sound.copyWith(
                      title: titleController.text,
                      language: selectedLanguage,
                      isActive: isActive,
                      url: '',
                    ),
                  );
                } else if (selectedFilePath != null) {
                  await provider.updatePrayerFormulaSoundWithFile(
                    File(selectedFilePath!),
                    sound.copyWith(
                      title: titleController.text,
                      language: selectedLanguage,
                      isActive: isActive,
                      url: '',
                    ),
                  );
                } else {
                  await provider.updatePrayerFormulaSound(
                    sound.copyWith(
                      title: titleController.text,
                      language: selectedLanguage,
                      isActive: isActive,
                      url: urlController.text.isNotEmpty
                          ? urlController.text
                          : sound.url,
                    ),
                  );
                }

                if (context.mounted) {
                  if (provider.errorMessage.isEmpty) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String? soundId) {
    if (soundId == null || soundId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: لا يمكن حذف هذا الصوت - معرف غير صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الصيغة الصوتية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري الحذف...'),
                  duration: Duration(seconds: 2),
                ),
              );

              try {
                await context.read<AdminProvider>().deletePrayerFormulaSound(
                  soundId,
                );

                if (context.mounted) {
                  final adminProvider = context.read<AdminProvider>();
                  if (adminProvider.errorMessage.isEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم الحذف بنجاح'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: ${adminProvider.errorMessage}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في الحذف: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
