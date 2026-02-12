import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alslat_aalnabi/features/admin/data/models/content_model.dart';
import 'package:alslat_aalnabi/features/virtues/data/models/virtue_model.dart';
import 'package:alslat_aalnabi/core/services/offline_database_service.dart';
import 'package:alslat_aalnabi/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class LastChange {
  final String entityName;
  final DateTime lastChange;

  LastChange({required this.entityName, required this.lastChange});

  factory LastChange.fromJson(Map<String, dynamic> json) {
    return LastChange(
      entityName: json['entityName'] as String,
      lastChange: DateTime.parse(json['lastChange'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityName': entityName,
      'lastChange': lastChange.toIso8601String(),
    };
  }
}

class SyncManagerService {
  static final SyncManagerService _instance = SyncManagerService._internal();
  final _offlineDb = OfflineDatabaseService();
  final _connectivity = Connectivity();
  late final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  factory SyncManagerService() {
    return _instance;
  }

  SyncManagerService._internal();

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  Timer? _periodicSyncTimer;

  Future<void> initialize() async {
    try {
      developer.log('Initializing SyncManagerService');

      _isOnline = await checkConnectivity();
      developer.log('Initial connectivity check: $_isOnline');

      await initializePrayerFormulaSoundsIfNeeded();
      await _setDefaultReminderSoundIfNeeded();

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        result,
      ) {
        _isOnline =
            result.isNotEmpty && !result.contains(ConnectivityResult.none);
        developer.log('Connectivity changed: $_isOnline');

        if (_isOnline && !_isSyncing) {
          syncAllData();
        }
      });

      if (_isOnline) {
        await syncAllData();
      }

      _startPeriodicSync();
    } catch (e) {
      developer.log('Error initializing SyncManagerService: $e', error: e);
    }
  }

  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (_isOnline && !_isSyncing) {
        developer.log('Running periodic sync check');
        checkAndSyncChanges();
      }
    });
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result.isConnected;
      return _isOnline;
    } catch (e) {
      developer.log('Error checking connectivity: $e', error: e);
      return false;
    }
  }

  Future<void> checkAndSyncChanges() async {
    if (!_isOnline || _isSyncing) return;

    try {
      developer.log('Checking for changes in lastChanges table');

      // Skip local DB check on Web
      if (kIsWeb) {
        developer.log(
          'Running on Web, skipping local DB check for lastChanges',
        );
        await syncAllData();
        return;
      }

      final localLastChanges = await _offlineDb.getAllLastChanges();

      final remoteResponse = await _supabase.from('lastChanges').select('*');
      final remoteLastChanges = (remoteResponse as List)
          .map((doc) => LastChange.fromJson(doc as Map<String, dynamic>))
          .toList();

      for (final remote in remoteLastChanges) {
        final local = localLastChanges[remote.entityName];

        developer.log(
          'Checking ${remote.entityName}: local=${local?.toIso8601String()}, remote=${remote.lastChange.toIso8601String()}',
        );

        if (local == null || remote.lastChange.isAfter(local)) {
          developer.log('${remote.entityName} has changes, syncing...');

          if (remote.entityName == 'prayerFormulaSounds') {
            await syncPrayerFormulaSounds();
          } else if (remote.entityName == 'virtues') {
            await syncVirtues();
          }
        }
      }

      developer.log('Change check completed');
    } catch (e) {
      developer.log('Error checking for changes: $e', error: e);
    }
  }

  Future<void> syncAllData() async {
    if (_isSyncing) {
      developer.log('Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      developer.log('Starting sync of all data');

      await Future.wait([
        syncPrayerFormulas(),
        syncEvidence(),
        syncHadith(),
        syncMedia(),
        syncSounds(),
        syncPrayerFormulaSounds(),
        syncVirtues(),
      ]);

      developer.log('All data synced successfully');
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      developer.log('Error syncing all data: $e', error: e);
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncPrayerFormulas() async {
    try {
      final lastSync = await _offlineDb.getLastSyncTime('prayer_formulas');

      final response = await _supabase.from('prayer_formulas').select();
      final onlineData = (response as List)
          .map((doc) => PrayerFormula.fromJson(doc as Map<String, dynamic>))
          .toList();

      for (final item in onlineData) {
        final shouldUpdate =
            lastSync == null || item.updatedAt.isAfter(lastSync);

        if (shouldUpdate) {
          await _offlineDb.insertPrayerFormula(item.toJson());
        }
      }

      await _offlineDb.updateSyncMetadata('prayer_formulas');
      developer.log('Synced ${onlineData.length} prayer formulas');
    } catch (e) {
      developer.log('Error syncing prayer formulas: $e', error: e);
    }
  }

  Future<void> syncEvidence() async {
    try {
      final lastSync = await _offlineDb.getLastSyncTime('evidence');

      final response = await _supabase.from('evidence').select();
      final onlineData = (response as List)
          .map((doc) => EvidenceItem.fromJson(doc as Map<String, dynamic>))
          .toList();

      for (final item in onlineData) {
        final shouldUpdate =
            lastSync == null || item.createdAt.isAfter(lastSync);

        if (shouldUpdate) {
          await _offlineDb.insertEvidence(item.toJson());
        }
      }

      await _offlineDb.updateSyncMetadata('evidence');
      developer.log('Synced ${onlineData.length} evidence items');
    } catch (e) {
      developer.log('Error syncing evidence: $e', error: e);
    }
  }

  Future<void> syncHadith() async {
    try {
      final lastSync = await _offlineDb.getLastSyncTime('hadith');

      final response = await _supabase.from('hadith').select();
      final onlineData = (response as List)
          .map((doc) => HadithItem.fromJson(doc as Map<String, dynamic>))
          .toList();

      for (final item in onlineData) {
        final shouldUpdate =
            lastSync == null || item.createdAt.isAfter(lastSync);

        if (shouldUpdate) {
          await _offlineDb.insertHadith(item.toJson());
        }
      }

      await _offlineDb.updateSyncMetadata('hadith');
      developer.log('Synced ${onlineData.length} hadith items');
    } catch (e) {
      developer.log('Error syncing hadith: $e', error: e);
    }
  }

  Future<void> syncMedia() async {
    try {
      final lastSync = await _offlineDb.getLastSyncTime('media');

      final response = await _supabase.from('media').select();
      final onlineData = (response as List)
          .map((doc) => MediaItem.fromJson(doc as Map<String, dynamic>))
          .toList();

      for (final item in onlineData) {
        final shouldUpdate =
            lastSync == null || item.createdAt.isAfter(lastSync);

        if (shouldUpdate) {
          await _offlineDb.insertMedia(item.toJson());
        }
      }

      await _offlineDb.updateSyncMetadata('media');
      developer.log('Synced ${onlineData.length} media items');
    } catch (e) {
      developer.log('Error syncing media: $e', error: e);
    }
  }

  Future<void> syncSounds() async {
    try {
      final lastSync = await _offlineDb.getLastSyncTime('sounds');

      final response = await _supabase.from('sounds').select();
      final onlineData = (response as List)
          .map((doc) => SoundItem.fromJson(doc as Map<String, dynamic>))
          .toList();

      for (final item in onlineData) {
        final shouldUpdate =
            lastSync == null || item.createdAt.isAfter(lastSync);

        if (shouldUpdate) {
          await _offlineDb.insertSound(item.toJson());
        }
      }

      await _offlineDb.updateSyncMetadata('sounds');
      developer.log('Synced ${onlineData.length} sound items');
    } catch (e) {
      developer.log('Error syncing sounds: $e', error: e);
    }
  }

  Future<void> syncPrayerFormulaSounds() async {
    try {
      developer.log('Starting syncPrayerFormulaSounds...');

      final localLastChange = await _offlineDb.getLastChangeForEntity(
        'prayerFormulaSounds',
      );
      developer.log(
        'Local lastChange for prayerFormulaSounds: ${localLastChange?.toIso8601String()}',
      );

      final response = await _supabase.from('prayerFormulaSounds').select('*');
      developer.log(
        'Response from Supabase prayer_formula_sounds: ${(response as List).length} items',
      );

      final onlineData = (response as List).map((doc) {
        developer.log(
          'Processing sound from Supabase: id=${doc['id']}, title=${doc['title']}, has_binary=${doc['sound_binary'] != null}',
        );
        return PrayerFormulaSound.fromJson(doc as Map<String, dynamic>);
      }).toList();

      developer.log(
        'Processed ${onlineData.length} prayer formula sounds from Supabase',
      );

      for (final item in onlineData) {
        final shouldUpdate =
            localLastChange == null ||
            (item.createdAt != null &&
                item.createdAt!.isAfter(localLastChange));

        if (shouldUpdate) {
          developer.log(
            'Saving to local db: id=${item.id}, title=${item.title}, sound_size=${item.soundBinary?.length ?? 0}',
          );
          await _offlineDb.insertPrayerFormulaSound(item.toJson());
        }
      }

      final remoteLastChangeResponse = await _supabase
          .from('lastChanges')
          .select('lastChange')
          .eq('entityName', 'prayerFormulaSounds')
          .single();

      final remoteLastChangeStr =
          remoteLastChangeResponse['lastChange'] as String?;
      if (remoteLastChangeStr != null) {
        final remoteLastChange = DateTime.parse(remoteLastChangeStr);
        await _offlineDb.updateLastChangeForEntity(
          'prayerFormulaSounds',
          remoteLastChange,
        );
      }

      await _offlineDb.updateSyncMetadata('prayer_formula_sounds');
      developer.log('Synced ${onlineData.length} prayer formula sounds');
    } catch (e) {
      developer.log('Error syncing prayer formula sounds: $e', error: e);
    }
  }

  Future<void> syncVirtues() async {
    try {
      developer.log('Starting syncVirtues...');

      final response = await _supabase.from('virtues').select('*');
      developer.log(
        'Response from Supabase virtues: ${(response as List).length} items',
      );

      final onlineData = (response as List).map((doc) {
        return Virtue.fromJson(doc as Map<String, dynamic>);
      }).toList();

      developer.log('Processed ${onlineData.length} virtues from Supabase');

      for (final item in onlineData) {
        developer.log(
          'Saving virtue to local db: id=${item.id}, title=${item.title}',
        );
        await _offlineDb.insertVirtue(item.toJson());
      }

      await _offlineDb.updateSyncMetadata('virtues');
      developer.log('Synced ${onlineData.length} virtues successfully');
    } catch (e) {
      developer.log('Error syncing virtues: $e', error: e);
    }
  }

  Future<void> _setDefaultReminderSoundIfNeeded() async {
    try {
      final storage = StorageService();
      final selectedSoundId = storage.getSelectedReminderSoundId();

      if (selectedSoundId == null || selectedSoundId.isEmpty) {
        developer.log(
          'No reminder sound selected, attempting to set default...',
        );

        final existingSounds = await _offlineDb.getPrayerFormulaSounds();

        if (existingSounds.isNotEmpty) {
          final defaultSound = existingSounds.firstWhere(
            (sound) => sound['title'] == 'default',
            orElse: () => existingSounds.first,
          );

          final soundId = defaultSound['id'] as String?;
          if (soundId != null && soundId.isNotEmpty) {
            await storage.setSelectedReminderSoundId(soundId);
            developer.log('✓ Set default reminder sound: $soundId');
          }
        } else {
          developer.log('⚠ No sounds available to set as default');
        }
      } else {
        developer.log('Reminder sound already selected: $selectedSoundId');
      }
    } catch (e) {
      developer.log('Error setting default reminder sound: $e', error: e);
    }
  }

  Future<void> initializePrayerFormulaSoundsIfNeeded() async {
    try {
      developer.log(
        'Checking if prayer formula sounds table needs initialization...',
      );

      final existingSounds = await _offlineDb.getPrayerFormulaSounds();

      if (existingSounds.isNotEmpty) {
        developer.log(
          'Prayer formula sounds table already initialized with ${existingSounds.length} sounds',
        );
        return;
      }

      developer.log(
        'Prayer formula sounds table is empty, attempting to initialize with default...',
      );

      bool defaultInitialized = false;

      if (_isOnline) {
        try {
          developer.log(
            'Attempting to fetch default prayer formula sound from Supabase...',
          );

          final response = await _supabase
              .from('prayerFormulaSounds')
              .select('*')
              .eq('title', 'default')
              .limit(1);

          if (response.isNotEmpty) {
            final defaultSound = PrayerFormulaSound.fromJson(response[0]);
            developer.log(
              'Found default sound from Supabase: id=${defaultSound.id}, title=${defaultSound.title}',
            );

            await _offlineDb.insertPrayerFormulaSound(defaultSound.toJson());
            defaultInitialized = true;
            developer.log(
              'Successfully initialized prayer formula sounds with default from Supabase',
            );
          } else {
            developer.log('No default prayer formula sound found in Supabase');
          }
        } catch (e) {
          developer.log('Error fetching default from Supabase: $e', error: e);
        }
      }

      if (!defaultInitialized) {
        developer.log('Creating fallback default prayer formula sound');

        final fallbackSound = PrayerFormulaSound(
          id: 'default-fallback',
          language: 'ar',
          title: 'default',
          soundBinary: null,
          isActive: true,
          createdAt: DateTime.now(),
        );

        await _offlineDb.insertPrayerFormulaSound(fallbackSound.toJson());
        developer.log(
          'Successfully initialized with fallback default prayer formula sound',
        );
      }
    } catch (e) {
      developer.log('Error initializing prayer formula sounds: $e', error: e);
    }
  }

  Future<List<PrayerFormula>> getPrayerFormulas({
    bool forceOnline = false,
  }) async {
    try {
      final offlineData = await _offlineDb.getPrayerFormulas();

      if (offlineData.isNotEmpty || !_isOnline) {
        return offlineData.map((data) => PrayerFormula.fromJson(data)).toList();
      }

      developer.log('Syncing prayer formulas from online...');
      await syncPrayerFormulas();

      final syncedData = await _offlineDb.getPrayerFormulas();
      return syncedData.map((data) => PrayerFormula.fromJson(data)).toList();
    } catch (e) {
      developer.log('Error getting prayer formulas: $e', error: e);
      return [];
    }
  }

  Future<List<EvidenceItem>> getEvidence({bool forceOnline = false}) async {
    try {
      final offlineData = await _offlineDb.getEvidence();

      if (offlineData.isNotEmpty || !_isOnline) {
        return offlineData.map((data) => EvidenceItem.fromJson(data)).toList();
      }

      developer.log('Syncing evidence from online...');
      await syncEvidence();

      final syncedData = await _offlineDb.getEvidence();
      return syncedData.map((data) => EvidenceItem.fromJson(data)).toList();
    } catch (e) {
      developer.log('Error getting evidence: $e', error: e);
      return [];
    }
  }

  Future<List<HadithItem>> getHadith({bool forceOnline = false}) async {
    try {
      final offlineData = await _offlineDb.getHadith();

      if (offlineData.isNotEmpty || !_isOnline) {
        return offlineData.map((data) => HadithItem.fromJson(data)).toList();
      }

      developer.log('Syncing hadith from online...');
      await syncHadith();

      final syncedData = await _offlineDb.getHadith();
      return syncedData.map((data) => HadithItem.fromJson(data)).toList();
    } catch (e) {
      developer.log('Error getting hadith: $e', error: e);
      return [];
    }
  }

  Future<List<MediaItem>> getMedia({
    String? type,
    bool forceOnline = false,
  }) async {
    try {
      final offlineData = await _offlineDb.getMedia(type: type);

      if (offlineData.isNotEmpty || !_isOnline) {
        return offlineData.map((data) => MediaItem.fromJson(data)).toList();
      }

      developer.log('Syncing media from online...');
      await syncMedia();

      final syncedData = await _offlineDb.getMedia(type: type);
      return syncedData.map((data) => MediaItem.fromJson(data)).toList();
    } catch (e) {
      developer.log('Error getting media: $e', error: e);
      return [];
    }
  }

  Future<List<SoundItem>> getSounds({bool forceOnline = false}) async {
    try {
      final offlineData = await _offlineDb.getSounds();

      if (offlineData.isNotEmpty || !_isOnline) {
        return offlineData.map((data) => SoundItem.fromJson(data)).toList();
      }

      developer.log('Syncing sounds from online...');
      await syncSounds();

      final syncedData = await _offlineDb.getSounds();
      return syncedData.map((data) => SoundItem.fromJson(data)).toList();
    } catch (e) {
      developer.log('Error getting sounds: $e', error: e);
      return [];
    }
  }

  Future<List<PrayerFormulaSound>> getPrayerFormulaSounds({
    bool forceOnline = false,
  }) async {
    try {
      developer.log(
        'getPrayerFormulaSounds called (forceOnline=$forceOnline, isOnline=$_isOnline)',
      );

      final offlineData = await _offlineDb.getPrayerFormulaSounds();
      developer.log(
        'Found ${offlineData.length} prayer formula sounds in offline db',
      );

      if (offlineData.isNotEmpty) {
        developer.log(
          'Returning ${offlineData.length} offline prayer formula sounds',
        );
        return offlineData
            .map((data) => PrayerFormulaSound.fromJson(data))
            .toList();
      }

      if (!_isOnline) {
        developer.log('No offline data and not online, returning empty list');
        return [];
      }

      developer.log('No offline data but online, syncing from Supabase...');
      await syncPrayerFormulaSounds();

      final syncedData = await _offlineDb.getPrayerFormulaSounds();
      developer.log(
        'After sync, found ${syncedData.length} prayer formula sounds',
      );
      return syncedData
          .map((data) => PrayerFormulaSound.fromJson(data))
          .toList();
    } catch (e) {
      developer.log('Error getting prayer formula sounds: $e', error: e);
      return [];
    }
  }

  Future<List<Virtue>> getVirtues({bool forceOnline = false}) async {
    try {
      developer.log(
        'getVirtues called (forceOnline=$forceOnline, isOnline=$_isOnline)',
      );

      // On web, always fetch directly from Supabase since offline DB doesn't work
      if (kIsWeb) {
        if (!_isOnline) {
          developer.log('Web platform: offline, returning empty list');
          return [];
        }
        developer.log('Web platform: fetching directly from Supabase');
        final response = await _supabase.from('virtues').select();
        return (response as List)
            .map(
              (doc) =>
                  Virtue.fromFirestore(doc as Map<String, dynamic>, doc['id']),
            )
            .toList();
      }

      // Mobile/Desktop: use offline-first approach
      if (forceOnline && _isOnline) {
        developer.log('Force sync from Supabase...');
        await syncVirtues();
      }

      final offlineData = await _offlineDb.getVirtues();
      developer.log('Found ${offlineData.length} virtues in offline db');

      if (offlineData.isNotEmpty) {
        developer.log('Returning ${offlineData.length} offline virtues');
        return offlineData.map((data) => Virtue.fromJson(data)).toList();
      }

      if (!_isOnline) {
        developer.log('No offline data and not online, returning empty list');
        return [];
      }

      developer.log('No offline data but online, syncing from Supabase...');
      await syncVirtues();

      final syncedData = await _offlineDb.getVirtues();
      return syncedData.map((data) => Virtue.fromJson(data)).toList();
    } catch (e) {
      developer.log('Error getting virtues: $e', error: e);
      return [];
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
  }
}

enum SyncStatus { syncing, synced, error }

extension ConnectivityResultExtension on List<ConnectivityResult> {
  bool get isConnected => isNotEmpty && !contains(ConnectivityResult.none);
}
