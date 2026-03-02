# Step 6: Set Up Storage - Detailed Instructions

## Create Storage Bucket

1. Go to your Supabase project dashboard
2. Click **"Storage"** in the sidebar
3. Click **"Create bucket"**
4. Enter bucket name: `avatars`
5. Set bucket as **Public** (optional, but recommended for avatars)
6. Click **"Save"**

## Create Storage Policies

After creating the bucket, you need to set up policies to control who can access the storage.

### Policy Names and Their Purpose:

1. **"Users can upload own avatar"**
   - Purpose: Allows authenticated users to upload their own avatar images
   - Type: INSERT policy
   - Condition: User can only upload to their own folder

2. **"Users can view own avatar"**
   - Purpose: Allows users to view their own avatar images
   - Type: SELECT policy
   - Condition: User can only view their own files

3. **"Users can update own avatar"**
   - Purpose: Allows users to update/replace their avatar images
   - Type: UPDATE policy
   - Condition: User can only update their own files

4. **"Users can delete own avatar"**
   - Purpose: Allows users to delete their own avatar images
   - Type: DELETE policy
   - Condition: User can only delete their own files

5. **"Avatar images are publicly accessible"**
   - Purpose: Makes avatar images publicly viewable (for profile display)
   - Type: SELECT policy
   - Condition: All avatar images in the bucket

## How to Create These Policies:

### Method 1: Using SQL Editor (Recommended)

1. Go to **SQL Editor** in your Supabase dashboard
2. Copy the entire content from `database/storage_policies.sql`
3. Paste it into the SQL Editor
4. Click **"Run"** to execute all policies at once

### Method 2: Using Storage UI

1. Go to **Storage** > **Policies**
2. For each policy:
   - Click **"New Policy"**
   - Select the table: `storage.objects`
   - Choose the policy type (INSERT, SELECT, UPDATE, DELETE)
   - Enter the policy name (from the list above)
   - Add the policy definition (the SQL condition)
   - Click **"Save"**

### Example Policy Creation via UI:

For "Users can upload own avatar":
- Table: `storage.objects`
- Policy name: `Users can upload own avatar`
- Policy definition: `bucket_id = 'avatars' AND auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()`
- Allowed operation: INSERT

## Important Notes:

1. **Folder Structure**: The policies use `(storage.foldername(name))[1] = auth.uid()` which means files should be stored as `users/{user_id}/filename.jpg`

2. **Public Access**: The last policy makes avatars publicly accessible so they can be displayed in profiles without authentication

3. **Testing**: After setting up policies, test by uploading an avatar image to verify the permissions work correctly

## File Path Structure:
When uploading avatars, use this path format:
`users/{user_id}/avatar_{timestamp}.jpg`

Example: `users/12345678-1234-1234-1234-123456789012/avatar_1234567890.jpg`
