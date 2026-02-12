
-- Enable RLS on storage.objects (usually enabled, but good to ensure)
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy: Allow Public Read Access to 'files', 'sounds', 'videos' buckets
DROP POLICY IF EXISTS "Public Read Access" ON storage.objects;
CREATE POLICY "Public Read Access"
ON storage.objects FOR SELECT
USING ( bucket_id IN ('files', 'sounds', 'videos') );

-- Policy: Allow Authenticated Users (Admins) to Upload/Insert
DROP POLICY IF EXISTS "Authenticated Insert Access" ON storage.objects;
CREATE POLICY "Authenticated Insert Access"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id IN ('files', 'sounds', 'videos')
);

-- Policy: Allow Authenticated Users (Admins) to Update
DROP POLICY IF EXISTS "Authenticated Update Access" ON storage.objects;
CREATE POLICY "Authenticated Update Access"
ON storage.objects FOR UPDATE
USING (
  auth.role() = 'authenticated' AND
  bucket_id IN ('files', 'sounds', 'videos')
);

-- Policy: Allow Authenticated Users (Admins) to Delete
DROP POLICY IF EXISTS "Authenticated Delete Access" ON storage.objects;
CREATE POLICY "Authenticated Delete Access"
ON storage.objects FOR DELETE
USING (
  auth.role() = 'authenticated' AND
  bucket_id IN ('files', 'sounds', 'videos')
);
