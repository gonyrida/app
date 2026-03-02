-- Storage policies for avatars bucket
-- Run these in the SQL Editor after creating the bucket

-- Users can upload their own avatars
CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Users can view their own avatars
CREATE POLICY "Users can view own avatar" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'avatars' AND 
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Users can update their own avatars
CREATE POLICY "Users can update own avatar" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars' AND 
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Users can delete their own avatars
CREATE POLICY "Users can delete own avatar" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'avatars' AND 
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Make avatars bucket public for viewing
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'avatars'
  );

-- Storage policies for task-images bucket
-- Run these in the SQL Editor after creating the bucket

-- Users can upload their own task images
CREATE POLICY "Users can upload own task images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'task-images' AND 
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Users can view their own task images
CREATE POLICY "Users can view own task images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'task-images' AND 
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Users can update their own task images
CREATE POLICY "Users can update own task images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'task-images' AND 
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Users can delete their own task images
CREATE POLICY "Users can delete own task images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'task-images' AND 
    (storage.foldername(name))[1]::text = auth.uid()::text
  );

-- Make task-images bucket public for viewing
CREATE POLICY "Task images are publicly accessible" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'task-images'
  );
