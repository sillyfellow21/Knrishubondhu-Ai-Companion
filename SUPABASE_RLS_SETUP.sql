# Supabase Row Level Security (RLS) Setup

## Copy and run these SQL commands in your Supabase SQL Editor

```sql
-- ============================================
-- USERS TABLE
-- ============================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

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

-- Create indexes
CREATE INDEX idx_lands_user_id ON lands(user_id);
CREATE INDEX idx_lands_created_at ON lands(created_at DESC);

CREATE INDEX idx_loans_user_id ON loans(user_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_loans_due_date ON loans(due_date);

CREATE INDEX idx_forum_posts_created_at ON forum_posts(created_at DESC);
CREATE INDEX idx_forum_posts_user_id ON forum_posts(user_id);

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
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_lands_updated_at ON lands;
DROP TRIGGER IF EXISTS update_loans_updated_at ON loans;
DROP TRIGGER IF EXISTS update_forum_posts_updated_at ON forum_posts;

-- Create triggers
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

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

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check if RLS is enabled on all tables
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'lands', 'loans', 'forum_posts');

-- Check all policies
SELECT schemaname, tablename, policyname, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Check all indexes
SELECT tablename, indexname, indexdef 
FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'lands', 'loans', 'forum_posts')
ORDER BY tablename, indexname;
```

## 🔒 Security Notes

1. **RLS Enabled**: All tables have Row Level Security enabled
2. **User Isolation**: Users can only access their own data (except forum posts which are public read)
3. **Authenticated Only**: Most write operations require authentication
4. **Performance**: Indexes created on frequently queried columns
5. **Auto-Update**: Triggers automatically update `updated_at` timestamps

## ✅ Testing RLS Policies

Test these queries after setup (replace with actual user IDs):

```sql
-- Test as authenticated user (run in Supabase SQL Editor after authenticating)
SELECT * FROM users WHERE id = auth.uid(); -- Should return current user only
SELECT * FROM lands WHERE user_id = auth.uid(); -- Should return user's lands only
SELECT * FROM loans WHERE user_id = auth.uid(); -- Should return user's loans only
SELECT * FROM forum_posts; -- Should return all posts (public read)
```

## 🚨 Important

- Run these commands in **Supabase SQL Editor**
- Test thoroughly before deploying to production
- Monitor slow queries and add indexes as needed
- Regular backup of database recommended
