import 'package:flutter/material.dart';
import 'package:alslat_aalnabi/features/admin/data/services/content_service.dart';
import 'package:alslat_aalnabi/features/admin/data/models/content_model.dart';

class InfoProvider extends ChangeNotifier {
  final ContentService _contentService = ContentService();

  List<PrayerFormula> _prayerFormulas = [];
  List<EvidenceItem> _evidence = [];
  List<HadithItem> _hadith = [];

  bool _isLoading = false;
  String _errorMessage = '';

  List<PrayerFormula> get prayerFormulas => _prayerFormulas;
  List<EvidenceItem> get evidence => _evidence;
  List<HadithItem> get hadith => _hadith;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadContent() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _contentService.getPrayerFormulas(),
        _contentService.getEvidence(),
        _contentService.getHadith(),
      ]);

      _prayerFormulas = results[0] as List<PrayerFormula>;
      _evidence = results[1] as List<EvidenceItem>;
      _hadith = results[2] as List<HadithItem>;
    } catch (e) {
      _errorMessage = 'خطأ في تحميل المحتوى: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
