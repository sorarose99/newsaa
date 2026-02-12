import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:alslat_aalnabi/features/virtues/data/models/virtue_model.dart';
import 'package:alslat_aalnabi/features/virtues/data/services/virtues_service.dart';

class DownloadProvider extends ChangeNotifier {
  final VirtuesService _virtuesService = VirtuesService();

  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  final Map<String, String?> _downloadError = {};
  final Map<String, String?> _downloadedPaths = {};

  double getDownloadProgress(String videoId) => _downloadProgress[videoId] ?? 0.0;
  bool isDownloading(String videoId) => _isDownloading[videoId] ?? false;
  String? getDownloadError(String videoId) => _downloadError[videoId];
  String? getDownloadedPath(String videoId) => _downloadedPaths[videoId];

  bool _isYouTube(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  Future<String?> downloadVideo(Virtue video) async {
    if (video.id == null || video.url == null || video.url!.isEmpty) {
      return null;
    }

    final videoId = video.id!;
    
    try {
      _isDownloading[videoId] = true;
      _downloadError[videoId] = null;
      _downloadProgress[videoId] = 0.0;
      notifyListeners();

      String filePath;
      
      if (_isYouTube(video.url!)) {
        developer.log('Downloading YouTube video: ${video.url}');
        filePath = await _virtuesService.downloadYouTubeVideo(
          video.url!,
          videoId,
          onProgress: (progress) {
            _downloadProgress[videoId] = progress;
            notifyListeners();
          },
        );
      } else {
        developer.log('Downloading direct video: ${video.url}');
        filePath = await _virtuesService.downloadVideo(
          video.url!,
          videoId,
          onProgress: (progress) {
            _downloadProgress[videoId] = progress;
            notifyListeners();
          },
        );
      }

      _downloadedPaths[videoId] = filePath;
      _isDownloading[videoId] = false;
      _downloadError[videoId] = null;
      notifyListeners();

      return filePath;
    } catch (e) {
      _isDownloading[videoId] = false;
      _downloadError[videoId] = e.toString();
      _downloadProgress[videoId] = 0.0;
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteDownloadedVideo(Virtue video) async {
    if (video.id == null || _downloadedPaths[video.id!] == null) {
      return;
    }

    final videoId = video.id!;
    try {
      await _virtuesService.deleteDownloadedVideo(_downloadedPaths[videoId]!);
      _downloadedPaths[videoId] = null;
      _downloadProgress[videoId] = 0.0;
      notifyListeners();
    } catch (e) {
      _downloadError[videoId] = e.toString();
      notifyListeners();
    }
  }

  Future<bool> isVideoDownloaded(String? filePath) async {
    return await _virtuesService.checkVideoExists(filePath);
  }
}
