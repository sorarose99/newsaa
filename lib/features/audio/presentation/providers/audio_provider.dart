import 'package:flutter/material.dart';
import 'package:alslat_aalnabi/features/admin/data/services/content_service.dart';
import 'package:alslat_aalnabi/features/admin/data/models/content_model.dart';

class AudioProvider extends ChangeNotifier {
  final ContentService _contentService = ContentService();

  List<SoundItem> _sounds = [];
  List<MediaItem> _media = [];

  bool _isLoading = false;
  String _errorMessage = '';

  List<SoundItem> get sounds => _sounds;
  List<MediaItem> get media => _media;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadSounds() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _contentService.getSounds(),
        _contentService.getMedia(),
      ]);

      _sounds = results[0] as List<SoundItem>;
      _media = results[1] as List<MediaItem>;
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الأصوات: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
