import 'dart:io';
import 'package:postgres/postgres.dart';

void main() async {
  final endpoint = Endpoint(
    host: 'aws-1-ap-south-1.pooler.supabase.com',
    database: 'postgres',
    username: 'postgres.mcmgbsxzdakqxjkrjlex',
    password: 'NOQaEczRLUPRn9RJ',
    port: 5432,
  );

  final connection = await Connection.open(
    endpoint,
    settings: ConnectionSettings(sslMode: SslMode.require),
  );

  print('Connected to database!');
  print('Setting up complete database schema...\n');

  try {
    // Read the init_schema.sql file
    final schemaFile = File(
      'supabase/migrations/20260207221246_init_schema.sql',
    );
    final schemaSQL = await schemaFile.readAsString();

    // Split by semicolons and execute each statement
    final statements = schemaSQL
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !s.startsWith('--'))
        .toList();

    print(
      'Executing ${statements.length} SQL statements from init_schema.sql...',
    );

    for (var i = 0; i < statements.length; i++) {
      final statement = statements[i];
      if (statement.isEmpty) continue;

      try {
        await connection.execute(statement);
        print('✓ Statement ${i + 1}/${statements.length} executed');
      } catch (e) {
        // Ignore "already exists" errors
        if (e.toString().contains('already exists') ||
            e.toString().contains('duplicate key')) {
          print(
            '⊙ Statement ${i + 1}/${statements.length} skipped (already exists)',
          );
        } else {
          print('✗ Statement ${i + 1}/${statements.length} failed: $e');
        }
      }
    }

    print('\n--- Adding lastChanges table ---');

    // Add lastChanges table
    try {
      await connection.execute(r'''
        CREATE TABLE IF NOT EXISTS public."lastChanges" (
          "entityName" TEXT PRIMARY KEY,
          "lastChange" TIMESTAMPTZ DEFAULT NOW()
        );
      ''');
      print('✓ lastChanges table created');
    } catch (e) {
      print('⊙ lastChanges table already exists');
    }

    // Enable RLS on lastChanges
    try {
      await connection.execute(
        'ALTER TABLE public."lastChanges" ENABLE ROW LEVEL SECURITY;',
      );
      print('✓ RLS enabled on lastChanges');
    } catch (e) {
      print('⊙ RLS already enabled on lastChanges');
    }

    // Create policies for lastChanges
    try {
      await connection.execute(r'''
        CREATE POLICY "Allow public read lastChanges" ON public."lastChanges" FOR SELECT USING (true);
      ''');
      print('✓ Read policy created for lastChanges');
    } catch (e) {
      print('⊙ Read policy already exists for lastChanges');
    }

    try {
      await connection.execute(r'''
        CREATE POLICY "Allow service role write lastChanges" ON public."lastChanges" FOR ALL USING (true) WITH CHECK (true);
      ''');
      print('✓ Write policy created for lastChanges');
    } catch (e) {
      print('⊙ Write policy already exists for lastChanges');
    }

    // Create admin read policy
    try {
      await connection.execute(r'''
        CREATE POLICY "Allow read access for own user"
        ON public.admins FOR SELECT
        USING ( auth.uid() = id );
      ''');
      print('✓ Admin read policy created');
    } catch (e) {
      print('⊙ Admin read policy already exists');
    }

    print('\n✅ Database setup complete!');
  } catch (e) {
    print('❌ Error during setup: $e');
  } finally {
    await connection.close();
    print('\nConnection closed.');
  }
}
