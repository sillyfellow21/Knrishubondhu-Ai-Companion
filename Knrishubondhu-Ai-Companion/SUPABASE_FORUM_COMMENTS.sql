-- ============================================================================
-- FORUM COMMENTS TABLE - Run this in Supabase SQL Editor
-- ============================================================================
-- 
-- This adds the forum_comments table if you already have forum_posts table
-- Run this AFTER you have run the SUPABASE_ALL_TABLES.sql or if you only need comments
--
-- ============================================================================

-- Create forum_comments table
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

-- Drop existing policies if any (to avoid conflicts)
DROP POLICY IF EXISTS "Anyone can view forum comments" ON public.forum_comments;
DROP POLICY IF EXISTS "Users can create forum comments" ON public.forum_comments;
DROP POLICY IF EXISTS "Users can update own forum comments" ON public.forum_comments;
DROP POLICY IF EXISTS "Users can delete own forum comments" ON public.forum_comments;

-- Create RLS Policies for forum_comments
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

-- Create trigger for auto-updating updated_at
DROP TRIGGER IF EXISTS update_forum_comments_updated_at ON public.forum_comments;
CREATE TRIGGER update_forum_comments_updated_at
    BEFORE UPDATE ON public.forum_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Verify creation
SELECT 
    table_name,
    CASE WHEN table_name IS NOT NULL THEN '✅ Created' ELSE '❌ Missing' END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'forum_comments';

-- ============================================================================
-- DONE!
-- ============================================================================
