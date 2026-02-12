import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://mcmgbsxzdakqxjkrjlex.supabase.co',
    Platform.environment['SUPABASE_KEY'] ?? '',
  );

  try {
    final response = await supabase.from('virtues').select('*');
    print('Total virtues: ${response.length}');
    for (final v in response) {
      print('---');
      print('ID: ${v['id']}');
      print('Title: ${v['title']}');
      print('Type: ${v['type']}');
      print('URL: ${v['url']}');
      print('File Path (Remote): ${v['file_path']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
