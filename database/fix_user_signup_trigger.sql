-- Fix User Signup Trigger
-- Run this in your Supabase SQL Editor to ensure users are stored in database

-- 1. Check if the trigger and function exist
SELECT 'Checking existing trigger...' as status;
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

SELECT 'Checking existing function...' as status;
SELECT * FROM pg_proc WHERE proname = 'handle_new_user';

-- 2. Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 3. Recreate the function with location support and proper null handling
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, phone, location, bio, avatar_url)
  VALUES (
    new.id, 
    new.email, 
    COALESCE(new.raw_user_meta_data->>'name', 'User'),
    COALESCE(new.raw_user_meta_data->>'phone', NULL),
    COALESCE(new.raw_user_meta_data->>'location', NULL),
    COALESCE(new.raw_user_meta_data->>'bio', NULL),
    COALESCE(new.raw_user_meta_data->>'avatar_url', NULL)
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 5. Test the function (optional - you can comment this out)
-- SELECT public.handle_new_user();

-- 6. Verify the setup
SELECT 'Trigger and function created successfully!' as status;
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
SELECT proname, prosrc FROM pg_proc WHERE proname = 'handle_new_user';

-- 7. Check existing users that might not have profiles
SELECT 'Checking users without profiles...' as status;
SELECT 
  au.id,
  au.email,
  au.created_at,
  CASE WHEN p.id IS NULL THEN 'MISSING PROFILE' ELSE 'HAS PROFILE' END as profile_status
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE au.email_confirmed_at IS NOT NULL
ORDER BY au.created_at DESC;

-- 8. Optional: Create profiles for existing users who don't have them
-- Uncomment this section if you want to fix existing users
/*
INSERT INTO public.profiles (id, email, name, phone, location, bio, avatar_url)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'name', 'User'),
  COALESCE(au.raw_user_meta_data->>'phone', NULL),
  COALESCE(au.raw_user_meta_data->>'location', NULL),
  COALESCE(au.raw_user_meta_data->>'bio', NULL),
  COALESCE(au.raw_user_meta_data->>'avatar_url', NULL)
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE au.email_confirmed_at IS NOT NULL 
  AND p.id IS NULL;
*/
