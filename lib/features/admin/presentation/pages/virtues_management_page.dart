import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:alslat_aalnabi/features/virtues/presentation/widgets/video_thumbnail_preview.dart';
import 'package:alslat_aalnabi/features/virtues/data/models/virtue_model.dart';
import 'package:alslat_aalnabi/features/virtues/presentation/providers/virtues_provider.dart';

class VirtuesManagementPage extends StatefulWidget {
  const VirtuesManagementPage({super.key});

  @override
  State<VirtuesManagementPage> createState() => _VirtuesManagementPageState();
}

class _VirtuesManagementPageState extends State<VirtuesManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفضائل'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          labelColor: colorScheme.onPrimary,
          tabs: const [
            Tab(text: 'الفوائد', icon: Icon(Icons.star)),
            Tab(text: 'أوقات الإكثار', icon: Icon(Icons.schedule)),
            Tab(text: 'الصور', icon: Icon(Icons.image)),
            Tab(text: 'الفيديوهات', icon: Icon(Icons.video_library)),
          ],
        ),
      ),
      body: Consumer<VirtuesProvider>(
        builder: (context, virtuesProvider, child) {
          if (virtuesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (virtuesProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(virtuesProvider.errorMessage));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBenefitsTab(virtuesProvider),
              _buildTimesTab(virtuesProvider),
              _buildImagesTab(virtuesProvider),
              _buildVideosTab(virtuesProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBenefitsTab(VirtuesProvider provider) {
    final benefits = provider.virtues
        .where((v) => v.type == VirtueType.benefit)
        .toList();
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: benefits.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddBenefitDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة فائدة'),
            ),
          );
        }
        final benefit = benefits[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            // **التعديل هنا: استخدام .description بدلاً من .text**
            title: Text(benefit.description!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditBenefitDialog(benefit),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteVirtue(benefit.id!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimesTab(VirtuesProvider provider) {
    final times = provider.virtues
        .where((v) => v.type == VirtueType.time)
        .toList();
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: times.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTimeDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة وقت'),
            ),
          );
        }
        final time = times[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            // **التعديل هنا: استخدام .description بدلاً من .text**
            title: Text(time.description!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditTimeDialog(time),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.deleteVirtue(time.id!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagesTab(VirtuesProvider provider) {
    final images = provider.virtues
        .where((v) => v.type == VirtueType.image)
        .toList();
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: images.length + 1,
      itemBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        if (index == 0) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: InkWell(
              onTap: () => _showAddImageDialog(),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'إضافة صورة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final image = images[index - 1];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        image.imageBinary != null &&
                            image.imageBinary!.isNotEmpty
                        ? Image.memory(
                            Virtue.decodeImageFromBase64(image.imageBinary!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.error,
                                      colorScheme.error.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.error,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : image.url != null && image.url!.isNotEmpty
                        ? Image.network(
                            image.url!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.error,
                                      colorScheme.error.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.error,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          image.title!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          image.description!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _showEditImageDialog(image),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        provider.deleteVirtue(image.id!);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
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
  }

  Widget _buildVideosTab(VirtuesProvider provider) {
    final videos = provider.virtues
        .where((v) => v.type == VirtueType.video)
        .toList();
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: videos.length + 1,
      itemBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        if (index == 0) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: InkWell(
              onTap: () => _showAddVideoDialog(),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_call_rounded,
                    size: 48,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'إضافة فيديو',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final video = videos[index - 1];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: VideoThumbnailPreview(video: video)),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.description!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _showEditVideoDialog(video),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        provider.deleteVirtue(video.id!);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
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
  }

  void _showAddBenefitDialog() {
    final controller = TextEditingController();
    VirtueCategory? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة فائدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'النص'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VirtueCategory?>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'التصنيف',
                  ),
                  initialValue: selectedCategory,
                  hint: const Text('اختر فئة (اختياري)'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('بدون فئة'),
                    ),
                    const DropdownMenuItem(
                      value: VirtueCategory.quran,
                      child: Text('الأدلة من القرآن'),
                    ),
                    const DropdownMenuItem(
                      value: VirtueCategory.hadith,
                      child: Text('الأحاديث النبوية'),
                    ),
                    const DropdownMenuItem(
                      value: VirtueCategory.formula,
                      child: Text('صيغ الصلاة'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCategory = value);
                  },
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
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final provider = Provider.of<VirtuesProvider>(
                    context,
                    listen: false,
                  );
                  provider.addVirtue(
                    Virtue(
                      type: VirtueType.benefit,
                      category: selectedCategory,
                      // **التعديل هنا: استخدام description بدلاً من text**
                      description: controller.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBenefitDialog(Virtue virtue) {
    // **التعديل هنا: استخدام .description بدلاً من .text**
    final controller = TextEditingController(text: virtue.description);
    VirtueCategory? selectedCategory = virtue.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل الفائدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'النص'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VirtueCategory?>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'التصنيف',
                  ),
                  initialValue: selectedCategory,
                  hint: const Text('اختر فئة (اختياري)'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('بدون فئة'),
                    ),
                    const DropdownMenuItem(
                      value: VirtueCategory.quran,
                      child: Text('الأدلة من القرآن'),
                    ),
                    const DropdownMenuItem(
                      value: VirtueCategory.hadith,
                      child: Text('الأحاديث النبوية'),
                    ),
                    const DropdownMenuItem(
                      value: VirtueCategory.formula,
                      child: Text('صيغ الصلاة'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCategory = value);
                  },
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
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final provider = Provider.of<VirtuesProvider>(
                    context,
                    listen: false,
                  );
                  provider.updateVirtue(
                    Virtue(
                      id: virtue.id,
                      type: VirtueType.benefit,
                      category: selectedCategory,
                      // **التعديل هنا: استخدام description بدلاً من text**
                      description: controller.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTimeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة وقت'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'النص'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final provider = Provider.of<VirtuesProvider>(
                  context,
                  listen: false,
                );
                provider.addVirtue(
                  // **التعديل هنا: استخدام description بدلاً من text**
                  Virtue(type: VirtueType.time, description: controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditTimeDialog(Virtue virtue) {
    // **التعديل هنا: استخدام .description بدلاً من .text**
    final controller = TextEditingController(text: virtue.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الوقت'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'النص'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final provider = Provider.of<VirtuesProvider>(
                  context,
                  listen: false,
                );
                provider.updateVirtue(
                  Virtue(
                    id: virtue.id,
                    type: VirtueType.time,
                    // **التعديل هنا: استخدام description بدلاً من text**
                    description: controller.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showAddImageDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();
    PlatformFile? selectedFile;
    String? fileStatusMessage;
    Color? fileStatusColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة صورة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'اختر طريقة الإضافة:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                          withData: true,
                        );
                    if (result != null) {
                      final file = result.files.single;
                      final fileSize = file.size;
                      setState(() {
                        selectedFile = file;
                        if (fileSize < 1024) {
                          fileStatusMessage =
                              'تحذير: حجم الملف صغير جداً (${(fileSize / 1024).toStringAsFixed(2)} KB)';
                          fileStatusColor = Colors.orange;
                        } else {
                          fileStatusMessage =
                              'حجم الملف: ${(fileSize / 1024).toStringAsFixed(2)} KB - متوافق';
                          fileStatusColor = Colors.green;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('اختر صورة من الجهاز'),
                ),
                const SizedBox(height: 12),
                if (selectedFile != null)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'تم اختيار: ${selectedFile!.name}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (fileStatusMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            fileStatusMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: fileStatusColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (selectedFile!.bytes != null)
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('معاينة الصورة'),
                                content: Image.memory(selectedFile!.bytes!),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إغلاق'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.preview),
                          label: const Text('معاينة الصورة'),
                        ),
                    ],
                  ),
                const Divider(),
                const SizedBox(height: 8),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'أو أدخل رابط الصورة (URL)',
                    hintText: 'https://example.com/image.jpg',
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
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descController.text.isNotEmpty) {
                  if (selectedFile != null || urlController.text.isNotEmpty) {
                    final provider = Provider.of<VirtuesProvider>(
                      context,
                      listen: false,
                    );
                    provider.addVirtue(
                      Virtue(
                        type: VirtueType.image,
                        title: titleController.text,
                        description: descController.text,
                        url: urlController.text,
                        filePath: selectedFile?.name,
                      ),
                      fileBytes: selectedFile?.bytes,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يجب اختيار صورة أو إدخال رابط'),
                      ),
                    );
                  }
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditImageDialog(Virtue virtue) {
    final titleController = TextEditingController(text: virtue.title);
    final descController = TextEditingController(text: virtue.description);
    final urlController = TextEditingController(text: virtue.url);
    PlatformFile? selectedFile;
    String? fileStatusMessage;
    Color? fileStatusColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل الصورة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'اختر طريقة الإضافة:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (selectedFile != null && selectedFile!.bytes != null)
                  Image.memory(
                    selectedFile!.bytes!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else if (virtue.imageBinary != null &&
                    virtue.imageBinary!.isNotEmpty)
                  Image.memory(
                    Virtue.decodeImageFromBase64(virtue.imageBinary!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else if (virtue.url != null && virtue.url!.isNotEmpty)
                  Image.network(
                    virtue.url!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                          withData: true,
                        );
                    if (result != null) {
                      final file = result.files.single;
                      final fileSize = file.size;
                      setState(() {
                        selectedFile = file;
                        if (fileSize < 1024) {
                          fileStatusMessage =
                              'تحذير: حجم الملف صغير جداً (${(fileSize / 1024).toStringAsFixed(2)} KB)';
                          fileStatusColor = Colors.orange;
                        } else {
                          fileStatusMessage =
                              'حجم الملف: ${(fileSize / 1024).toStringAsFixed(2)} KB - متوافق';
                          fileStatusColor = Colors.green;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('اختر صورة من الجهاز'),
                ),
                const SizedBox(height: 12),
                if (selectedFile != null)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'تم اختيار: ${selectedFile!.name}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (fileStatusMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            fileStatusMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: fileStatusColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (selectedFile!.bytes != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('معاينة الصورة'),
                                content: Image.memory(selectedFile!.bytes!),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إغلاق'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.preview),
                          label: const Text('معاينة الصورة'),
                        ),
                    ],
                  ),
                const Divider(),
                const SizedBox(height: 8),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'أو أدخل رابط الصورة (URL)',
                    hintText: 'https://example.com/image.jpg',
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
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descController.text.isNotEmpty) {
                  if (selectedFile != null || urlController.text.isNotEmpty) {
                    final provider = Provider.of<VirtuesProvider>(
                      context,
                      listen: false,
                    );
                    provider.updateVirtue(
                      Virtue(
                        id: virtue.id,
                        type: VirtueType.image,
                        title: titleController.text,
                        description: descController.text,
                        url: urlController.text,
                        filePath: selectedFile?.name,
                        imageBinary: virtue.imageBinary,
                      ),
                      fileBytes: selectedFile?.bytes,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يجب اختيار صورة أو إدخال رابط'),
                      ),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  // **الدالة المفقودة (التي تسببت في الخطأ)**
  void _showAddVideoDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final urlController = TextEditingController();
    String? selectedFilePath;
    Uint8List? selectedFileBytes;
    VideoPlayerController? previewController;
    Uint8List? generatedThumbnail;
    bool isGeneratingThumbnail = false;
    bool isPreviewLoading = false;

    // Helper to generate thumbnail
    Future<void> updateThumbnail(String path, Function setState) async {
      if (kIsWeb) return; // Not supported on web
      setState(() {
        isGeneratingThumbnail = true;
      });
      try {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          quality: 50,
        );
        setState(() {
          generatedThumbnail = uint8list;
          isGeneratingThumbnail = false;
        });
      } catch (e) {
        developer.log('Error generating thumbnail: $e');
        setState(() {
          isGeneratingThumbnail = false;
        });
      }
    }

    // Helper to initialize preview
    Future<void> updatePreview(
      String path,
      bool isUrl,
      Function setState,
    ) async {
      if (previewController != null) {
        await previewController!.dispose();
      }

      setState(() {
        isPreviewLoading = true;
      });

      try {
        if (isUrl || kIsWeb) {
          previewController = VideoPlayerController.networkUrl(Uri.parse(path));
        } else {
          previewController = VideoPlayerController.file(File(path));
        }

        await previewController!.initialize();
        setState(() {
          isPreviewLoading = false;
        });
      } catch (e) {
        developer.log('Error initializing preview: $e');
        setState(() {
          isPreviewLoading = false;
          previewController = null;
        });
      }
    }

    // Helper to capture frame
    Future<void> captureFrame(Function setState) async {
      if (previewController == null || !previewController!.value.isInitialized)
        return;

      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اقتطاع الصور غير مدعوم على المتصفح حالياً'),
          ),
        );
        return;
      }

      setState(() {
        isGeneratingThumbnail = true;
      });

      try {
        final position = previewController!.value.position;
        // Use either the URL or the local file path
        final path = urlController.text.isNotEmpty
            ? urlController.text
            : selectedFilePath;

        if (path == null) return;

        final uint8list = await VideoThumbnail.thumbnailData(
          video: path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          quality: 70,
          timeMs: position.inMilliseconds,
        );

        setState(() {
          generatedThumbnail = uint8list;
          isGeneratingThumbnail = false;
        });
      } catch (e) {
        developer.log('Error capturing frame: $e');
        setState(() {
          isGeneratingThumbnail = false;
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('إضافة فيديو جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'مصدر الفيديو',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط فيديو (YouTube أو مباشر)',
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) async {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          selectedFilePath = null;
                          selectedFileBytes = null;
                        });
                        // Basic URL validation
                        if (value.startsWith('http')) {
                          // For direct URLs, we can try preview and thumbnail
                          // For YouTube, we just show indicator
                          if (!value.contains('youtube') &&
                              !value.contains('youtu.be')) {
                            updatePreview(value, true, setState);
                            updateThumbnail(value, setState);
                          } else {
                            setState(() {
                              previewController = null;
                              generatedThumbnail = null;
                            });
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('أو'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.video,
                        withData: true,
                      );
                      if (result != null) {
                        final file = result.files.single;
                        setState(() {
                          selectedFileBytes = file.bytes;
                          selectedFilePath = file.path;
                          if (selectedFilePath == null &&
                              file.name.isNotEmpty) {
                            selectedFilePath = file.name;
                          }
                          urlController.clear();
                        });

                        if (file.path != null) {
                          updatePreview(file.path!, false, setState);
                          updateThumbnail(file.path!, setState);
                        } else if (kIsWeb && file.bytes != null) {
                          // Note: Previewing local bytes on web usually requires a blob URL
                          // We might add support for that if needed, for now we provide feedback
                        }
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('رفع ملف من الجهاز'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'المعاينة والصورة المصغرة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Video Preview Area
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: isPreviewLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (previewController != null &&
                              previewController!.value.isInitialized)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: previewController!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(previewController!),
                                  IconButton(
                                    icon: Icon(
                                      previewController!.value.isPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      size: 50,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        previewController!.value.isPlaying
                                            ? previewController!.pause()
                                            : previewController!.play();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'لا توجد معاينة متاحة\n(روابط يوتيوب لا تدعم المعاينة هنا)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (previewController != null &&
                      previewController!.value.isInitialized &&
                      !kIsWeb)
                    TextButton.icon(
                      onPressed: () => captureFrame(setState),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('استخدام هذا الإطار كصورة مصغرة'),
                    ),
                  const SizedBox(height: 16),

                  // Thumbnail Selection Area
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                          image: generatedThumbnail != null
                              ? DecorationImage(
                                  image: MemoryImage(generatedThumbnail!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: isGeneratingThumbnail
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : generatedThumbnail == null
                            ? const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الصورة المصغرة',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.image,
                                      withData: true,
                                    );
                                if (result != null) {
                                  setState(() {
                                    generatedThumbnail =
                                        result.files.single.bytes;
                                  });
                                }
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text(
                                'تغيير الصورة',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (kIsWeb)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'على المتصفح، يفضل اختيار صورة مصغرة يدوياً لضمان ظهورها.',
                        style: TextStyle(fontSize: 10, color: Colors.orange),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  previewController?.dispose();
                  Navigator.pop(context);
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: (isPreviewLoading || isGeneratingThumbnail)
                    ? null
                    : () async {
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('العنوان مطلوب')),
                          );
                          return;
                        }

                        final provider = Provider.of<VirtuesProvider>(
                          context,
                          listen: false,
                        );
                        try {
                          String? imageBinaryBase64;
                          if (generatedThumbnail != null) {
                            imageBinaryBase64 = Virtue.encodeImageToBase64(
                              generatedThumbnail!,
                            );
                          }

                          await provider.addVirtue(
                            Virtue(
                              type: VirtueType.video,
                              title: titleController.text,
                              description: descController.text,
                              url: urlController.text.trim().isEmpty
                                  ? null
                                  : urlController.text.trim(),
                              filePath: selectedFilePath,
                              imageBinary: imageBinaryBase64,
                            ),
                            fileBytes: selectedFileBytes,
                          );

                          if (context.mounted) {
                            previewController?.dispose();
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                          }
                        }
                      },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );
  }

  // **الدالة المفقودة (التي تسببت في الخطأ)**
  void _showEditVideoDialog(Virtue virtue) {
    final titleController = TextEditingController(text: virtue.title);
    final descController = TextEditingController(text: virtue.description);
    final urlController = TextEditingController(text: virtue.url ?? '');
    String? selectedFilePath;
    Uint8List? selectedFileBytes;
    VideoPlayerController? previewController;
    Uint8List? generatedThumbnail;
    bool isGeneratingThumbnail = false;
    bool isPreviewLoading = false;

    if (virtue.imageBinary != null) {
      generatedThumbnail = Virtue.decodeImageFromBase64(virtue.imageBinary!);
    }

    // Helpers
    Future<void> updateThumbnail(String path, Function setState) async {
      if (kIsWeb) return;
      setState(() => isGeneratingThumbnail = true);
      try {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          quality: 50,
        );
        setState(() {
          generatedThumbnail = uint8list;
          isGeneratingThumbnail = false;
        });
      } catch (e) {
        developer.log('Error generating thumbnail: $e');
        setState(() => isGeneratingThumbnail = false);
      }
    }

    Future<void> updatePreview(
      String path,
      bool isUrl,
      Function setState,
    ) async {
      if (previewController != null) await previewController!.dispose();
      setState(() => isPreviewLoading = true);
      try {
        if (isUrl || kIsWeb) {
          previewController = VideoPlayerController.networkUrl(Uri.parse(path));
        } else {
          previewController = VideoPlayerController.file(File(path));
        }
        await previewController!.initialize();
        setState(() => isPreviewLoading = false);
      } catch (e) {
        developer.log('Error initializing preview: $e');
        setState(() {
          isPreviewLoading = false;
          previewController = null;
        });
      }
    }

    // Helper to capture frame
    Future<void> captureFrame(Function setState) async {
      if (previewController == null || !previewController!.value.isInitialized)
        return;

      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اقتطاع الصور غير مدعوم على المتصفح حالياً'),
          ),
        );
        return;
      }

      setState(() {
        isGeneratingThumbnail = true;
      });

      try {
        final position = previewController!.value.position;
        final path = urlController.text.isNotEmpty
            ? urlController.text
            : selectedFilePath;

        if (path == null) return;

        final uint8list = await VideoThumbnail.thumbnailData(
          video: path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          quality: 70,
          timeMs: position.inMilliseconds,
        );

        setState(() {
          generatedThumbnail = uint8list;
          isGeneratingThumbnail = false;
        });
      } catch (e) {
        developer.log('Error capturing frame: $e');
        setState(() {
          isGeneratingThumbnail = false;
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('تعديل الفيديو'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط فيديو (URL)',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.startsWith('http')) {
                        if (!value.contains('youtube') &&
                            !value.contains('youtu.be')) {
                          updatePreview(value, true, setState);
                          updateThumbnail(value, setState);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('أو استبدل الملف:'),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.video,
                        withData: true,
                      );
                      if (result != null) {
                        final file = result.files.single;
                        setState(() {
                          selectedFileBytes = file.bytes;
                          selectedFilePath = file.path;
                          urlController.clear();
                        });
                        if (file.path != null) {
                          updatePreview(file.path!, false, setState);
                          updateThumbnail(file.path!, setState);
                        }
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('رفع ملف جديد'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'المعايـنة والصورة المصغرة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isPreviewLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (previewController != null &&
                              previewController!.value.isInitialized)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: previewController!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(previewController!),
                                  IconButton(
                                    icon: Icon(
                                      previewController!.value.isPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      size: 40,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () => setState(
                                      () => previewController!.value.isPlaying
                                          ? previewController!.pause()
                                          : previewController!.play(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'لا توجد معاينة',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (previewController != null &&
                      previewController!.value.isInitialized &&
                      !kIsWeb)
                    TextButton.icon(
                      onPressed: () => captureFrame(setState),
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text(
                        'استخدام هذا الإطار كصورة مصغرة',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                          image: generatedThumbnail != null
                              ? DecorationImage(
                                  image: MemoryImage(generatedThumbnail!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: isGeneratingThumbnail
                            ? const Center(
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            withData: true,
                          );
                          if (result != null)
                            setState(
                              () => generatedThumbnail =
                                  result.files.single.bytes,
                            );
                        },
                        child: const Text(
                          'تغيير الصورة',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  if (kIsWeb)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'على المتصفح، يفضل اختيار صورة مصغرة يدوياً لضمان ظهورها.',
                        style: TextStyle(fontSize: 10, color: Colors.orange),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  previewController?.dispose();
                  Navigator.pop(context);
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: (isPreviewLoading || isGeneratingThumbnail)
                    ? null
                    : () async {
                        if (titleController.text.isEmpty) return;
                        final provider = Provider.of<VirtuesProvider>(
                          context,
                          listen: false,
                        );
                        String? imageBinaryBase64 = virtue.imageBinary;
                        if (generatedThumbnail != null)
                          imageBinaryBase64 = Virtue.encodeImageToBase64(
                            generatedThumbnail!,
                          );
                        await provider.updateVirtue(
                          virtue.copyWith(
                            title: titleController.text,
                            description: descController.text,
                            url: urlController.text.trim().isEmpty
                                ? null
                                : urlController.text.trim(),
                            filePath: selectedFilePath ?? virtue.filePath,
                            imageBinary: imageBinaryBase64,
                            category: virtue.category,
                            text: virtue.text,
                          ),
                          fileBytes: selectedFileBytes,
                        );
                        if (context.mounted) {
                          previewController?.dispose();
                          Navigator.pop(context);
                        }
                      },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }
}
