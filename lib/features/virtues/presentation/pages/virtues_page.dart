import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:alslat_aalnabi/core/localization/app_localizations.dart';
import 'package:alslat_aalnabi/features/virtues/data/models/virtue_model.dart';
import 'package:alslat_aalnabi/features/virtues/presentation/providers/virtues_provider.dart';
import 'package:alslat_aalnabi/features/virtues/presentation/providers/download_provider.dart';
import 'package:alslat_aalnabi/features/virtues/presentation/widgets/video_thumbnail_preview.dart';

class VirtuesPage extends StatefulWidget {
  const VirtuesPage({super.key});

  @override
  State<VirtuesPage> createState() => _VirtuesPageState();
}

class _VirtuesPageState extends State<VirtuesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text(localizations.virtues),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onPrimary.withValues(alpha: 0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: localizations.virtueInfo, icon: const Icon(Icons.info)),
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
          _buildVirtueInfoTab(localizations),
          _buildImagesTabWithShare(localizations),
          _buildVideosTabWithShare(localizations),
        ],
      ),
    );
  }

  Widget _buildImagesTabWithShare(AppLocalizations localizations) {
    return Consumer<VirtuesProvider>(
      builder: (context, virtuesProvider, _) {
        final images = virtuesProvider.virtues
            .where((v) => v.type == VirtueType.image)
            .toList();

        if (images.isEmpty) {
          return const Center(child: Text('لا توجد صور'));
        }

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
            final image = images[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () => _showImageDialog(image, localizations),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildImagePreview(image)),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                image.title ?? 'صورة',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                image.description ?? '',
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImagePreview(Virtue image) {
    if (image.url != null && image.url!.isNotEmpty) {
      return Image.network(
        image.url!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorPlaceholder();
        },
      );
    } else if (image.filePath != null && image.filePath!.isNotEmpty) {
      return Image.file(
        File(image.filePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorPlaceholder();
        },
      );
    } else if (image.imageBinary != null && image.imageBinary!.isNotEmpty) {
      return Image.memory(
        Virtue.decodeImageFromBase64(image.imageBinary!),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorPlaceholder();
        },
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: Icon(
        Icons.image,
        size: 60,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB71C1C), Color(0xFFF44336)],
        ),
      ),
      child: const Icon(Icons.error, size: 60, color: Colors.white),
    );
  }

  Widget _buildVideosTabWithShare(AppLocalizations localizations) {
    return Consumer<VirtuesProvider>(
      builder: (context, virtuesProvider, _) {
        final videos = virtuesProvider.virtues
            .where((v) => v.type == VirtueType.video)
            .toList();

        if (videos.isEmpty) {
          return const Center(child: Text('لا توجد فيديوهات'));
        }

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () => _showVideoDialog(video, localizations),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildVideoThumbnail(video)),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title ?? 'فيديو',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                video.description ?? '',
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVideoThumbnail(Virtue video) {
    return VideoThumbnailPreview(video: video);
  }

  void _showImageDialog(Virtue image, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(image.title ?? 'صورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageDialogPreview(image),
            const SizedBox(height: 16),
            Text(image.description ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
          ElevatedButton.icon(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: '${image.title}: ${image.description}',
                  subject: image.title,
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: Text(localizations.share),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDialogPreview(Virtue image) {
    if (image.url != null && image.url!.isNotEmpty) {
      return Image.network(
        image.url!,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageDialogErrorPlaceholder();
        },
      );
    } else if (image.filePath != null && image.filePath!.isNotEmpty) {
      return Image.file(
        File(image.filePath!),
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageDialogErrorPlaceholder();
        },
      );
    } else if (image.imageBinary != null && image.imageBinary!.isNotEmpty) {
      return Image.memory(
        Virtue.decodeImageFromBase64(image.imageBinary!),
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageDialogErrorPlaceholder();
        },
      );
    } else {
      return _buildImageDialogPlaceholder();
    }
  }

  Widget _buildImageDialogPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image,
        size: 100,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildImageDialogErrorPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB71C1C), Color(0xFFF44336)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.error, size: 100, color: Colors.white),
    );
  }

  void _showVideoDialog(Virtue video, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) {
        return _VideoDialog(video: video, localizations: localizations);
      },
    );
  }

  Widget _buildVirtueInfoTab(AppLocalizations localizations) {
    return Consumer<VirtuesProvider>(
      builder: (context, virtuesProvider, _) {
        final quranVirtues = virtuesProvider.virtues
            .where(
              (v) =>
                  v.type == VirtueType.benefit &&
                  v.category == VirtueCategory.quran,
            )
            .toList();
        final hadithVirtues = virtuesProvider.virtues
            .where(
              (v) =>
                  v.type == VirtueType.benefit &&
                  v.category == VirtueCategory.hadith,
            )
            .toList();
        final formulaVirtues = virtuesProvider.virtues
            .where(
              (v) =>
                  v.type == VirtueType.benefit &&
                  v.category == VirtueCategory.formula,
            )
            .toList();
        final customBenefits = virtuesProvider.virtues
            .where(
              (v) =>
                  v.type == VirtueType.benefit &&
                  (v.category == null || v.category == VirtueCategory.custom),
            )
            .toList();
        final times = virtuesProvider.virtues
            .where((v) => v.type == VirtueType.time)
            .toList();

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (quranVirtues.isNotEmpty)
              Column(
                children: [
                  _buildSection(
                    'الأدلة من القرآن',
                    Icons.book,
                    Theme.of(context).colorScheme.primary,
                    quranVirtues
                        .map(
                          (v) => _buildQuranVerseWithShare(
                            v.text,
                            v.description ?? '',
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (hadithVirtues.isNotEmpty)
              Column(
                children: [
                  _buildSection(
                    'الأحاديث النبوية',
                    Icons.article,
                    Theme.of(context).colorScheme.secondary,
                    hadithVirtues
                        .map(
                          (v) => _buildHadithWithShare(
                            v.text,
                            v.description ?? '',
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (customBenefits.isNotEmpty)
              Column(
                children: [
                  _buildSection(
                    'فوائد الصلاة على النبي',
                    Icons.star,
                    Theme.of(context).colorScheme.secondary,
                    customBenefits.map((v) => _buildBenefit(v.text)).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (times.isNotEmpty)
              Column(
                children: [
                  _buildSection(
                    'أوقات الإكثار من الصلاة',
                    Icons.access_time,
                    Theme.of(context).colorScheme.primary,
                    times.map((v) => _buildTime(v.text)).toList(),
                    onShareAll: () => _shareAllTimes(times),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (formulaVirtues.isNotEmpty)
              Column(
                children: [
                  _buildSection(
                    'صيغ الصلاة على النبي',
                    Icons.format_quote,
                    Theme.of(context).colorScheme.secondary,
                    formulaVirtues
                        .map((v) => _buildFormulaWithShare(v.text))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.mosque, size: 60, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              'الصلاة على النبي محمد ﷺ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'من أعظم العبادات وأجل القربات',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children, {
    VoidCallback? onShareAll,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onShareAll != null)
                  IconButton(
                    onPressed: onShareAll,
                    icon: Icon(Icons.share, color: color, size: 24),
                    tooltip: 'مشاركة الكل',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildQuranVerseWithShare(String verse, String reference) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verse,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reference,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '$verse\n$reference',
                      subject: 'Quran Verse',
                    ),
                  );
                },
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHadithWithShare(String text, String reference) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574).withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
                const SizedBox(height: 6),
                Text(
                  reference,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(text: '$text\n$reference', subject: 'Hadith'),
              );
            },
            icon: Icon(
              Icons.share,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTime(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.schedule,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaWithShare(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(text: text, subject: 'Salawat Formula'),
              );
            },
            icon: Icon(
              Icons.share,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _shareAllTimes(List<Virtue> times) {
    final allTimesText = times.map((v) => '• ${v.text}').join('\n');
    final fullText = 'أوقات الإكثار من الصلاة على النبي ﷺ:\n\n$allTimesText';
    SharePlus.instance.share(
      ShareParams(text: fullText, subject: 'أوقات الإكثار من الصلاة'),
    );
  }

  Widget _buildFooter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.secondary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'اللهم صل وسلم وبارك على سيدنا محمد وعلى آله وصحبه أجمعين',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoDialog extends StatefulWidget {
  const _VideoDialog({required this.video, required this.localizations});

  final Virtue video;
  final AppLocalizations localizations;

  @override
  State<_VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<_VideoDialog> {
  VideoPlayerController? _controller;
  WebViewController? _webViewController;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isYouTube = false;
  bool _isVideoDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkIfVideoDownloaded();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeVideoController();
      }
    });
  }

  Future<void> _checkIfVideoDownloaded() async {
    final downloadProvider = Provider.of<DownloadProvider>(
      context,
      listen: false,
    );
    final isDownloaded = await downloadProvider.isVideoDownloaded(
      widget.video.filePath,
    );
    if (mounted) {
      setState(() {
        _isVideoDownloaded = isDownloaded;
      });
    }
  }

  String? _extractYouTubeVideoId(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.host.contains('youtube.com')) {
        final videoId = uri.queryParameters['v'];
        if (videoId != null && videoId.isNotEmpty) {
          return videoId;
        }
      } else if (uri.host.contains('youtu.be')) {
        final path = uri.path.replaceFirst('/', '');
        if (path.isNotEmpty) {
          return path;
        }
      }
    } catch (e) {
      developer.log('Error extracting YouTube video ID: $e');
    }
    return null;
  }

  String _getYouTubeEmbedHtml(String videoId) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        html, body {
          width: 100%;
          height: 100%;
          background: #000;
          font-family: Arial, sans-serif;
          overflow: hidden;
        }
        .video-container {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
          background: #000;
        }
        iframe {
          width: 100%;
          height: 100%;
          border: none;
          display: block;
        }
        /* Hide all YouTube UI elements except player */
        .ytp-endscreen-container,
        .ytp-endscreen,
        .ytp-suggestions,
        .ytp-related-videos,
        .ytp-next-endscreen,
        .annotation,
        .ytp-suggested-action,
        [aria-label*="Suggested"],
        [aria-label*="suggested"],
        [aria-label*="Watch"],
        [aria-label*="Recommended"] {
          display: none !important;
          visibility: hidden !important;
        }
        /* Hide all links */
        a {
          pointer-events: none !important;
          cursor: default !important;
        }
        /* Hide info cards */
        .ytp-infomercial-bar,
        .html5-video-container + * {
          display: none !important;
        }
      </style>
    </head>
    <body>
      <div class="video-container">
        <iframe 
          width="100%" 
          height="100%" 
          src="https://www.youtube.com/embed/$videoId?controls=1&autoplay=1&rel=0&modestbranding=1&fs=1&playsinline=1" 
          frameborder="0" 
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
          allowfullscreen
          referrerpolicy="strict-origin-when-cross-origin">
        </iframe>
      </div>
      <script>
        // Block all click events on non-player elements
        document.addEventListener('click', function(e) {
          const target = e.target;
          
          // Check if click is on a link or suggested video
          if (target.tagName === 'A' || 
              target.closest('a') ||
              target.closest('[role="link"]') ||
              target.closest('.ytp-endscreen') ||
              target.closest('.ytp-suggestions')) {
            e.preventDefault();
            e.stopPropagation();
            return false;
          }
        }, true);
        
        // Disable keyboard shortcuts that might navigate
        document.addEventListener('keydown', function(e) {
          if (e.key === 'Enter' && e.target.tagName !== 'INPUT') {
            e.preventDefault();
          }
        });
      </script>
    </body>
    </html>
    ''';
  }

  Future<void> _initializeVideoController() async {
    try {
      developer.log('--- Initializing Video Dialog ---');
      developer.log('ID: ${widget.video.id}');
      developer.log('Title: ${widget.video.title}');
      developer.log('FilePath: ${widget.video.filePath}');
      developer.log('URL: ${widget.video.url}');

      // Check for valid URL first to determine if it's a YouTube video
      final hasValidUrl =
          widget.video.url != null && widget.video.url!.isNotEmpty;

      if (widget.video.filePath != null && widget.video.filePath!.isNotEmpty) {
        if (kIsWeb) {
          developer.log(
            'On Web: Using networkUrl for filePath: ${widget.video.filePath}',
          );
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.video.filePath!),
          );
        } else {
          final file = File(widget.video.filePath!);
          final exists = await file.exists();
          developer.log('Checking local file existence: $exists');

          if (!exists) {
            developer.log('Local file NOT found: ${widget.video.filePath}');
            if (!hasValidUrl) {
              throw Exception(
                'الملف المحفوظ غير متوفر: ${widget.video.filePath}',
              );
            }
            developer.log(
              'Falling back to network URL since local file is missing',
            );
          } else {
            final fileSize = await file.length();
            developer.log('Local file size: $fileSize bytes');
            if (fileSize == 0) {
              developer.log('Local file is empty');
              if (!hasValidUrl) {
                throw Exception('ملف الفيديو فارغ (بدون محتوى)');
              }
            } else {
              _controller = VideoPlayerController.file(file);
            }
          }
        }
      }

      // If controller is still null and we have a URL, try the URL
      if (_controller == null && hasValidUrl) {
        final url = widget.video.url!;
        developer.log('Attempting network initialization with URL: $url');

        final videoId = _extractYouTubeVideoId(url);
        if (videoId != null && videoId.isNotEmpty) {
          developer.log('Detected YouTube video ID: $videoId');
          _isYouTube = true;

          final htmlContent = _getYouTubeEmbedHtml(videoId);
          _webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadHtmlString(htmlContent);

          setState(() {
            _isLoading = false;
          });
          return;
        }

        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      }

      if (_controller != null) {
        developer.log('Starting VideoPlayerController initialization...');
        await _controller!.initialize().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            developer.log('Video initialization timed out (30s)');
            throw Exception('انتهت مهلة تحميل الفيديو (30 ثانية)');
          },
        );

        developer.log('VideoPlayerController initialized successfully');
        developer.log('Duration: ${_controller!.value.duration}');
        developer.log('Size: ${_controller!.value.size}');

        if (mounted) {
          await _controller!.play();
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        developer.log('Error: Both FilePath and URL are invalid or failed');
        throw Exception('لم يتم تحديد فيديو - لا توجد رابط أو ملف صالح');
      }
    } catch (e, stackTrace) {
      developer.log('Error in video dialog initialization: $e');
      developer.log('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تحميل الفيديو:\n$e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.video.title ?? 'فيديو'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB71C1C), Color(0xFFF44336)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_isLoading)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD4A574), Color(0xFF8B6F47)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'جاري تحميل الفيديو...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isYouTube && _webViewController != null)
              SizedBox(
                height: 300,
                width: 300,
                child: WebViewWidget(controller: _webViewController!),
              )
            else if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Container(
                  color: Colors.black,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD4A574), Color(0xFF8B6F47)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            Text(widget.video.description ?? '', textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        if (_controller != null && _controller!.value.isInitialized)
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                _controller!.value.isPlaying
                    ? _controller!.pause()
                    : _controller!.play();
              });
            },
          ),
        Consumer<DownloadProvider>(
          builder: (context, downloadProvider, _) {
            final isDownloading = downloadProvider.isDownloading(
              widget.video.id ?? '',
            );
            final downloadProgress = downloadProvider.getDownloadProgress(
              widget.video.id ?? '',
            );
            final hasUrl =
                widget.video.url != null && widget.video.url!.isNotEmpty;

            if (hasUrl) {
              if (isDownloading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: downloadProgress,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(downloadProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (_isVideoDownloaded) {
                return Tooltip(
                  message: 'حذف الفيديو المحفوظ',
                  child: Consumer<VirtuesProvider>(
                    builder: (context, virtuesProvider, _) {
                      return IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('حذف الفيديو'),
                              content: const Text(
                                'هل تريد حذف الفيديو المحفوظ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('إلغاء'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await downloadProvider.deleteDownloadedVideo(
                              widget.video,
                            );
                            if (mounted && widget.video.id != null) {
                              await virtuesProvider.deleteVirtueFilePath(
                                widget.video.id!,
                              );

                              setState(() {
                                _isVideoDownloaded = false;
                              });
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              } else {
                return Tooltip(
                  message: 'تحميل الفيديو',
                  child: Consumer<VirtuesProvider>(
                    builder: (context, virtuesProvider, _) {
                      return IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          final filePath = await downloadProvider.downloadVideo(
                            widget.video,
                          );
                          if (!mounted) return;
                          if (filePath != null && widget.video.id != null) {
                            setState(() {
                              _isVideoDownloaded = true;
                            });

                            await virtuesProvider.updateVirtueFilePath(
                              widget.video.id!,
                              filePath,
                            );

                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تحميل الفيديو بنجاح'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.localizations.close),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            try {
              final title = widget.video.title ?? 'فيديو';
              final description = widget.video.description ?? '';
              final url = widget.video.url;

              String shareText = '$title\n$description';
              if (url != null && url.isNotEmpty) {
                shareText += '\n\n$url';
              }

              await SharePlus.instance.share(
                ShareParams(text: shareText, subject: title),
              );
            } catch (e) {
              developer.log('Error sharing video: $e');
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('خطأ في المشاركة: $e')));
            }
          },
          icon: const Icon(Icons.share),
          label: Text(widget.localizations.share),
        ),
      ],
    );
  }
}
