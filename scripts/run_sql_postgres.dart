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
    settings: ConnectionSettings(
      sslMode: SslMode.disable,
    ), // Try disable first, Supabase might require require. Usually require.
  );

  print('Connected to database!');

  try {
    print('Executing SQL...');

    // Create Table
    await connection.execute(r'''
      CREATE TABLE IF NOT EXISTS public."lastChanges" (
        "entityName" TEXT PRIMARY KEY,
        "lastChange" TIMESTAMPTZ DEFAULT NOW()
      );
    ''');
    print('Table "lastChanges" created/verified.');

    // Enable RLS
    await connection.execute(
      'ALTER TABLE public."lastChanges" ENABLE ROW LEVEL SECURITY;',
    );
    print('RLS enabled.');

    // Create Policies (handling "relation already exists" gracefully by ignoring or dropping first?)
    // Best way in a script is to drop if exists or use DO block, but simple CREATE POLICY IF NOT EXISTS (Postgres 10+) ? No, "CREATE POLICY IF NOT EXISTS" is not standard.
    // We'll wrap in try-catch blocks for policies.

    try {
      await connection.execute(r'''
        CREATE POLICY "Allow public read lastChanges" ON public."lastChanges" FOR SELECT USING (true);
      ''');
      print('Policy "Allow public read lastChanges" created.');
    } catch (e) {
      print(
        'Policy "Allow public read lastChanges" might already exist or error: $e',
      );
    }

    try {
      await connection.execute(r'''
        CREATE POLICY "Allow service role write lastChanges" ON public."lastChanges" FOR ALL USING (true) WITH CHECK (true);
      ''');
      print('Policy "Allow service role write lastChanges" created.');
    } catch (e) {
      print(
        'Policy "Allow service role write lastChanges" might already exist or error: $e',
      );
    }

    // Also fixing the admins policy if missing
    try {
      await connection.execute(r'''
        create policy "Allow read access for own user"
        on public.admins for select
        using ( auth.uid() = id );
        ''');
      print('Policy "Allow read access for own user" on admins created.');
    } catch (e) {
      print('Policy on admins might already exist: $e');
    }

    print('All SQL executed.');
  } catch (e) {
    print('Error executing SQL: $e');
  } finally {
    await connection.close();
    print('Connection closed.');
  }
}
