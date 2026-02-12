import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef AdminData = Map<String, dynamic>;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static const Duration _defaultTimeout = Duration(seconds: 30);

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://mcmgbsxzdakqxjkrjlex.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jbWdic3h6ZGFrcXhqa3JqbGV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0ODQ1MzAsImV4cCI6MjA4NjA2MDUzMH0.QiPYMhRxHUPqYPZ6xwiWOZdU-I5xGQiA8eyjcwmPY68',
      );
    } catch (e) {
      developer.log('Supabase initialization error: $e', error: e);
      rethrow;
    }
  }

  Future<({String userId, AdminData adminData})> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password cannot be empty');
    }

    try {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('User not found in response');
      }

      final userId = user.id;
      developer.log('User signed in: $userId');

      final adminData = await client
          .from('admins')
          .select('*')
          .eq('id', userId)
          .single();

      return (userId: userId, adminData: adminData);
    } on AuthException catch (e) {
      developer.log('Login failed: ${e.message}', error: e);
      rethrow;
    } catch (e) {
      developer.log('Unexpected error during login: $e', error: e);
      rethrow;
    }
  }

  Future<AdminData> executeAdminTask({
    required String taskType,
    required AdminData data,
    Duration timeout = _defaultTimeout,
  }) async {
    if (taskType.isEmpty) {
      throw ArgumentError('Task type cannot be empty');
    }
    if (data.isEmpty) {
      throw ArgumentError('Data cannot be empty');
    }

    final session = client.auth.currentSession;
    if (session == null) {
      throw Exception('User is not authenticated');
    }

    try {
      developer.log('Executing admin task: $taskType', name: 'AdminTask');

      final response = await client.functions
          .invoke('admin-tasks', body: {'task': taskType, 'payload': data})
          .timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                'Admin task timed out after ${timeout.inSeconds}s',
              );
            },
          );

      if (response.status != 200) {
        developer.log(
          'Admin task failed with status ${response.status}',
          name: 'AdminTask',
        );
        throw Exception('Admin task failed with status ${response.status}');
      }

      final result = response.data as AdminData?;
      if (result == null) {
        throw Exception('No data returned from admin task');
      }

      developer.log('Admin task completed successfully', name: 'AdminTask');
      return result;
    } catch (e) {
      developer.log(
        'Error executing admin task: $e',
        error: e,
        name: 'AdminTask',
      );
      rethrow;
    }
  }

  Future<AdminData?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      developer.log('Error fetching user profile: $e', error: e);
      rethrow;
    }
  }

  Future<void> updateUserProfile(String userId, AdminData profileData) async {
    try {
      await client.from('users').update(profileData).eq('id', userId);
      developer.log('User profile updated: $userId');
    } catch (e) {
      developer.log('Error updating user profile: $e', error: e);
      rethrow;
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? username,
  }) async {
    try {
      await client.from('users').insert({
        'id': userId,
        'email': email,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
      developer.log('User profile created: $userId');
    } catch (e) {
      developer.log('Error creating user profile: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> getVirtues({int limit = 50, int offset = 0}) async {
    try {
      final response = await client
          .from('virtues')
          .select()
          .range(offset, offset + limit - 1);
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error fetching virtues: $e', error: e);
      rethrow;
    }
  }

  Future<AdminData?> getVirtueById(String id) async {
    try {
      final response = await client
          .from('virtues')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      developer.log('Error fetching virtue: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> getPrayerFormulas({
    String? virtueId,
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = client.from('prayer_formulas').select();
      if (virtueId != null) {
        query = query.eq('virtue_id', virtueId);
      }
      if (category != null) {
        query = query.eq('category', category);
      }
      final response = await query.range(offset, offset + limit - 1);
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error fetching prayer formulas: $e', error: e);
      rethrow;
    }
  }

  Future<AdminData?> getPrayerFormulaById(String id) async {
    try {
      final response = await client
          .from('prayer_formulas')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      developer.log('Error fetching prayer formula: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> getEvidence({
    String? prayerFormulaId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = client.from('evidence').select();
      if (prayerFormulaId != null) {
        query = query.eq('prayer_formula_id', prayerFormulaId);
      }
      final response = await query.range(offset, offset + limit - 1);
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error fetching evidence: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> getHadith({int limit = 50, int offset = 0}) async {
    try {
      final response = await client
          .from('hadith')
          .select()
          .range(offset, offset + limit - 1);
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error fetching hadith: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> getMedia({
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = client.from('media').select();
      if (type != null) {
        query = query.eq('type', type);
      }
      final response = await query.range(offset, offset + limit - 1);
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error fetching media: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> getSounds({int limit = 50, int offset = 0}) async {
    try {
      final response = await client
          .from('sounds')
          .select()
          .range(offset, offset + limit - 1);
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error fetching sounds: $e', error: e);
      rethrow;
    }
  }

  Future<void> addFavorite({
    required String userId,
    required String formulaId,
  }) async {
    try {
      await client.from('favorites').insert({
        'user_id': userId,
        'prayer_formula_id': formulaId,
        'created_at': DateTime.now().toIso8601String(),
      });
      developer.log('Favorite added: $formulaId for user $userId');
    } catch (e) {
      developer.log('Error adding favorite: $e', error: e);
      rethrow;
    }
  }

  Future<void> removeFavorite({
    required String userId,
    required String formulaId,
  }) async {
    try {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('prayer_formula_id', formulaId);
      developer.log('Favorite removed: $formulaId for user $userId');
    } catch (e) {
      developer.log('Error removing favorite: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> getUserFavorites(String userId) async {
    try {
      final response = await client
          .from('favorites')
          .select('prayer_formula_id, prayer_formulas(*)')
          .eq('user_id', userId);
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error fetching user favorites: $e', error: e);
      rethrow;
    }
  }

  Future<bool> isFavorite({
    required String userId,
    required String formulaId,
  }) async {
    try {
      final response = await client
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('prayer_formula_id', formulaId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      developer.log('Error checking favorite: $e', error: e);
      return false;
    }
  }

  Future<String> uploadFile({
    required File file,
    required String bucket,
    required String destination,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();

      await client.storage
          .from(bucket)
          .uploadBinary('$destination/$fileName', fileBytes);

      final url = client.storage
          .from(bucket)
          .getPublicUrl('$destination/$fileName');

      developer.log('File uploaded successfully: $url');
      return url;
    } catch (e) {
      developer.log('Error uploading file: $e', error: e);
      rethrow;
    }
  }

  Future<void> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await client.storage.from(bucket).remove([filePath]);
      developer.log('File deleted successfully: $filePath');
    } catch (e) {
      developer.log('Error deleting file: $e', error: e);
      rethrow;
    }
  }

  Future<List<AdminData>> searchContent({
    required String query,
    String table = 'prayer_formulas',
    String searchField = 'formula_text',
  }) async {
    try {
      final response = await client
          .from(table)
          .select()
          .ilike(searchField, '%$query%');
      return List<AdminData>.from(response as List);
    } catch (e) {
      developer.log('Error searching content: $e', error: e);
      rethrow;
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  Future<void> dispose() async {
    await Supabase.instance.client.dispose();
  }
}
