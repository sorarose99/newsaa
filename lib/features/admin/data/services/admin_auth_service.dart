import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthService {
  static final AdminAuthService _instance = AdminAuthService._internal();
  final _supabase = Supabase.instance.client;

  factory AdminAuthService() {
    return _instance;
  }

  AdminAuthService._internal();

  User? get currentUser => _supabase.auth.currentUser;

  Future<bool> loginAdmin(String username, String password) async {
    try {
      String emailToUse = username;
      if (username.trim() == 'admin') {
        emailToUse = 'admin@prophet-mohammed.com';
      }

      await _supabase.auth.signInWithPassword(
        email: emailToUse,
        password: password,
      );

      if (_supabase.auth.currentUser != null) {
        final userId = _supabase.auth.currentUser!.id;

        try {
          final response = await _supabase
              .from('admins')
              .select()
              .eq('id', userId)
              .single();

          if (response['isAdmin'] == true) {
            return true;
          }
        } catch (e) {
          return false;
        }
      }

      await _supabase.auth.signOut();
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<bool> isAdminLoggedIn() async {
    if (_supabase.auth.currentUser != null) {
      try {
        final response = await _supabase
            .from('admins')
            .select()
            .eq('id', _supabase.auth.currentUser!.id)
            .single();
        return response['isAdmin'] == true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
