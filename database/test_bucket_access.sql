-- Test if we can access the task-images bucket
-- This should return no error if bucket exists and policies are correct

-- Try to select from the bucket (should work if policies are correct)
SELECT * FROM storage.objects WHERE bucket_id = 'task-images' LIMIT 1;
