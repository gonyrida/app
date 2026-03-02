# Task Images Storage Setup

## Prerequisites
- You have already set up the Supabase project and database schema
- You have run the `supabase_schema.sql` file

## Steps to Set Up Task Images Storage

### 1. Create the Storage Bucket
1. Go to your Supabase project dashboard
2. Navigate to **Storage** section in the left sidebar
3. Click **"New bucket"**
4. Enter bucket name: `task-images`
5. Set bucket to **Public** (for viewing images)
6. Click **"Save"**

### 2. Set Up Storage Policies
1. Go to **SQL Editor** in your Supabase dashboard
2. Copy and run the contents of `database/storage_policies.sql`
3. This will create policies that:
   - Allow authenticated users to upload their own task images
   - Allow users to view their own task images
   - Make task images publicly accessible for viewing

### 3. Verify Setup
1. In Storage section, you should see the `task-images` bucket
2. The bucket should be marked as public
3. Test by uploading an image through the app

## How It Works
- Images are stored in path: `users/{userId}/tasks/{filename}`
- Each user can only access their own images
- Images are publicly viewable but only uploadable by authenticated users
- The app automatically uploads images when creating/updating tasks

## Troubleshooting
- If upload fails, check that the bucket exists and policies are applied
- Ensure the user is authenticated before uploading
- Check browser console for specific error messages
