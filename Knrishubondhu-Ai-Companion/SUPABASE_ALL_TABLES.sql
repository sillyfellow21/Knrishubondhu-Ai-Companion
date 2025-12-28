-- ============================================================================
-- KRISHIBONDHU AI - SUPABASE DATABASE SCHEMA
-- ============================================================================
-- 
-- This file contains ALL the database tables needed for KrishiBondhu AI app
-- to work properly with Supabase.
--
-- INSTRUCTIONS:
-- 1. Go to your Supabase Dashboard (https://supabase.com/dashboard)
-- 2. Select your project
-- 3. Click on "SQL Editor" in the left sidebar
-- 4. Click "New Query"
-- 5. Copy and paste this ENTIRE file
-- 6. Click "Run" or press Ctrl+Enter
-- 7. You should see "Success. No rows returned" for each table
--
-- TABLES THAT WILL BE CREATED:
-- 1. profiles       - User profile information (you may already have this)
-- 2. lands          - Land/farm information
-- 3. loans          - Loan tracking
-- 4. forum_posts    - Community forum posts
-- 5. chat_history   - AI chat history (optional - for sync)
--
-- ============================================================================


-- ============================================================================
-- ENABLE UUID EXTENSION (Required for UUID generation)
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ============================================================================
-- TABLE 1: PROFILES (User profiles)
-- ============================================================================
-- This table stores additional user information after signup
-- Note: If you already have this table, this will skip creation
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    area TEXT NOT NULL,
    land_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.profiles;

-- Create RLS Policies for profiles
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile"
    ON public.profiles FOR DELETE
    USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);


-- ============================================================================
-- TABLE 2: LANDS (Farm/Land information)
-- ============================================================================
-- This table stores information about user's agricultural lands
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.lands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    area DECIMAL(10, 2) NOT NULL DEFAULT 0,
    soil_type TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.lands ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own lands" ON public.lands;
DROP POLICY IF EXISTS "Users can insert own lands" ON public.lands;
DROP POLICY IF EXISTS "Users can update own lands" ON public.lands;
DROP POLICY IF EXISTS "Users can delete own lands" ON public.lands;

-- Create RLS Policies for lands
CREATE POLICY "Users can view own lands"
    ON public.lands FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lands"
    ON public.lands FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lands"
    ON public.lands FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own lands"
    ON public.lands FOR DELETE
    USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_lands_user_id ON public.lands(user_id);


-- ============================================================================
-- TABLE 3: LOANS (Loan tracking)
-- ============================================================================
-- This table stores loan information for farmers
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lender_name TEXT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    paid_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
    purpose TEXT NOT NULL,
    loan_date TIMESTAMP WITH TIME ZONE NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'partial', 'paid', 'overdue')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own loans" ON public.loans;
DROP POLICY IF EXISTS "Users can insert own loans" ON public.loans;
DROP POLICY IF EXISTS "Users can update own loans" ON public.loans;
DROP POLICY IF EXISTS "Users can delete own loans" ON public.loans;

-- Create RLS Policies for loans
CREATE POLICY "Users can view own loans"
    ON public.loans FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own loans"
    ON public.loans FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own loans"
    ON public.loans FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own loans"
    ON public.loans FOR DELETE
    USING (auth.uid() = user_id);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_loans_user_id ON public.loans(user_id);
CREATE INDEX IF NOT EXISTS idx_loans_status ON public.loans(status);
CREATE INDEX IF NOT EXISTS idx_loans_loan_date ON public.loans(loan_date);


-- ============================================================================
-- TABLE 4: FORUM_POSTS (Community forum)
-- ============================================================================
-- This table stores forum posts for community discussions
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.forum_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Anyone can view forum posts" ON public.forum_posts;
DROP POLICY IF EXISTS "Users can create forum posts" ON public.forum_posts;
DROP POLICY IF EXISTS "Users can update own forum posts" ON public.forum_posts;
DROP POLICY IF EXISTS "Users can delete own forum posts" ON public.forum_posts;

-- Create RLS Policies for forum_posts
-- NOTE: Forum posts are public - anyone can view, but only owners can edit/delete
CREATE POLICY "Anyone can view forum posts"
    ON public.forum_posts FOR SELECT
    USING (true);

CREATE POLICY "Users can create forum posts"
    ON public.forum_posts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own forum posts"
    ON public.forum_posts FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own forum posts"
    ON public.forum_posts FOR DELETE
    USING (auth.uid() = user_id);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_forum_posts_user_id ON public.forum_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_created_at ON public.forum_posts(created_at DESC);


-- ============================================================================
-- TABLE 5: FORUM_COMMENTS (Comments on forum posts)
-- ============================================================================
-- This table stores comments for forum posts
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.forum_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES public.forum_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Anyone can view forum comments" ON public.forum_comments;
DROP POLICY IF EXISTS "Users can create forum comments" ON public.forum_comments;
DROP POLICY IF EXISTS "Users can update own forum comments" ON public.forum_comments;
DROP POLICY IF EXISTS "Users can delete own forum comments" ON public.forum_comments;

-- Create RLS Policies for forum_comments
-- NOTE: Comments are public - anyone can view, but only owners can edit/delete
CREATE POLICY "Anyone can view forum comments"
    ON public.forum_comments FOR SELECT
    USING (true);

CREATE POLICY "Users can create forum comments"
    ON public.forum_comments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own forum comments"
    ON public.forum_comments FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own forum comments"
    ON public.forum_comments FOR DELETE
    USING (auth.uid() = user_id);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_forum_comments_post_id ON public.forum_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_forum_comments_user_id ON public.forum_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_forum_comments_created_at ON public.forum_comments(created_at DESC);


-- ============================================================================
-- TABLE 6: CHAT_HISTORY (AI Chat history - Optional for cloud sync)
-- ============================================================================
-- This table stores chat history with AI for backup/sync purposes
-- The app primarily uses local SQLite storage, this is for cloud backup
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.chat_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id TEXT NOT NULL,
    message TEXT NOT NULL,
    sender TEXT NOT NULL CHECK (sender IN ('user', 'ai')),
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image')),
    metadata TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own chat history" ON public.chat_history;
DROP POLICY IF EXISTS "Users can insert own chat messages" ON public.chat_history;
DROP POLICY IF EXISTS "Users can delete own chat history" ON public.chat_history;

-- Create RLS Policies for chat_history
CREATE POLICY "Users can view own chat history"
    ON public.chat_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat messages"
    ON public.chat_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat history"
    ON public.chat_history FOR DELETE
    USING (auth.uid() = user_id);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_chat_history_user_id ON public.chat_history(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_session_id ON public.chat_history(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_created_at ON public.chat_history(created_at DESC);


-- ============================================================================
-- TRIGGER FUNCTION: Auto-update 'updated_at' timestamp
-- ============================================================================
-- This function automatically updates the 'updated_at' column when a row is modified
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- CREATE TRIGGERS FOR AUTO-UPDATE OF 'updated_at'
-- ============================================================================

-- Profiles trigger
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Lands trigger
DROP TRIGGER IF EXISTS update_lands_updated_at ON public.lands;
CREATE TRIGGER update_lands_updated_at
    BEFORE UPDATE ON public.lands
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Loans trigger
DROP TRIGGER IF EXISTS update_loans_updated_at ON public.loans;
CREATE TRIGGER update_loans_updated_at
    BEFORE UPDATE ON public.loans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Forum posts trigger
DROP TRIGGER IF EXISTS update_forum_posts_updated_at ON public.forum_posts;
CREATE TRIGGER update_forum_posts_updated_at
    BEFORE UPDATE ON public.forum_posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Forum comments trigger
DROP TRIGGER IF EXISTS update_forum_comments_updated_at ON public.forum_comments;
CREATE TRIGGER update_forum_comments_updated_at
    BEFORE UPDATE ON public.forum_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================
-- Run this query after creating tables to verify everything is set up correctly
-- ============================================================================

SELECT 
    table_name,
    CASE WHEN table_name IS NOT NULL THEN '✅ Created' ELSE '❌ Missing' END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'lands', 'loans', 'forum_posts', 'forum_comments', 'chat_history')
ORDER BY table_name;


-- ============================================================================
-- DONE! 
-- ============================================================================
-- 
-- After running this script, you should see 6 tables created:
-- ✅ profiles
-- ✅ lands
-- ✅ loans
-- ✅ forum_posts
-- ✅ forum_comments
-- ✅ chat_history
--
-- Each table has:
-- - Row Level Security (RLS) enabled
-- - Policies for user data isolation
-- - Indexes for performance
-- - Auto-update triggers for 'updated_at' column
--
-- ============================================================================
