-- ============================================
-- Supabase Row Level Security (RLS) Setup
-- Copy and run these SQL commands in your Supabase SQL Editor
-- ============================================

-- ============================================
-- USERS TABLE (Optional - only if you have this table)
-- ============================================

-- Enable RLS
ALTER TABLE IF EXISTS users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;

-- Create policies
CREATE POLICY "Users can view own data" ON users
  FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE 
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================
-- LANDS TABLE
-- ============================================

ALTER TABLE lands ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own lands" ON lands;
DROP POLICY IF EXISTS "Users can insert own lands" ON lands;
DROP POLICY IF EXISTS "Users can update own lands" ON lands;
DROP POLICY IF EXISTS "Users can delete own lands" ON lands;

CREATE POLICY "Users can view own lands" ON lands
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lands" ON lands
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lands" ON lands
  FOR UPDATE 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own lands" ON lands
  FOR DELETE 
  USING (auth.uid() = user_id);

-- ============================================
-- LOANS TABLE
-- ============================================

ALTER TABLE loans ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own loans" ON loans;
DROP POLICY IF EXISTS "Users can insert own loans" ON loans;
DROP POLICY IF EXISTS "Users can update own loans" ON loans;
DROP POLICY IF EXISTS "Users can delete own loans" ON loans;

CREATE POLICY "Users can view own loans" ON loans
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own loans" ON loans
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own loans" ON loans
  FOR UPDATE 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own loans" ON loans
  FOR DELETE 
  USING (auth.uid() = user_id);

-- ============================================
-- CHAT HISTORY TABLE
-- ============================================

ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own chat history" ON chat_history;
DROP POLICY IF EXISTS "Users can insert own chat history" ON chat_history;
DROP POLICY IF EXISTS "Users can delete own chat history" ON chat_history;

CREATE POLICY "Users can view own chat history" ON chat_history
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat history" ON chat_history
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat history" ON chat_history
  FOR DELETE 
  USING (auth.uid() = user_id);

-- ============================================
-- FORUM POSTS TABLE
-- ============================================

ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view forum posts" ON forum_posts;
DROP POLICY IF EXISTS "Authenticated users can create posts" ON forum_posts;
DROP POLICY IF EXISTS "Users can update own posts" ON forum_posts;
DROP POLICY IF EXISTS "Users can delete own posts" ON forum_posts;

-- Anyone can read posts
CREATE POLICY "Anyone can view forum posts" ON forum_posts
  FOR SELECT 
  USING (true);

-- Only authenticated users can create posts
CREATE POLICY "Authenticated users can create posts" ON forum_posts
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own posts
CREATE POLICY "Users can update own posts" ON forum_posts
  FOR UPDATE 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete own posts" ON forum_posts
  FOR DELETE 
  USING (auth.uid() = user_id);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Drop existing indexes if any
DROP INDEX IF EXISTS idx_lands_user_id;
DROP INDEX IF EXISTS idx_lands_created_at;
DROP INDEX IF EXISTS idx_loans_user_id;
DROP INDEX IF EXISTS idx_loans_status;
DROP INDEX IF EXISTS idx_loans_due_date;
DROP INDEX IF EXISTS idx_forum_posts_created_at;
DROP INDEX IF EXISTS idx_forum_posts_user_id;
DROP INDEX IF EXISTS idx_chat_history_user_id;
DROP INDEX IF EXISTS idx_chat_history_created_at;

-- Create indexes
CREATE INDEX idx_lands_user_id ON lands(user_id);
CREATE INDEX idx_lands_created_at ON lands(created_at DESC);

CREATE INDEX idx_loans_user_id ON loans(user_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_loans_due_date ON loans(due_date);

CREATE INDEX idx_forum_posts_created_at ON forum_posts(created_at DESC);
CREATE INDEX idx_forum_posts_user_id ON forum_posts(user_id);

CREATE INDEX idx_chat_history_user_id ON chat_history(user_id);
CREATE INDEX idx_chat_history_created_at ON chat_history(created_at DESC);

-- ============================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================

-- Create or replace function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if any
DROP TRIGGER IF EXISTS update_lands_updated_at ON lands;
DROP TRIGGER IF EXISTS update_loans_updated_at ON loans;
DROP TRIGGER IF EXISTS update_forum_posts_updated_at ON forum_posts;

-- Create triggers
CREATE TRIGGER update_lands_updated_at
  BEFORE UPDATE ON lands
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_loans_updated_at
  BEFORE UPDATE ON loans
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_forum_posts_updated_at
  BEFORE UPDATE ON forum_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
