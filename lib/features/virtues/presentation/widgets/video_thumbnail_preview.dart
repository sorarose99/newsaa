import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:alslat_aalnabi/features/virtues/data/models/virtue_model.dart';

class VideoThumbnailPreview extends StatefulWidget {
  final Virtue video;
  const VideoThumbnailPreview({super.key, required this.video});

  @override
  State<VideoThumbnailPreview> createState() => _VideoThumbnailPreviewState();
}

class _VideoThumbnailPreviewState extends State<VideoThumbnailPreview> {
  Uint8List? _thumbnailData;
  File? _thumbnailFile;
  String? _youtubeThumbnailUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumbnailPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.video.url != oldWidget.video.url ||
        widget.video.filePath != oldWidget.video.filePath) {
      _generateThumbnail();
    }
  }

  String? _extractYouTubeVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      } else if (uri.host.contains('youtu.be')) {
        return uri.path.replaceFirst('/', '');
      }
    } catch (_) {}
    return null;
  }

  Future<void> _generateThumbnail() async {
    if (!mounted) return;

    developer.log('--- Generating Thumbnail ---');
    developer.log('ID: ${widget.video.id}');
    developer.log('URL: ${widget.video.url}');
    developer.log('FilePath: ${widget.video.filePath}');

    setState(() {
      _isLoading = true;
      _thumbnailData = null;
      _thumbnailFile = null;
      _youtubeThumbnailUrl = null;
      _error = null;
    });

    try {
      // 0. Check for imageBinary first (manual selection/capture)
      if (widget.video.imageBinary != null &&
          widget.video.imageBinary!.isNotEmpty) {
        developer.log('Found manual thumbnail (imageBinary)');
        final data = Virtue.decodeImageFromBase64(widget.video.imageBinary!);
        if (mounted) {
          setState(() {
            _thumbnailData = data;
            _isLoading = false;
          });
        }
        return;
      }

      // YouTube works on web
      if (widget.video.url != null && widget.video.url!.isNotEmpty) {
        final youtubeId = _extractYouTubeVideoId(widget.video.url!);
        if (youtubeId != null) {
          developer.log('Detected YouTube ID: $youtubeId');
          if (mounted) {
            setState(() {
              _youtubeThumbnailUrl =
                  'https://img.youtube.com/vi/$youtubeId/0.jpg';
              _isLoading = false;
            });
          }
          return;
        }
      }

      // Local and network file thumbnails are NOT supported on web via this package
      if (kIsWeb) {
        developer.log(
          'Thumbnail generation via plugin is not supported on Web',
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // 1. Try local file path first
      if (widget.video.filePath != null && widget.video.filePath!.isNotEmpty) {
        final file = File(widget.video.filePath!);
        if (await file.exists()) {
          developer.log('Found local file: ${widget.video.filePath}');
          final data = await VideoThumbnail.thumbnailData(
            video: widget.video.filePath!,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 250,
            quality: 75,
          );
          if (mounted) {
            setState(() {
              _thumbnailData = data;
              _isLoading = false;
            });
          }
          return;
        } else {
          developer.log('Local file NOT found: ${widget.video.filePath}');
        }
      }

      // 2. Try network URL
      if (widget.video.url != null && widget.video.url!.isNotEmpty) {
        final url = widget.video.url!;

        // Direct URL - using thumbnailFile for better stability on network sources
        developer.log('Fetching network thumbnail for URL: $url');
        final path = await VideoThumbnail.thumbnailFile(
          video: url,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 400,
          quality: 25,
        ).timeout(const Duration(seconds: 15));

        if (path != null && mounted) {
          final file = File(path);
          if (await file.exists()) {
            developer.log('Thumbnail file generated at: $path');
            setState(() {
              _thumbnailFile = file;
              _isLoading = false;
            });
            return;
          }
        } else {
          developer.log(
            'Failed to generate thumbnail file (path is null or timed out)',
          );
        }
      } else {
        developer.log(
          'No valid URL or filePath found for thumbnail generation',
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error generating thumbnail for ${widget.video.url}: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget backgroundContent;

    if (_isLoading) {
      backgroundContent = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    } else if (_youtubeThumbnailUrl != null) {
      backgroundContent = Image.network(
        _youtubeThumbnailUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40, color: Colors.white),
      );
    } else if (_thumbnailData != null) {
      backgroundContent = Image.memory(
        _thumbnailData!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40, color: Colors.white),
      );
    } else if (_thumbnailFile != null) {
      backgroundContent = Image.file(
        _thumbnailFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40, color: Colors.white),
      );
    } else {
      backgroundContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _error != null ? Icons.error_outline : Icons.videocam,
              size: 40,
              color: Colors.white.withAlpha(180),
            ),
            if (_error != null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'خطأ في التحميل',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    final hasImage =
        _thumbnailData != null ||
        _thumbnailFile != null ||
        _youtubeThumbnailUrl != null;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A574), Color(0xFF8B6F47)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: backgroundContent),
          if (!_isLoading && _error == null)
            Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasImage ? Colors.black26 : Colors.transparent,
                  shape: BoxShape.circle,
                  border: hasImage
                      ? Border.all(color: Colors.white30, width: 1)
                      : null,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 32,
                  color: hasImage ? Colors.white : Colors.white.withAlpha(200),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
