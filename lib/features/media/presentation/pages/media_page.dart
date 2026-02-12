import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appName),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.images, icon: const Icon(Icons.image)),
            Tab(
              text: localizations.videos,
              icon: const Icon(Icons.video_library),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImagesTab(localizations),
          _buildVideosTab(localizations),
        ],
      ),
    );
  }

  Widget _buildImagesTab(AppLocalizations localizations) {
    final images = [
      {
        'title': 'آيات الصلاة على النبي',
        'desc': 'آيات قرآنية عن الصلاة على النبي',
      },
      {'title': 'فضائل الصلاة', 'desc': 'فوائد وثمرات الصلاة على النبي'},
      {'title': 'أذكار الصباح', 'desc': 'الصلاة على النبي في أذكار الصباح'},
      {'title': 'أذكار المساء', 'desc': 'الصلاة على النبي في أذكار المساء'},
      {'title': 'يوم الجمعة', 'desc': 'فضل الإكثار من الصلاة يوم الجمعة'},
    ];

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showImageDialog(images[index], localizations),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF00695C),
                          const Color(0xFF4CAF50),
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
                        images[index]['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        images[index]['desc']!,
                        style: const TextStyle(
                          fontSize: 11,
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
          ),
        );
      },
    );
  }

  Widget _buildVideosTab(AppLocalizations localizations) {
    final videos = [
      {'title': 'فضل الصلاة على النبي', 'duration': '5:30', 'views': '1.2M'},
      {
        'title': 'كيفية الصلاة الإبراهيمية',
        'duration': '3:15',
        'views': '850K',
      },
      {
        'title': 'الصلاة على النبي في القرآن',
        'duration': '8:45',
        'views': '2.1M',
      },
      {
        'title': 'أحاديث عن الصلاة على النبي',
        'duration': '10:20',
        'views': '1.5M',
      },
      {'title': 'ثمرات الصلاة على النبي', 'duration': '6:55', 'views': '980K'},
    ];

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showVideoDialog(videos[index], localizations),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00695C), Color(0xFF4CAF50)],
                      ),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          videos[index]['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              videos[index]['duration']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.visibility,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              videos[index]['views']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageDialog(
    Map<String, String> image,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(image['title']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00695C), Color(0xFF4CAF50)],
                ),
              ),
              child: const Icon(Icons.image, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              image['desc']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'قريباً: سيتم إضافة محتوى حقيقي',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Future.microtask(() {
                if (mounted) {
                  _showShareOptions(_MediaKind.image, image, localizations);
                }
              });
            },
            child: Text(localizations.share),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog(
    Map<String, String> video,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(video['title']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00695C), Color(0xFF4CAF50)],
                ),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text(video['duration']!),
                const SizedBox(width: 16),
                const Icon(Icons.visibility, size: 16),
                const SizedBox(width: 4),
                Text(video['views']!),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'قريباً: سيتم إضافة مشغل فيديو حقيقي',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Future.microtask(() {
                if (mounted) {
                  _showShareOptions(_MediaKind.video, video, localizations);
                }
              });
            },
            child: Text(localizations.share),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  Future<void> _showShareOptions(
    _MediaKind kind,
    Map<String, String> data,
    AppLocalizations localizations,
  ) async {
    if (!mounted) {
      return;
    }
    final shareText = _composeShareText(kind, data, localizations);
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.shareVia,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _buildShareButton(
                      icon: Icons.chat,
                      color: const Color(0xFF25D366),
                      label: localizations.shareWhatsapp,
                      onTap: () async {
                        await _shareContent(
                          shareText,
                          localizations.shareWhatsapp,
                          sheetContext,
                        );
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      label: localizations.shareFacebook,
                      onTap: () async {
                        await _shareContent(
                          shareText,
                          localizations.shareFacebook,
                          sheetContext,
                        );
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.camera_alt,
                      color: const Color(0xFFE4405F),
                      label: localizations.shareInstagram,
                      onTap: () async {
                        await _shareContent(
                          shareText,
                          localizations.shareInstagram,
                          sheetContext,
                        );
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.alternate_email,
                      color: const Color(0xFF1DA1F2),
                      label: localizations.shareTwitter,
                      onTap: () async {
                        await _shareContent(
                          shareText,
                          localizations.shareTwitter,
                          sheetContext,
                        );
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.send,
                      color: const Color(0xFF0084FF),
                      label: localizations.shareMessenger,
                      onTap: () async {
                        await _shareContent(
                          shareText,
                          localizations.shareMessenger,
                          sheetContext,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required Color color,
    required String label,
    required Future<void> Function() onTap,
  }) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              await onTap();
            },
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _shareContent(
    String text,
    String subject,
    BuildContext sheetContext,
  ) async {
    Navigator.of(sheetContext).pop();
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      ),
    );
  }

  String _composeShareText(
    _MediaKind kind,
    Map<String, String> data,
    AppLocalizations localizations,
  ) {
    final buffer = StringBuffer(data['title'] ?? localizations.appName);
    if (kind == _MediaKind.image) {
      final description = data['desc'];
      if (description != null && description.isNotEmpty) {
        buffer.write('\n$description');
      }
    } else {
      final duration = data['duration'];
      final views = data['views'];
      if (duration != null && duration.isNotEmpty) {
        buffer.write('\n${localizations.videos}: $duration');
      }
      if (views != null && views.isNotEmpty) {
        buffer.write('\n${localizations.total}: $views');
      }
    }
    buffer.write('\n${localizations.appName}');
    return buffer.toString();
  }
}

enum _MediaKind { image, video }
