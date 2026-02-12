import 'dart:developer' as developer;
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:alslat_aalnabi/core/services/offline_database_service.dart';
import 'package:alslat_aalnabi/core/services/sync_manager_service.dart';
import 'package:alslat_aalnabi/features/admin/data/models/content_model.dart';

class ContentService {
  static final ContentService _instance = ContentService._internal();
  final _supabase = Supabase.instance.client;
  late final _offlineDb = OfflineDatabaseService();
  late final _syncManager = SyncManagerService();

  factory ContentService() {
    return _instance;
  }

  ContentService._internal();

  Future<void> addPrayerFormula(PrayerFormula formula) async {
    try {
      await _offlineDb.insertPrayerFormula(formula.toJson());
      if (_syncManager.isOnline) {
        await _supabase.from('prayer_formulas').insert(formula.toJson());
        await _offlineDb.markTableAsSynced('prayer_formulas');
      }
    } catch (e) {
      developer.log('Error adding prayer formula: $e', error: e);
    }
  }

  Future<void> updatePrayerFormula(PrayerFormula formula) async {
    try {
      await _offlineDb.updatePrayerFormula(formula.id, formula.toJson());
      if (_syncManager.isOnline) {
        await _supabase
            .from('prayer_formulas')
            .update(formula.toJson())
            .eq('id', formula.id);
        await _offlineDb.markTableAsSynced('prayer_formulas');
      }
    } catch (e) {
      developer.log('Error updating prayer formula: $e', error: e);
    }
  }

  Future<void> deletePrayerFormula(String id) async {
    try {
      await _offlineDb.deletePrayerFormula(id);
      if (_syncManager.isOnline) {
        await _supabase.from('prayer_formulas').delete().eq('id', id);
        await _offlineDb.markTableAsSynced('prayer_formulas');
      }
    } catch (e) {
      developer.log('Error deleting prayer formula: $e', error: e);
    }
  }

  Future<List<PrayerFormula>> getPrayerFormulas() async {
    try {
      return await _syncManager.getPrayerFormulas();
    } catch (e) {
      developer.log('Error fetching prayer formulas: $e', error: e);
      return [];
    }
  }

  Future<void> addEvidence(EvidenceItem evidence) async {
    try {
      await _offlineDb.insertEvidence(evidence.toJson());
      if (_syncManager.isOnline) {
        await _supabase.from('evidence').insert(evidence.toJson());
        await _offlineDb.markTableAsSynced('evidence');
      }
    } catch (e) {
      developer.log('Error adding evidence: $e', error: e);
    }
  }

  Future<void> updateEvidence(EvidenceItem evidence) async {
    try {
      await _offlineDb.updateEvidence(evidence.id, evidence.toJson());
      if (_syncManager.isOnline) {
        await _supabase
            .from('evidence')
            .update(evidence.toJson())
            .eq('id', evidence.id);
        await _offlineDb.markTableAsSynced('evidence');
      }
    } catch (e) {
      developer.log('Error updating evidence: $e', error: e);
    }
  }

  Future<void> deleteEvidence(String id) async {
    try {
      await _offlineDb.deleteEvidence(id);
      if (_syncManager.isOnline) {
        await _supabase.from('evidence').delete().eq('id', id);
        await _offlineDb.markTableAsSynced('evidence');
      }
    } catch (e) {
      developer.log('Error deleting evidence: $e', error: e);
    }
  }

  Future<List<EvidenceItem>> getEvidence() async {
    try {
      return await _syncManager.getEvidence();
    } catch (e) {
      developer.log('Error fetching evidence: $e', error: e);
      return [];
    }
  }

  Future<void> addHadith(HadithItem hadith) async {
    try {
      await _offlineDb.insertHadith(hadith.toJson());
      if (_syncManager.isOnline) {
        await _supabase.from('hadith').insert(hadith.toJson());
        await _offlineDb.markTableAsSynced('hadith');
      }
    } catch (e) {
      developer.log('Error adding hadith: $e', error: e);
    }
  }

  Future<void> updateHadith(HadithItem hadith) async {
    try {
      await _offlineDb.updateHadith(hadith.id, hadith.toJson());
      if (_syncManager.isOnline) {
        await _supabase
            .from('hadith')
            .update(hadith.toJson())
            .eq('id', hadith.id);
        await _offlineDb.markTableAsSynced('hadith');
      }
    } catch (e) {
      developer.log('Error updating hadith: $e', error: e);
    }
  }

  Future<void> deleteHadith(String id) async {
    try {
      await _offlineDb.deleteHadith(id);
      if (_syncManager.isOnline) {
        await _supabase.from('hadith').delete().eq('id', id);
        await _offlineDb.markTableAsSynced('hadith');
      }
    } catch (e) {
      developer.log('Error deleting hadith: $e', error: e);
    }
  }

  Future<List<HadithItem>> getHadith() async {
    try {
      return await _syncManager.getHadith();
    } catch (e) {
      developer.log('Error fetching hadith: $e', error: e);
      return [];
    }
  }

  Future<void> addMedia(MediaItem media) async {
    try {
      await _offlineDb.insertMedia(media.toJson());
      if (_syncManager.isOnline) {
        await _supabase.from('media').insert(media.toJson());
        await _offlineDb.markTableAsSynced('media');
      }
    } catch (e) {
      developer.log('Error adding media: $e', error: e);
    }
  }

  Future<void> updateMedia(MediaItem media) async {
    try {
      await _offlineDb.updateMedia(media.id, media.toJson());
      if (_syncManager.isOnline) {
        await _supabase.from('media').update(media.toJson()).eq('id', media.id);
        await _offlineDb.markTableAsSynced('media');
      }
    } catch (e) {
      developer.log('Error updating media: $e', error: e);
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _offlineDb.deleteMedia(id);
      if (_syncManager.isOnline) {
        await _supabase.from('media').delete().eq('id', id);
        await _offlineDb.markTableAsSynced('media');
      }
    } catch (e) {
      developer.log('Error deleting media: $e', error: e);
    }
  }

  Future<List<MediaItem>> getMedia({String? type}) async {
    try {
      return await _syncManager.getMedia(type: type);
    } catch (e) {
      developer.log('Error fetching media: $e', error: e);
      return [];
    }
  }

  Future<void> addSound(SoundItem sound) async {
    try {
      await _offlineDb.insertSound(sound.toJson());
      if (_syncManager.isOnline) {
        await _supabase.from('sounds').insert(sound.toJson());
        await _offlineDb.markTableAsSynced('sounds');
      }
    } catch (e) {
      developer.log('Error adding sound: $e', error: e);
    }
  }

  Future<void> updateSound(SoundItem sound) async {
    try {
      await _offlineDb.updateSound(sound.id, sound.toJson());
      if (_syncManager.isOnline) {
        await _supabase
            .from('sounds')
            .update(sound.toJson())
            .eq('id', sound.id);
        await _offlineDb.markTableAsSynced('sounds');
      }
    } catch (e) {
      developer.log('Error updating sound: $e', error: e);
    }
  }

  Future<void> deleteSound(String id) async {
    try {
      await _offlineDb.deleteSound(id);
      if (_syncManager.isOnline) {
        await _supabase.from('sounds').delete().eq('id', id);
        await _offlineDb.markTableAsSynced('sounds');
      }
    } catch (e) {
      developer.log('Error deleting sound: $e', error: e);
    }
  }

  Future<List<SoundItem>> getSounds() async {
    try {
      return await _syncManager.getSounds();
    } catch (e) {
      developer.log('Error fetching sounds: $e', error: e);
      return [];
    }
  }

  Future<void> addPrayerFormulaSound(PrayerFormulaSound sound) async {
    try {
      developer.log('[OFFLINE_SAVE] Saving prayer formula sound to offline DB');
      final json = sound.toJson();
      await _offlineDb.insertPrayerFormulaSound(json);

      if (_syncManager.isOnline) {
        developer.log(
          '[SUPABASE_SAVE] ===== SAVING PRAYER FORMULA SOUND =====',
        );
        developer.log('[SUPABASE_SAVE] Sound title: ${sound.title}');
        developer.log('[SUPABASE_SAVE] Sound language: ${sound.language}');
        developer.log(
          '[SUPABASE_SAVE] Sound binary length: ${sound.soundBinary?.length ?? 0} bytes',
        );

        if (sound.soundBinary != null && sound.soundBinary!.isNotEmpty) {
          final firstBytes = sound.soundBinary!.length >= 4
              ? sound.soundBinary!.sublist(0, 4)
              : sound.soundBinary!;
          final firstBytesHex = firstBytes
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join(' ');
          developer.log('[SUPABASE_SAVE] First bytes (HEX): $firstBytesHex');
        }

        developer.log('[SUPABASE_SAVE] JSON keys: ${json.keys.toList()}');

        if (json['sound_binary'] != null) {
          final base64Data = json['sound_binary'] as String;
          developer.log(
            '[SUPABASE_SAVE] Base64 encoded length: ${base64Data.length} characters',
          );
          developer.log(
            '[SUPABASE_SAVE] Base64 first 50 chars: ${base64Data.substring(0, base64Data.length > 50 ? 50 : base64Data.length)}',
          );
        }

        developer.log('[SUPABASE_SAVE] Sending to Supabase...');
        developer.log('[SUPABASE_SAVE] Full JSON: $json');
        await _supabase.from('prayerFormulaSounds').insert(json);
        await _offlineDb.markTableAsSynced('prayer_formula_sounds');
        developer.log(
          '[SUPABASE_SAVE] ✓ Successfully added prayer formula sound',
        );
      }
    } catch (e) {
      developer.log('Error adding prayer formula sound: $e', error: e);
      rethrow;
    }
  }

  Future<void> updatePrayerFormulaSound(PrayerFormulaSound sound) async {
    try {
      final json = sound.toJson();
      await _offlineDb.updatePrayerFormulaSound(sound.id as String, json);

      if (_syncManager.isOnline) {
        developer.log('Updating prayer formula sound with id: ${sound.id}');
        developer.log('Update data: $json');
        await _supabase
            .from('prayerFormulaSounds')
            .update(json)
            .eq('id', sound.id as Object);
        await _offlineDb.markTableAsSynced('prayer_formula_sounds');
        developer.log('Successfully updated prayer formula sound');
      }
    } catch (e) {
      developer.log('Error updating prayer formula sound: $e', error: e);
      rethrow;
    }
  }

  Future<void> deletePrayerFormulaSound(String id) async {
    try {
      developer.log('deletePrayerFormulaSound called with id: $id');

      await _offlineDb.deletePrayerFormulaSound(id);
      developer.log('Deleted from offline DB');

      if (_syncManager.isOnline) {
        developer.log('Deleting from Supabase with id: $id');

        try {
          final response = await _supabase
              .from('prayerFormulaSounds')
              .delete()
              .eq('id', id);

          developer.log('Delete response: $response');
          await _offlineDb.markTableAsSynced('prayer_formula_sounds');
          developer.log('✓ Successfully deleted prayer formula sound');
        } catch (supabaseError) {
          developer.log(
            'Supabase delete error: $supabaseError',
            error: supabaseError,
          );
          throw Exception('فشل حذف من Supabase: $supabaseError');
        }
      }
    } catch (e) {
      developer.log('Error deleting prayer formula sound: $e', error: e);
      rethrow;
    }
  }

  Future<String> uploadAudioToStorage(File file, String soundTitle) async {
    try {
      final fileName = 'sound_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final storagePath = 'sounds/$fileName';

      // On mobile/desktop, use .upload(path, File) which is more memory efficient
      await _supabase.storage
          .from('files')
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = _supabase.storage.from('files').getPublicUrl(storagePath);
      return url;
    } catch (e) {
      developer.log('Error uploading audio to storage: $e', error: e);
      rethrow;
    }
  }

  Future<String> uploadAudioBytesToStorage(
    List<int> bytes,
    String soundTitle,
  ) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$soundTitle.mp3';
      developer.log('Uploading audio bytes to storage: $fileName');

      await _supabase.storage
          .from('sounds')
          .uploadBinary(fileName, Uint8List.fromList(bytes));

      final publicUrl = _supabase.storage.from('sounds').getPublicUrl(fileName);

      developer.log('Successfully uploaded audio bytes. URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      developer.log('Error uploading audio bytes to storage: $e', error: e);
      rethrow;
    }
  }

  Future<List<PrayerFormulaSound>> getPrayerFormulaSounds() async {
    try {
      return await _syncManager.getPrayerFormulaSounds();
    } catch (e) {
      developer.log('Error fetching prayer formula sounds: $e', error: e);
      return [];
    }
  }

  Future<int> getUserCount() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      final response = await _supabase
          .from('users')
          .select('id')
          .gte('lastActive', thirtyDaysAgo.toIso8601String());
      return (response as List).length;
    } catch (e) {
      developer.log('Error getting user count: $e', error: e);
      return 0;
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final results = await Future.wait([
        getUserCount(),
        getPrayerFormulas(),
        getEvidence(),
        getHadith(),
        getMedia(),
        getSounds(),
      ]);

      return {
        'users': results[0] as int,
        'formulas': (results[1] as List).length,
        'evidence': (results[2] as List).length,
        'hadith': (results[3] as List).length,
        'media': (results[4] as List).length,
        'sounds': (results[5] as List).length,
      };
    } catch (e) {
      developer.log('Error loading statistics: $e', error: e);
      return {
        'users': 0,
        'formulas': 0,
        'evidence': 0,
        'hadith': 0,
        'media': 0,
        'sounds': 0,
      };
    }
  }
}
