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
  print('Setting up storage bucket policies...\n');

  try {
    // Create storage policies for authenticated users (admins)
    final policies = [
      // Allow authenticated users to upload to virtues bucket
      '''
      CREATE POLICY "Allow authenticated uploads to virtues"
      ON storage.objects FOR INSERT
      TO authenticated
      WITH CHECK (bucket_id = 'virtues');
      ''',

      // Allow authenticated users to update in virtues bucket
      '''
      CREATE POLICY "Allow authenticated updates to virtues"
      ON storage.objects FOR UPDATE
      TO authenticated
      USING (bucket_id = 'virtues');
      ''',

      // Allow authenticated users to delete from virtues bucket
      '''
      CREATE POLICY "Allow authenticated deletes from virtues"
      ON storage.objects FOR DELETE
      TO authenticated
      USING (bucket_id = 'virtues');
      ''',

      // Allow authenticated users to upload to sounds bucket
      '''
      CREATE POLICY "Allow authenticated uploads to sounds"
      ON storage.objects FOR INSERT
      TO authenticated
      WITH CHECK (bucket_id = 'sounds');
      ''',

      // Allow authenticated users to update in sounds bucket
      '''
      CREATE POLICY "Allow authenticated updates to sounds"
      ON storage.objects FOR UPDATE
      TO authenticated
      USING (bucket_id = 'sounds');
      ''',

      // Allow authenticated users to delete from sounds bucket
      '''
      CREATE POLICY "Allow authenticated deletes from sounds"
      ON storage.objects FOR DELETE
      TO authenticated
      USING (bucket_id = 'sounds');
      ''',

      // Allow authenticated users to upload to files bucket
      '''
      CREATE POLICY "Allow authenticated uploads to files"
      ON storage.objects FOR INSERT
      TO authenticated
      WITH CHECK (bucket_id = 'files');
      ''',

      // Allow authenticated users to update in files bucket
      '''
      CREATE POLICY "Allow authenticated updates to files"
      ON storage.objects FOR UPDATE
      TO authenticated
      USING (bucket_id = 'files');
      ''',

      // Allow authenticated users to delete from files bucket
      '''
      CREATE POLICY "Allow authenticated deletes from files"
      ON storage.objects FOR DELETE
      TO authenticated
      USING (bucket_id = 'files');
      ''',

      // Allow authenticated users to upload to videos bucket
      '''
      CREATE POLICY "Allow authenticated uploads to videos"
      ON storage.objects FOR INSERT
      TO authenticated
      WITH CHECK (bucket_id = 'videos');
      ''',

      // Allow authenticated users to update in videos bucket
      '''
      CREATE POLICY "Allow authenticated updates to videos"
      ON storage.objects FOR UPDATE
      TO authenticated
      USING (bucket_id = 'videos');
      ''',

      // Allow authenticated users to delete from videos bucket
      '''
      CREATE POLICY "Allow authenticated deletes from videos"
      ON storage.objects FOR DELETE
      TO authenticated
      USING (bucket_id = 'videos');
      ''',

      // Allow public read access to all buckets
      '''
      CREATE POLICY "Allow public reads"
      ON storage.objects FOR SELECT
      TO public
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

    print('\n✅ Storage policies configured!');
    print('\nAdmins can now:');
    print('  • Upload images to virtues bucket');
    print('  • Upload audio to sounds bucket');
    print('  • Upload any files to files bucket');
    print('  • Update and delete their uploads');
    print('  • All files are publicly readable');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    await connection.close();
    print('\nConnection closed.');
  }
}
