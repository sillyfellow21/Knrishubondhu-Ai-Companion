# 📘 Complete Supabase Setup Guide - Step by Step

## 🎯 Overview
This guide will walk you through setting up all database tables in Supabase. Takes about 5-7 minutes.

---

## 📋 What You'll Create

1. ✅ **profiles** - User profile information
2. ✅ **lands** - Agricultural land records
3. ✅ **loans** - Loan tracking
4. ✅ **chat_history** - AI chatbot conversation history
5. ✅ **forum_posts** - Community forum posts

---

## 🚀 Step-by-Step Instructions

### Step 1: Login to Supabase Dashboard

1. Open your browser and go to: **https://supabase.com/dashboard**
2. Click **"Sign In"**
3. Enter your credentials

### Step 2: Select Your Project

1. After login, you'll see a list of your projects
2. Click on the project with ID: **mifwuugvljzhbuavhnbf**
   - Project Name: (whatever name you gave it)
   - Project URL: https://mifwuugvljzhbuavhnbf.supabase.co

### Step 3: Open SQL Editor

1. Look at the left sidebar of your Supabase dashboard
2. Click on **"SQL Editor"** (it has a `</>` icon)
3. You'll see a button **"New Query"** at the top right
4. Click **"New Query"**

---

## 📝 Execute SQL Queries (In Order)

### Query 1: Create Profiles Table

**What it does**: Stores user profile information (name, area, land amount)

**How to execute**:

1. In the SQL Editor, you'll see a blank text area
2. Open file: `C:\KrishiBondhuAI\SUPABASE_PROFILES_TABLE.sql`
3. Copy ALL the content from that file (Ctrl+A, Ctrl+C)
4. Paste it into the Supabase SQL Editor
5. Click the **"RUN"** button (or press Ctrl+Enter)
6. ✅ You should see: **"Success. No rows returned"**

**What you just created**:
- Table: `profiles`
- Columns: id, user_id, full_name, area, land_amount, created_at, updated_at
- RLS policies: Users can only access their own profile
- Auto-update trigger: `updated_at` changes automatically

---

### Query 2: Create Lands Table

**What it does**: Stores agricultural land information

**How to execute**:

1. Click **"New Query"** again (top right)
2. Copy this SQL and paste into the editor:

```sql
-- Create Lands Table
CREATE TABLE IF NOT EXISTS public.lands (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  location TEXT,
  area_in_acres DECIMAL(10, 2),
  soil_type TEXT,
  latitude DECIMAL(10, 6),
  longitude DECIMAL(10, 6),
  crops TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.lands ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own lands"
  ON public.lands FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lands"
  ON public.lands FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lands"
  ON public.lands FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own lands"
  ON public.lands FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX idx_lands_user_id ON public.lands(user_id);

-- Auto-update trigger
CREATE TRIGGER update_lands_updated_at 
  BEFORE UPDATE ON public.lands
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
```

3. Click **"RUN"**
4. ✅ You should see: **"Success. No rows returned"**

---

### Query 3: Create Loans Table

**What it does**: Tracks agricultural loans and payments

**How to execute**:

1. Click **"New Query"**
2. Copy and paste this SQL:

```sql
-- Create Loans Table
CREATE TABLE IF NOT EXISTS public.loans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lender_name TEXT NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  paid_amount DECIMAL(15, 2) DEFAULT 0,
  purpose TEXT,
  loan_date TIMESTAMP WITH TIME ZONE NOT NULL,
  due_date TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own loans"
  ON public.loans FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own loans"
  ON public.loans FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own loans"
  ON public.loans FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own loans"
  ON public.loans FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_loans_user_id ON public.loans(user_id);

-- Auto-update trigger
CREATE TRIGGER update_loans_updated_at 
  BEFORE UPDATE ON public.loans
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
```

3. Click **"RUN"**
4. ✅ Success message should appear

---

### Query 4: Create Chat History Table

**What it does**: Stores AI chatbot conversations

**How to execute**:

1. Click **"New Query"**
2. Copy and paste this SQL:

```sql
-- Create Chat History Table
CREATE TABLE IF NOT EXISTS public.chat_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  response TEXT NOT NULL,
  image_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own chat history"
  ON public.chat_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat history"
  ON public.chat_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat history"
  ON public.chat_history FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_chat_history_user_id ON public.chat_history(user_id);
CREATE INDEX idx_chat_history_created_at ON public.chat_history(created_at DESC);
```

3. Click **"RUN"**
4. ✅ Success message should appear

---

### Query 5: Create Forum Posts Table

**What it does**: Stores community forum discussions

**How to execute**:

1. Click **"New Query"**
2. Copy and paste this SQL:

```sql
-- Create Forum Posts Table
CREATE TABLE IF NOT EXISTS public.forum_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies (public read, authenticated write)
CREATE POLICY "Anyone can view forum posts"
  ON public.forum_posts FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert posts"
  ON public.forum_posts FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own posts"
  ON public.forum_posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
  ON public.forum_posts FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_forum_posts_user_id ON public.forum_posts(user_id);
CREATE INDEX idx_forum_posts_created_at ON public.forum_posts(created_at DESC);

-- Auto-update trigger
CREATE TRIGGER update_forum_posts_updated_at 
  BEFORE UPDATE ON public.forum_posts
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
```

3. Click **"RUN"**
4. ✅ Success message should appear

---

## ✅ Verify Everything is Set Up

### Method 1: Check via Table Editor

1. In left sidebar, click **"Table Editor"**
2. You should see all these tables:
   - ✅ profiles
   - ✅ lands
   - ✅ loans
   - ✅ chat_history
   - ✅ forum_posts
3. Click on each table to see its structure (columns)

### Method 2: Run Verification Query

1. Go back to **SQL Editor**
2. Click **"New Query"**
3. Copy and paste:

```sql
-- Verify all tables exist
SELECT 
  tablename,
  schemaname
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'lands', 'loans', 'chat_history', 'forum_posts')
ORDER BY tablename;
```

4. Click **"RUN"**
5. ✅ You should see 5 rows returned with all table names

---

## 🔐 Verify RLS Policies

1. In SQL Editor, run:

```sql
-- Check RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

2. ✅ You should see multiple policies for each table

---

## 🎉 Success Indicators

After completing all steps, you should have:

✅ **5 tables created**:
- profiles (user data)
- lands (agricultural lands)
- loans (loan tracking)
- chat_history (AI conversations)
- forum_posts (community posts)

✅ **Row Level Security enabled** on all tables

✅ **RLS Policies configured**:
- Users can only see/edit their own data
- Forum posts are publicly readable
- Auto-update triggers working

✅ **Indexes created** for better performance

---

## 🚨 Troubleshooting

### Error: "relation already exists"

**Solution**: Table already exists! You can skip that query.

### Error: "function update_updated_at_column does not exist"

**Solution**: 
1. Go back and run **Query 1 (SUPABASE_PROFILES_TABLE.sql)** first
2. This creates the trigger function needed by other tables

### Error: "permission denied for table"

**Solution**: 
1. Make sure you're logged in as the project owner
2. Check project settings → Database → Connection pooling is enabled

### Can't see tables in Table Editor

**Solution**:
1. Refresh the page (F5)
2. Check you're looking at the correct project
3. Try running the verification query in SQL Editor

---

## 📱 Next Steps

Now that Supabase is set up, you can:

1. ✅ Run the Flutter app: `flutter run`
2. ✅ Register a new account
3. ✅ Test each feature:
   - Add a land
   - Chat with AI
   - Record a loan
   - Check weather
   - Post in forum

4. ✅ Verify data is syncing:
   - Go to Supabase → Table Editor → lands
   - You should see the land you added in the app

---

## 💾 Saving Your Queries (Optional)

If you want to save these queries in Supabase for future reference:

### Method 1: Save as Snippet

1. After pasting a query in SQL Editor
2. Click the **"Save"** icon (💾) at the top
3. Give it a name like "Setup Profiles Table"
4. It will appear in the left sidebar under "Your queries"

### Method 2: Create Migration File

1. In Supabase dashboard, click **"Database"** in sidebar
2. Click **"Migrations"**
3. Click **"New migration"**
4. Paste your SQL
5. Click **"Run migration"**

**Note**: For this setup, Method 1 (just running queries) is sufficient. Migrations are for version control.

---

## 📊 Expected Database Schema

```
public.profiles
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── full_name (TEXT)
├── area (TEXT)
├── land_amount (DECIMAL)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)

public.lands
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── name (TEXT)
├── location (TEXT)
├── area_in_acres (DECIMAL)
├── soil_type (TEXT)
├── latitude (DECIMAL)
├── longitude (DECIMAL)
├── crops (TEXT)
├── image_url (TEXT)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)

public.loans
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── lender_name (TEXT)
├── amount (DECIMAL)
├── paid_amount (DECIMAL)
├── purpose (TEXT)
├── loan_date (TIMESTAMP)
├── due_date (TIMESTAMP)
├── status (TEXT)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)

public.chat_history
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── message (TEXT)
├── response (TEXT)
├── image_path (TEXT)
└── created_at (TIMESTAMP)

public.forum_posts
├── id (UUID, PK)
├── user_id (UUID, FK → auth.users)
├── title (TEXT)
├── content (TEXT)
├── image_url (TEXT)
├── likes (INTEGER)
├── comments (INTEGER)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)
```

---

## 🎓 Understanding What You Did

### Row Level Security (RLS)
- Ensures users can only access their own data
- Enforced at database level (can't be bypassed)
- More secure than application-level checks

### Foreign Keys
- `user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE`
- Links your tables to Supabase authentication
- `CASCADE` means if user is deleted, their data is deleted too

### Indexes
- `CREATE INDEX idx_lands_user_id ON public.lands(user_id)`
- Makes queries faster when filtering by user_id
- Essential for good performance

### Triggers
- `update_updated_at_column()` automatically updates timestamps
- Runs before every UPDATE operation
- Ensures `updated_at` is always accurate

---

## ✨ You're All Set!

Congratulations! Your Supabase database is fully configured. 

**Total time taken**: ~5-7 minutes  
**Tables created**: 5  
**RLS policies**: 19  
**Status**: ✅ READY FOR PRODUCTION

Now run your Flutter app and start testing! 🚀

---

**Last Updated**: December 26, 2025  
**Guide Version**: 1.0  
**Project**: KrishiBondhu AI
