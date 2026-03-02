-- Drop existing policies and create simpler ones
DROP POLICY IF EXISTS "Users can upload own task images" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own task images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own task images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own task images" ON storage.objects;
DROP POLICY IF EXISTS "Task images are publicly accessible" ON storage.objects;

-- Simple upload policy - allow authenticated users to upload to task-images
CREATE POLICY "Users can upload own task images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'task-images' AND 
    auth.role() = 'authenticated'
  );

-- Simple view policy - allow users to view their own images
CREATE POLICY "Users can view own task images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'task-images' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Simple update policy
CREATE POLICY "Users can update own task images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'task-images' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Simple delete policy
CREATE POLICY "Users can delete own task images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'task-images' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Make task-images bucket public for viewing
CREATE POLICY "Task images are publicly accessible" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'task-images'
  );
