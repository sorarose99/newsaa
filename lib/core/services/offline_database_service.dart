import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class OfflineDatabaseService {
  static final OfflineDatabaseService _instance =
      OfflineDatabaseService._internal();
  static Database? _database;

  factory OfflineDatabaseService() {
    return _instance;
  }

  OfflineDatabaseService._internal();

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('SQLite not available on Web');
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        developer.log(
          'Web detected: Offline Database not supported natively via sqflite. Returning null.',
        );
        // We throw a clear error that we can catch or handle
        throw UnsupportedError(
          'Sqlite not supported on web without FFI configuration',
        );
      }
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'salat_offline.db');

      developer.log('Initializing offline database at: $path');

      final db = await openDatabase(
        path,
        version: 5,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      developer.log('Offline database initialized successfully');
      return db;
    } catch (e) {
      developer.log('Error initializing offline database: $e', error: e);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS prayer_formulas (
          id TEXT PRIMARY KEY,
          title_ar TEXT NOT NULL,
          title_en TEXT NOT NULL,
          content_ar TEXT NOT NULL,
          content_en TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 1,
          last_synced TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS evidence (
          id TEXT PRIMARY KEY,
          title_ar TEXT NOT NULL,
          title_en TEXT NOT NULL,
          content_ar TEXT NOT NULL,
          content_en TEXT NOT NULL,
          source TEXT NOT NULL,
          created_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 1,
          last_synced TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS hadith (
          id TEXT PRIMARY KEY,
          text_ar TEXT NOT NULL,
          text_en TEXT NOT NULL,
          narrator TEXT NOT NULL,
          source TEXT NOT NULL,
          created_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 1,
          last_synced TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS media (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          url TEXT NOT NULL,
          description TEXT,
          created_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 1,
          last_synced TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sounds (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          url TEXT NOT NULL,
          duration INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 1,
          last_synced TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS prayer_formula_sounds (
          id TEXT PRIMARY KEY,
          language TEXT NOT NULL,
          title TEXT NOT NULL,
          url TEXT,
          sound_binary TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT,
          is_synced INTEGER DEFAULT 1,
          last_synced TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS virtues (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          category TEXT,
          text TEXT NOT NULL,
          title TEXT,
          description TEXT,
          url TEXT,
          file_path TEXT,
          image_binary TEXT,
          created_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 1,
          last_synced TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_metadata (
          table_name TEXT PRIMARY KEY,
          last_sync_time TEXT,
          sync_status TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS lastChanges (
          entityName TEXT PRIMARY KEY,
          lastChange TEXT NOT NULL
        )
      ''');

      await db.insert('lastChanges', {
        'entityName': 'prayerFormulaSounds',
        'lastChange': '1970-01-01T00:00:00Z',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await db.insert('lastChanges', {
        'entityName': 'virtues',
        'lastChange': '1970-01-01T00:00:00Z',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await _initializeDefaultPrayerFormulaSound(db);

      developer.log('Database tables created successfully');
    } catch (e) {
      developer.log('Error creating database tables: $e', error: e);
      rethrow;
    }
  }

  Future<void> _initializeDefaultPrayerFormulaSound(Database db) async {
    try {
      developer.log(
        'Initializing default prayer formula sound during database creation...',
      );

      bool defaultInitialized = false;

      try {
        final connectivity = Connectivity();
        final connectivityResult = await connectivity.checkConnectivity();
        final isOnline =
            connectivityResult.isNotEmpty &&
            !connectivityResult.contains(ConnectivityResult.none);

        if (isOnline) {
          try {
            developer.log(
              'Online: Attempting to fetch default sound from Supabase...',
            );

            final supabase = Supabase.instance.client;
            final response = await supabase
                .from('prayerFormulaSounds')
                .select('*')
                .eq('title', 'default')
                .limit(1);

            if (response.isNotEmpty) {
              final defaultSound = response[0];
              developer.log(
                'Found default sound in Supabase: id=${defaultSound['id']}, title=${defaultSound['title']}',
              );

              final soundBinary = defaultSound['sound_binary'];
              final insertData = {
                'id': defaultSound['id'].toString(),
                'language': defaultSound['language'] ?? 'ar',
                'title': defaultSound['title'],
                'sound_binary': soundBinary,
                'is_active': 1,
                'created_at':
                    defaultSound['created_at'] ??
                    DateTime.now().toIso8601String(),
                'is_synced': 1,
                'last_synced': DateTime.now().toIso8601String(),
              };

              await db.insert(
                'prayer_formula_sounds',
                insertData,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );

              defaultInitialized = true;
              developer.log(
                '✓ Successfully initialized default sound from Supabase',
              );
            } else {
              developer.log('No default sound found in Supabase');
            }
          } catch (e) {
            developer.log(
              'Error fetching default sound from Supabase: $e',
              error: e,
            );
          }
        } else {
          developer.log('Offline: Skipping Supabase fetch');
        }
      } catch (e) {
        developer.log('Error checking connectivity: $e', error: e);
      }

      if (!defaultInitialized) {
        developer.log('Creating fallback default sound with binary data');

        final defaultSoundBinary =
            '${'SUQzBAAAAAAAf1RYWFgAAAASAAADbWFqb3JfYnJhbmQAbXA0MgBUWFhYAAAAEQAAA21pbm9yX3ZlcnNpb24AMABUWFhYAAAAHAAAA2NvbXBhdGlibGVfYnJhbmRzAGlzb21tcDQyAFRTU0UAAAAOAAADTGF2ZjYxLjcuMTAwAAAAAAAAAAAAAAD/+1AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABJbmZvAAAADwAAALAAASAoAAMGCQwNEBMWFxodICIkJyosLzI0Njk8P0FDRklMTVBTVldaXWBhZGdqbG5xdHZ5fH6Bg4aJi42Qk5aXmp2goaSnqquusbS2uLu+wcPFyMvN0NPV19rd4OHk5+rr7vH09fj7/gAAAABMYXZjNjEuMTkAAAAAAAAAAAAAAAAkBcAAAAAAAAEgKFuSUxoAAAAAAAAAAAAAAAAAAAAA//uQZAAP8AAAaQAAAAgAAA0gAAABAAABpAAAACAAADSAAAAETEFNRTMuMTAwVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVTEFNRTMuMTAwVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//uSZECP8AAAaQAAAAgAAA0gAAABAAABpAAAACAAADSAAAAEVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUxBTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVf/7kmRAj/AAAGkAAAAIAAANIAAAAQAAAaQAAAAgAAA0gAAABFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVMQU1FMy4xMDBVVVVVVVVVVVVVVVVVVVVVVVVVVVV'}${_getLongBase64Part()}';

        final fallbackSound = {
          'id': 'default',
          'language': 'ar',
          'title': 'default',
          'sound_binary': defaultSoundBinary,
          'is_active': 1,
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 0,
          'last_synced': null,
        };

        await db.insert(
          'prayer_formula_sounds',
          fallbackSound,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        developer.log(
          '✓ Successfully created fallback default sound with audio binary',
        );
      }
    } catch (e) {
      developer.log(
        'Error initializing default prayer formula sound: $e',
        error: e,
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      developer.log(
        'Upgrading database from version $oldVersion to $newVersion',
      );

      if (oldVersion < 2) {
        developer.log(
          'Migrating prayer_formula_sounds table to use TEXT for sound_binary',
        );
        await db.execute('''
          ALTER TABLE prayer_formula_sounds 
          RENAME TO prayer_formula_sounds_old
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS prayer_formula_sounds (
            id TEXT PRIMARY KEY,
            language TEXT NOT NULL,
            title TEXT NOT NULL,
            sound_binary TEXT,
            is_active INTEGER DEFAULT 1,
            created_at TEXT,
            is_synced INTEGER DEFAULT 1,
            last_synced TEXT
          )
        ''');

        await db.execute('''
          INSERT INTO prayer_formula_sounds 
          SELECT * FROM prayer_formula_sounds_old
        ''');

        await db.execute('DROP TABLE prayer_formula_sounds_old');
        developer.log('Successfully migrated prayer_formula_sounds table');
      }

      if (oldVersion < 3) {
        developer.log('Creating virtues table');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS virtues (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            category TEXT,
            text TEXT NOT NULL,
            title TEXT,
            description TEXT,
            url TEXT,
            file_path TEXT,
            image_binary TEXT,
            created_at TEXT NOT NULL,
            is_synced INTEGER DEFAULT 1,
            last_synced TEXT
          )
        ''');
        developer.log('Successfully created virtues table');
      }

      if (oldVersion < 4) {
        developer.log('Creating lastChanges table');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS lastChanges (
            entityName TEXT PRIMARY KEY,
            lastChange TEXT NOT NULL
          )
        ''');

        await db.insert('lastChanges', {
          'entityName': 'prayerFormulaSounds',
          'lastChange': '1970-01-01T00:00:00Z',
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        await db.insert('lastChanges', {
          'entityName': 'virtues',
          'lastChange': '1970-01-01T00:00:00Z',
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        await _initializeDefaultPrayerFormulaSound(db);

        developer.log('Successfully created lastChanges table');
      }
      if (oldVersion < 5) {
        developer.log('Adding url column to prayer_formula_sounds table');
        try {
          await db.execute(
            'ALTER TABLE prayer_formula_sounds ADD COLUMN url TEXT',
          );
          developer.log('Successfully added url column');
        } catch (e) {
          developer.log('Error adding url column: $e');
        }
      }
    } catch (e) {
      developer.log('Error upgrading database: $e', error: e);
    }
  }

  Future<void> updateSyncMetadata(String tableName) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.insert('sync_metadata', {
        'table_name': tableName,
        'last_sync_time': DateTime.now().toIso8601String(),
        'sync_status': 'synced',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      developer.log('Error updating sync metadata: $e', error: e);
    }
  }

  Future<DateTime?> getLastSyncTime(String tableName) async {
    if (kIsWeb) return null;
    try {
      final db = await database;
      final result = await db.query(
        'sync_metadata',
        where: 'table_name = ?',
        whereArgs: [tableName],
      );

      if (result.isNotEmpty) {
        final lastSync = result.first['last_sync_time'] as String?;
        return lastSync != null ? DateTime.parse(lastSync) : null;
      }
      return null;
    } catch (e) {
      developer.log('Error getting last sync time: $e', error: e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPrayerFormulas() async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      return await db.query('prayer_formulas');
    } catch (e) {
      developer.log(
        'Error getting prayer formulas from local db: $e',
        error: e,
      );
      return [];
    }
  }

  Future<void> insertPrayerFormula(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.insert('prayer_formulas', {
        ...data,
        'is_synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      developer.log('Error inserting prayer formula: $e', error: e);
    }
  }

  Future<void> updatePrayerFormula(String id, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(
        'prayer_formulas',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error updating prayer formula: $e', error: e);
    }
  }

  Future<void> deletePrayerFormula(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.delete('prayer_formulas', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Error deleting prayer formula: $e', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getEvidence() async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      return await db.query('evidence');
    } catch (e) {
      developer.log('Error getting evidence from local db: $e', error: e);
      return [];
    }
  }

  Future<void> insertEvidence(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.insert('evidence', {
        ...data,
        'is_synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      developer.log('Error inserting evidence: $e', error: e);
    }
  }

  Future<void> updateEvidence(String id, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(
        'evidence',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error updating evidence: $e', error: e);
    }
  }

  Future<void> deleteEvidence(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.delete('evidence', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Error deleting evidence: $e', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getHadith() async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      return await db.query('hadith');
    } catch (e) {
      developer.log('Error getting hadith from local db: $e', error: e);
      return [];
    }
  }

  Future<void> insertHadith(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.insert('hadith', {
        ...data,
        'is_synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      developer.log('Error inserting hadith: $e', error: e);
    }
  }

  Future<void> updateHadith(String id, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(
        'hadith',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error updating hadith: $e', error: e);
    }
  }

  Future<void> deleteHadith(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.delete('hadith', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Error deleting hadith: $e', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getMedia({String? type}) async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      if (type != null) {
        return await db.query('media', where: 'type = ?', whereArgs: [type]);
      }
      return await db.query('media');
    } catch (e) {
      developer.log('Error getting media from local db: $e', error: e);
      return [];
    }
  }

  Future<void> insertMedia(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.insert('media', {
        ...data,
        'is_synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      developer.log('Error inserting media: $e', error: e);
    }
  }

  Future<void> updateMedia(String id, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(
        'media',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error updating media: $e', error: e);
    }
  }

  Future<void> deleteMedia(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.delete('media', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Error deleting media: $e', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getSounds() async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      return await db.query('sounds');
    } catch (e) {
      developer.log('Error getting sounds from local db: $e', error: e);
      return [];
    }
  }

  Future<void> insertSound(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.insert('sounds', {
        ...data,
        'is_synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      developer.log('Error inserting sound: $e', error: e);
    }
  }

  Future<void> updateSound(String id, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(
        'sounds',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error updating sound: $e', error: e);
    }
  }

  Future<void> deleteSound(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.delete('sounds', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Error deleting sound: $e', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getPrayerFormulaSounds() async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      final results = await db.query('prayer_formula_sounds');
      developer.log(
        '[DB_SOUNDS] Retrieved ${results.length} prayer formula sounds from local db',
      );

      return results.map((row) {
        final soundBinary = row['sound_binary'];
        final soundBinaryType = soundBinary?.runtimeType.toString() ?? 'null';
        final soundBinaryLength = soundBinary is String
            ? soundBinary.length
            : 0;
        final soundBinaryPreview =
            soundBinary is String && soundBinary.isNotEmpty
            ? soundBinary.substring(
                0,
                soundBinary.length > 50 ? 50 : soundBinary.length,
              )
            : 'N/A';

        developer.log(
          '[DB_SOUNDS] Sound: id=${row['id']}, title=${row['title']}, '
          'sound_binary_type=$soundBinaryType, '
          'sound_binary_length=$soundBinaryLength chars, '
          'preview=$soundBinaryPreview',
        );

        return {
          ...row,
          if (row['is_active'] is int)
            'is_active': (row['is_active'] as int) == 1,
        };
      }).toList();
    } catch (e) {
      developer.log(
        'Error getting prayer formula sounds from local db: $e',
        error: e,
      );
      return [];
    }
  }

  Future<void> insertPrayerFormulaSound(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;

      final insertData = {...data, 'is_synced': 0};

      if (insertData['is_active'] is bool) {
        insertData['is_active'] = insertData['is_active'] ? 1 : 0;
      }

      final soundBinarySize =
          (insertData['sound_binary'] as String?)?.length ?? 0;
      developer.log(
        'Inserting prayer formula sound: id=${insertData['id']}, title=${insertData['title']}, sound_size=$soundBinarySize bytes',
      );

      await db.insert(
        'prayer_formula_sounds',
        insertData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      developer.log(
        'Successfully inserted prayer formula sound: ${insertData['id']}',
      );
    } catch (e) {
      developer.log('Error inserting prayer formula sound: $e', error: e);
    }
  }

  Future<void> updatePrayerFormulaSound(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(
        'prayer_formula_sounds',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error updating prayer formula sound: $e', error: e);
    }
  }

  Future<void> deletePrayerFormulaSound(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.delete(
        'prayer_formula_sounds',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error deleting prayer formula sound: $e', error: e);
    }
  }

  Future<List<Map<String, dynamic>>> getVirtues() async {
    if (kIsWeb) return [];
    try {
      final db = await database;
      return await db.query('virtues');
    } catch (e) {
      developer.log('Error getting virtues from local db: $e', error: e);
      return [];
    }
  }

  Future<void> insertVirtue(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.insert('virtues', {
        ...data,
        'is_synced': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      developer.log('Error inserting virtue: $e', error: e);
    }
  }

  Future<void> updateVirtue(String id, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(
        'virtues',
        {...data, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error updating virtue: $e', error: e);
    }
  }

  Future<void> deleteVirtue(String id) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.delete('virtues', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Error deleting virtue: $e', error: e);
    }
  }

  Future<void> markTableAsSynced(String tableName) async {
    if (kIsWeb) return;
    try {
      final db = await database;
      await db.update(tableName, {
        'is_synced': 1,
        'last_synced': DateTime.now().toIso8601String(),
      });
      await updateSyncMetadata(tableName);
    } catch (e) {
      developer.log('Error marking table as synced: $e', error: e);
    }
  }

  Future<DateTime?> getLastChangeForEntity(String entityName) async {
    if (kIsWeb) return null;
    try {
      final db = await database;
      final result = await db.query(
        'lastChanges',
        where: 'entityName = ?',
        whereArgs: [entityName],
      );

      if (result.isNotEmpty) {
        final lastChangeStr = result.first['lastChange'] as String?;
        if (lastChangeStr != null) {
          return DateTime.parse(lastChangeStr);
        }
      }
      return null;
    } catch (e) {
      developer.log(
        'Error getting last change for entity $entityName: $e',
        error: e,
      );
      return null;
    }
  }

  Future<void> updateLastChangeForEntity(
    String entityName,
    DateTime lastChange,
  ) async {
    try {
      final db = await database;
      await db.update(
        'lastChanges',
        {'entityName': entityName, 'lastChange': lastChange.toIso8601String()},
        where: 'entityName = ?',
        whereArgs: [entityName],
      );
      developer.log(
        'Updated lastChange for $entityName to ${lastChange.toIso8601String()}',
      );
    } catch (e) {
      developer.log(
        'Error updating last change for entity $entityName: $e',
        error: e,
      );
    }
  }

  Future<Map<String, DateTime>> getAllLastChanges() async {
    try {
      final db = await database;
      final results = await db.query('lastChanges');

      final map = <String, DateTime>{};
      for (final row in results) {
        final entityName = row['entityName'] as String?;
        final lastChangeStr = row['lastChange'] as String?;
        if (entityName != null && lastChangeStr != null) {
          map[entityName] = DateTime.parse(lastChangeStr);
        }
      }
      return map;
    } catch (e) {
      developer.log('Error getting all last changes: $e', error: e);
      return {};
    }
  }

  String _getLongBase64Part() {
    return 'UVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVf/7kmRAj/AAAGkAAAAIAAANIAAAAQAAAaQAAAAgAAA0gAAABFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUxBTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVf/7kmRAj/AAAGkAAAAIAAANIAAAAQAAAaQAAAAgAAA0gAAABFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVMQU1FMy4xMDBVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVf/7kmRAj/AAAGkAAAAIAAANIAAAAQAAAaQAAAAgAAA0gAAABFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVMQU1FMy4xMDBVVVVVVVVVVVVVVVVVVVVVVVVVV';
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
