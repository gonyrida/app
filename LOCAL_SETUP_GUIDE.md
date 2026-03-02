# Local Development Setup Guide

## Problem
Your app is running on `http://localhost:3000` but Supabase needs to know this is a valid redirect URL.

## Quick Fix (Recommended)

### Option 1: Update Supabase Dashboard (Easiest)
1. Go to: https://supabase.com/dashboard
2. Select your project: `baxdknteexminpprfotv`
3. Navigate to: **Authentication** → **Settings**
4. Scroll to **"Site URL"** and add: `http://localhost:3000`
5. Scroll to **"Redirect URLs"** and add:
   - `http://localhost:3000`
   - `http://localhost:3000/**`
6. Click **Save**

### Option 2: Use .env.local (Advanced)
1. Copy `.env.local` to your main `.env` file
2. Restart your app
3. The local URLs will be configured automatically

## Testing
After setup:
1. Restart your Flutter app: `flutter run`
2. Try signup with a real email (not test@gmail.com)
3. Check Supabase Dashboard → Authentication → Users
4. You should see the new user appear

## Current Status
- ✅ Supabase Connection: Working
- ✅ App Running: http://localhost:3000
- ⚠️  Redirect URLs: Need configuration
- ✅ Authentication Code: Fixed and improved

## Common Issues
- **"email rate limit exceeded"**: Wait 2-3 minutes, then try again
- **"invalid email address"**: Use real email, not test emails
- **Signup not working**: Check Supabase dashboard settings

## Need Help?
1. Check the console output for environment variables
2. Verify your .env file has correct values
3. Make sure Supabase project settings include localhost URLs
