# ⚠️ URGENT: Setup Supabase Tables Now

## Problem Found

Your app is failing because:
1. ❌ **The `profiles` table doesn't exist in Supabase** 
2. ❌ **Email confirmation is enabled** (preventing login)

## Error in Logs:
```
PostgrestException: Could not find the table 'public.profiles' in the schema cache
AuthApiException: Email not confirmed
```

---

## ✅ Solution: 3 Steps

### Step 1: Create the `profiles` Table in Supabase

1. **Open your Supabase Dashboard**: https://supabase.com/dashboard
2. **Select your project**
3. **Go to SQL Editor** (left sidebar)
4. **Click "New Query"**
5. **Copy and paste the entire content** from `SUPABASE_PROFILES_TABLE.sql`
6. **Click "Run"** or press `Ctrl+Enter`

You should see: ✅ "Success. No rows returned"

### Step 2: Disable Email Confirmation (For Development)

1. **In Supabase Dashboard**, go to **Authentication** → **Providers**
2. **Click on Email** provider
3. Scroll down to **"Confirm email"**
4. **Toggle OFF** "Confirm email"
5. **Save**

OR

### Step 2 Alternative: Confirm Your Test Emails

1. **Sign up with a test email**
2. **Check your email inbox** for confirmation link
3. **Click the confirmation link**
4. **Now you can login**

---

### Step 3: Test Login Again

1. **Hot restart your app** (Press `R` in the terminal)
2. **Try to login** with the email you signed up with
3. ✅ **Should work now!**

---

## Quick SQL Script to Copy

Open Supabase SQL Editor and run this:

```sql
-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  area TEXT NOT NULL,
  land_amount DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to manage their own profile
CREATE POLICY "Users can manage own profile" 
ON public.profiles 
FOR ALL 
USING (auth.uid() = user_id) 
WITH CHECK (auth.uid() = user_id);

-- Create index
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at 
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## Why This Happens

- **SQLite (local)** tables are created automatically by the app ✅
- **Supabase (cloud)** tables must be created manually using SQL ❌
- The app saves data locally but fails to sync with Supabase

---

## After Setup

Once you create the table and disable email confirmation:

1. **Sign up** → Will save to both local DB and Supabase
2. **Create profile** → Will save to both local DB and Supabase `profiles` table
3. **Login** → Will check if profile exists and redirect accordingly

---

## Need Help?

If you still have issues:
1. Check Supabase logs: Dashboard → Logs
2. Verify table exists: Dashboard → Table Editor → profiles
3. Check authentication users: Dashboard → Authentication → Users
