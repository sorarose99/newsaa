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
  print('Setting up admin write policies for content tables...\n');

  try {
    final policies = [
      // Virtues table - allow authenticated users to insert/update/delete
      '''
      CREATE POLICY "Allow authenticated insert virtues"
      ON public.virtues FOR INSERT
      TO authenticated
      WITH CHECK (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated update virtues"
      ON public.virtues FOR UPDATE
      TO authenticated
      USING (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated delete virtues"
      ON public.virtues FOR DELETE
      TO authenticated
      USING (true);
      ''',

      // Prayer formulas - allow authenticated users to insert/update/delete
      '''
      CREATE POLICY "Allow authenticated insert prayer_formulas"
      ON public.prayer_formulas FOR INSERT
      TO authenticated
      WITH CHECK (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated update prayer_formulas"
      ON public.prayer_formulas FOR UPDATE
      TO authenticated
      USING (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated delete prayer_formulas"
      ON public.prayer_formulas FOR DELETE
      TO authenticated
      USING (true);
      ''',

      // Evidence - allow authenticated users to insert/update/delete
      '''
      CREATE POLICY "Allow authenticated insert evidence"
      ON public.evidence FOR INSERT
      TO authenticated
      WITH CHECK (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated update evidence"
      ON public.evidence FOR UPDATE
      TO authenticated
      USING (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated delete evidence"
      ON public.evidence FOR DELETE
      TO authenticated
      USING (true);
      ''',

      // Hadith - allow authenticated users to insert/update/delete
      '''
      CREATE POLICY "Allow authenticated insert hadith"
      ON public.hadith FOR INSERT
      TO authenticated
      WITH CHECK (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated update hadith"
      ON public.hadith FOR UPDATE
      TO authenticated
      USING (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated delete hadith"
      ON public.hadith FOR DELETE
      TO authenticated
      USING (true);
      ''',

      // Media - allow authenticated users to insert/update/delete
      '''
      CREATE POLICY "Allow authenticated insert media"
      ON public.media FOR INSERT
      TO authenticated
      WITH CHECK (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated update media"
      ON public.media FOR UPDATE
      TO authenticated
      USING (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated delete media"
      ON public.media FOR DELETE
      TO authenticated
      USING (true);
      ''',

      // Sounds - allow authenticated users to insert/update/delete
      '''
      CREATE POLICY "Allow authenticated insert sounds"
      ON public.sounds FOR INSERT
      TO authenticated
      WITH CHECK (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated update sounds"
      ON public.sounds FOR UPDATE
      TO authenticated
      USING (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated delete sounds"
      ON public.sounds FOR DELETE
      TO authenticated
      USING (true);
      ''',

      // Prayer Formula Sounds - allow authenticated users to insert/update/delete
      '''
      CREATE POLICY "Allow authenticated insert prayerFormulaSounds"
      ON public."prayerFormulaSounds" FOR INSERT
      TO authenticated
      WITH CHECK (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated update prayerFormulaSounds"
      ON public."prayerFormulaSounds" FOR UPDATE
      TO authenticated
      USING (true);
      ''',

      '''
      CREATE POLICY "Allow authenticated delete prayerFormulaSounds"
      ON public."prayerFormulaSounds" FOR DELETE
      TO authenticated
      USING (true);
      ''',
    ];

    for (var i = 0; i < policies.length; i++) {
      try {
        await connection.execute(policies[i]);
        print('✓ Policy ${i + 1}/${policies.length} created');
      } catch (e) {
        if (e.toString().contains('already exists')) {
          print('⊙ Policy ${i + 1}/${policies.length} already exists');
        } else {
          print('✗ Policy ${i + 1}/${policies.length} failed: $e');
        }
      }
    }

    print('\n✅ Admin write policies configured!');
    print('\nAuthenticated users (admins) can now:');
    print('  • Create, update, and delete virtues');
    print('  • Create, update, and delete prayer formulas');
    print('  • Create, update, and delete evidence');
    print('  • Create, update, and delete hadith');
    print('  • Create, update, and delete media');
    print('  • Create, update, and delete sounds');
    print('  • Create, update, and delete prayer formula sounds');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    await connection.close();
    print('\nConnection closed.');
  }
}
