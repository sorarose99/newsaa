import 'dart:io';
import 'package:supabase/supabase.dart';

// CONFIGURATION
// Project URL
const _projectUrl = 'https://mcmgbsxzdakqxjkrjlex.supabase.co';
// SERVICE ROLE KEY - HAS FULL ACCESS
const _serviceKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jbWdic3h6ZGFrcXhqa3JqbGV4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDQ4NDUzMCwiZXhwIjoyMDg2MDYwNTMwfQ.mFsCvFxd3JmAGxx758KQky1b-ip2KGRxSLblc1PF9fs';

void main(List<String> args) async {
  print('Initializing Supabase Client with Service Role Key...');
  final client = SupabaseClient(_projectUrl, _serviceKey);

  if (args.isEmpty) {
    print('Usage: dart run scripts/supabase_admin.dart <command> [args]');
    print('Commands:');
    print('  list_users');
    print('  create_user <email> <password>');
    print('  update_password <uid> <new_password>');
    print('  delete_user <uid>');
    print('  make_admin <uid>');
    print('  query <table>');
    exit(1);
  }

  final command = args[0];

  try {
    switch (command) {
      case 'list_users':
        await _listUsers(client);
        break;
      case 'create_user':
        if (args.length < 3) throw 'Missing email or password';
        await _createUser(client, args[1], args[2]);
        break;
      case 'update_password':
        if (args.length < 3) throw 'Missing UID or new password';
        await _updatePassword(client, args[1], args[2]);
        break;
      case 'delete_user':
        if (args.length < 2) throw 'Missing UID';
        await _deleteUser(client, args[1]);
        break;
      case 'make_admin':
        if (args.length < 2) throw 'Missing UID';
        await _makeAdmin(client, args[1]);
        break;
      case 'query':
        if (args.length < 2) throw 'Missing table name';
        await _queryTable(client, args[1]);
        break;
      default:
        print('Unknown command: $command');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    exit(0);
  }
}

Future<void> _listUsers(SupabaseClient client) async {
  try {
    final response = await client.auth.admin.listUsers();
    print('Found ${response.length} users:');
    for (final user in response) {
      print('- ${user.id} (${user.email ?? "No Email"})');
    }
  } catch (e) {
    print('Failed to list users: $e');
  }
}

Future<void> _createUser(
  SupabaseClient client,
  String email,
  String password,
) async {
  try {
    final response = await client.auth.admin.createUser(
      AdminUserAttributes(email: email, password: password, emailConfirm: true),
    );
    print('User created: ${response.user?.id} (${response.user?.email})');
  } catch (e) {
    print('Failed to create user: $e');
  }
}

Future<void> _updatePassword(
  SupabaseClient client,
  String uid,
  String newPassword,
) async {
  try {
    final response = await client.auth.admin.updateUserById(
      uid,
      attributes: AdminUserAttributes(password: newPassword),
    );
    print('Password updated for user: ${response.user?.id}');
  } catch (e) {
    print('Failed to update password: $e');
  }
}

Future<void> _deleteUser(SupabaseClient client, String uid) async {
  try {
    await client.auth.admin.deleteUser(uid);
    print('User $uid deleted.');
  } catch (e) {
    print('Failed to delete user: $e');
  }
}

Future<void> _makeAdmin(SupabaseClient client, String uid) async {
  try {
    // 1. Update metadata if needed (optional)
    // 2. Insert into admins table
    await client.from('admins').upsert({'id': uid, 'isAdmin': true});
    print('User $uid is now an admin locally.');
  } catch (e) {
    print('Failed to set admin: $e');
  }
}

Future<void> _queryTable(SupabaseClient client, String table) async {
  try {
    final data = await client.from(table).select().limit(10);
    print('Data from $table:');
    print(data);
  } catch (e) {
    print('Query failed: $e');
  }
}
