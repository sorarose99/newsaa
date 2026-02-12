import 'package:flutter/material.dart';
import 'package:alslat_aalnabi/features/admin/data/services/admin_auth_service.dart';
import 'package:alslat_aalnabi/features/admin/data/services/content_service.dart';
import 'package:alslat_aalnabi/features/admin/data/models/content_model.dart';
import 'package:alslat_aalnabi/core/services/admin_session_manager.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';

class AdminProvider extends ChangeNotifier {
  final AdminAuthService _authService = AdminAuthService();
  final ContentService _contentService = ContentService();
  final AdminSessionManager _sessionManager = AdminSessionManager();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _errorMessage = '';

  List<PrayerFormula> _prayerFormulas = [];
  List<EvidenceItem> _evidence = [];
  List<HadithItem> _hadith = [];
  List<MediaItem> _media = [];
  List<SoundItem> _sounds = [];
  List<PrayerFormulaSound> _prayerFormulaSounds = [];

  Map<String, dynamic> _statistics = {};

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<PrayerFormula> get prayerFormulas => _prayerFormulas;
  List<EvidenceItem> get evidence => _evidence;
  List<HadithItem> get hadith => _hadith;
  List<MediaItem> get media => _media;
  List<SoundItem> get sounds => _sounds;
  List<PrayerFormulaSound> get prayerFormulaSounds => _prayerFormulaSounds;
  Map<String, dynamic> get statistics => _statistics;

  AdminProvider() {
    _isLoggedIn = false;
    _errorMessage = '';

    // Listen to session expiry
    _sessionManager.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    if (_sessionManager.isExpired && _isLoggedIn) {
      // Auto-logout on session expiry
      logout();
    }
  }

  AdminSessionManager get sessionManager => _sessionManager;

  Future<void> checkAdminStatus() async {
    final loggedIn = await _authService.isAdminLoggedIn();
    _isLoggedIn = loggedIn;
  }

  Future<bool> loginAdmin(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final success = await _authService.loginAdmin(username, password);
    _isLoggedIn = success;
    if (!success) {
      _errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة';
    } else {
      // Start session on successful login
      _sessionManager.startSession();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _sessionManager.endSession();
    _isLoggedIn = false;
    _prayerFormulas = [];
    _evidence = [];
    _hadith = [];
    _media = [];
    _sounds = [];
    _prayerFormulaSounds = [];
    _statistics = {};
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
    _sessionManager.dispose();
    super.dispose();
  }

  Future<void> loadPrayerFormulas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _prayerFormulas = await _contentService.getPrayerFormulas();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل صيغ الصلاة: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPrayerFormula(PrayerFormula formula) async {
    try {
      await _contentService.addPrayerFormula(formula);
      _prayerFormulas.add(formula);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة صيغة الصلاة: $e';
      notifyListeners();
    }
  }

  Future<void> updatePrayerFormula(PrayerFormula formula) async {
    try {
      await _contentService.updatePrayerFormula(formula);
      final index = _prayerFormulas.indexWhere((f) => f.id == formula.id);
      if (index != -1) {
        _prayerFormulas[index] = formula;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث صيغة الصلاة: $e';
      notifyListeners();
    }
  }

  Future<void> deletePrayerFormula(String id) async {
    try {
      await _contentService.deletePrayerFormula(id);
      _prayerFormulas.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في حذف صيغة الصلاة: $e';
      notifyListeners();
    }
  }

  Future<void> loadEvidence() async {
    _isLoading = true;
    notifyListeners();
    try {
      _evidence = await _contentService.getEvidence();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الأدلة: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvidence(EvidenceItem evidence) async {
    try {
      await _contentService.addEvidence(evidence);
      _evidence.add(evidence);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة الدليل: $e';
      notifyListeners();
    }
  }

  Future<void> updateEvidence(EvidenceItem evidence) async {
    try {
      await _contentService.updateEvidence(evidence);
      final index = _evidence.indexWhere((e) => e.id == evidence.id);
      if (index != -1) {
        _evidence[index] = evidence;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الدليل: $e';
      notifyListeners();
    }
  }

  Future<void> deleteEvidence(String id) async {
    try {
      await _contentService.deleteEvidence(id);
      _evidence.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في حذف الدليل: $e';
      notifyListeners();
    }
  }

  Future<void> loadHadith() async {
    _isLoading = true;
    notifyListeners();
    try {
      _hadith = await _contentService.getHadith();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الأحاديث: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHadith(HadithItem hadith) async {
    try {
      await _contentService.addHadith(hadith);
      _hadith.add(hadith);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة الحديث: $e';
      notifyListeners();
    }
  }

  Future<void> updateHadith(HadithItem hadith) async {
    try {
      await _contentService.updateHadith(hadith);
      final index = _hadith.indexWhere((h) => h.id == hadith.id);
      if (index != -1) {
        _hadith[index] = hadith;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الحديث: $e';
      notifyListeners();
    }
  }

  Future<void> deleteHadith(String id) async {
    try {
      await _contentService.deleteHadith(id);
      _hadith.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في حذف الحديث: $e';
      notifyListeners();
    }
  }

  Future<void> loadMedia() async {
    _isLoading = true;
    notifyListeners();
    try {
      _media = await _contentService.getMedia();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الوسائط: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMedia(MediaItem media) async {
    try {
      await _contentService.addMedia(media);
      _media.add(media);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة الوسيط: $e';
      notifyListeners();
    }
  }

  Future<void> updateMedia(MediaItem media) async {
    try {
      await _contentService.updateMedia(media);
      final index = _media.indexWhere((m) => m.id == media.id);
      if (index != -1) {
        _media[index] = media;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الوسيط: $e';
      notifyListeners();
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _contentService.deleteMedia(id);
      _media.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في حذف الوسيط: $e';
      notifyListeners();
    }
  }

  Future<void> loadSounds() async {
    _isLoading = true;
    notifyListeners();
    try {
      _sounds = await _contentService.getSounds();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الأصوات: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSound(SoundItem sound) async {
    try {
      await _contentService.addSound(sound);
      _sounds.add(sound);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة الصوت: $e';
      notifyListeners();
    }
  }

  Future<void> updateSound(SoundItem sound) async {
    try {
      await _contentService.updateSound(sound);
      final index = _sounds.indexWhere((s) => s.id == sound.id);
      if (index != -1) {
        _sounds[index] = sound;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الصوت: $e';
      notifyListeners();
    }
  }

  Future<void> deleteSound(String id) async {
    try {
      await _contentService.deleteSound(id);
      _sounds.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في حذف الصوت: $e';
      notifyListeners();
    }
  }

  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();
    try {
      _statistics = await _contentService.getStatistics();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الإحصائيات: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPrayerFormulaSounds() async {
    _isLoading = true;
    notifyListeners();
    try {
      _prayerFormulaSounds = await _contentService.getPrayerFormulaSounds();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل صيغ الصلاة الصوتية: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPrayerFormulaSound(PrayerFormulaSound sound) async {
    _errorMessage = '';
    notifyListeners();
    try {
      await _contentService.addPrayerFormulaSound(sound);
      await loadPrayerFormulaSounds();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة صيغة الصلاة الصوتية: $e';
      notifyListeners();
    }
  }

  Future<void> updatePrayerFormulaSound(PrayerFormulaSound sound) async {
    _errorMessage = '';
    notifyListeners();
    try {
      await _contentService.updatePrayerFormulaSound(sound);
      await loadPrayerFormulaSounds();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث صيغة الصلاة الصوتية: $e';
      notifyListeners();
    }
  }

  Future<void> deletePrayerFormulaSound(String id) async {
    _errorMessage = '';
    notifyListeners();
    try {
      if (id.isEmpty) {
        _errorMessage = 'معرف الصوت فارغ';
        notifyListeners();
        return;
      }

      await _contentService.deletePrayerFormulaSound(id);
      await Future.delayed(const Duration(seconds: 1));
      await loadPrayerFormulaSounds();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'خطأ في حذف صيغة الصلاة الصوتية: $e';
    }
    notifyListeners();
  }

  Future<void> addPrayerFormulaSoundWithFile(
    File audioFile,
    PrayerFormulaSound sound,
  ) async {
    _errorMessage = '';
    notifyListeners();
    try {
      developer.log('Uploading audio file to Supabase Storage...');
      final audioUrl = await _contentService.uploadAudioToStorage(
        audioFile,
        sound.title,
      );

      final soundWithUrl = sound.copyWith(
        id: sound.id ?? const Uuid().v4(),
        url: audioUrl,
        // We can keep soundBinary as null to avoid storing large data in DB
      );

      await _contentService.addPrayerFormulaSound(soundWithUrl);
      await Future.delayed(const Duration(seconds: 1));
      await loadPrayerFormulaSounds();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة الصوت: $e';
      notifyListeners();
    }
  }

  Future<void> updatePrayerFormulaSoundWithFile(
    File? audioFile,
    PrayerFormulaSound sound,
  ) async {
    _errorMessage = '';
    notifyListeners();
    try {
      PrayerFormulaSound soundToUpdate = sound;

      if (audioFile != null) {
        developer.log('Uploading new audio file to Supabase Storage...');
        final audioUrl = await _contentService.uploadAudioToStorage(
          audioFile,
          sound.title,
        );
        soundToUpdate = sound.copyWith(url: audioUrl);
      }

      await _contentService.updatePrayerFormulaSound(soundToUpdate);
      await loadPrayerFormulaSounds();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الصوت: $e';
      notifyListeners();
    }
  }

  Future<void> addPrayerFormulaSoundWithBytes(
    Uint8List audioBytes,
    PrayerFormulaSound sound,
  ) async {
    _errorMessage = '';
    notifyListeners();
    try {
      developer.log('Uploading audio bytes to Supabase Storage...');
      final audioUrl = await _contentService.uploadAudioBytesToStorage(
        audioBytes,
        sound.title,
      );

      final soundWithUrl = sound.copyWith(
        id: sound.id ?? const Uuid().v4(),
        url: audioUrl,
      );

      await _contentService.addPrayerFormulaSound(soundWithUrl);
      await Future.delayed(const Duration(seconds: 1));
      await loadPrayerFormulaSounds();
    } catch (e) {
      _errorMessage = 'خطأ في إضافة الصوت: $e';
      notifyListeners();
    }
  }

  Future<void> updatePrayerFormulaSoundWithBytes(
    Uint8List? audioBytes,
    PrayerFormulaSound sound,
  ) async {
    _errorMessage = '';
    notifyListeners();
    try {
      PrayerFormulaSound soundToUpdate = sound;

      if (audioBytes != null) {
        developer.log('Uploading new audio bytes to Supabase Storage...');
        final audioUrl = await _contentService.uploadAudioBytesToStorage(
          audioBytes,
          sound.title,
        );
        soundToUpdate = sound.copyWith(url: audioUrl);
      }

      await _contentService.updatePrayerFormulaSound(soundToUpdate);
      await loadPrayerFormulaSounds();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الصوت: $e';
      notifyListeners();
    }
  }
}
