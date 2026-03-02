-- Check existing storage policies
SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';

-- Check if your bucket exists
SELECT * FROM storage.buckets WHERE name = 'task-images';
