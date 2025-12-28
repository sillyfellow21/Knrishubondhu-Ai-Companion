# ✅ Supabase Setup - Quick Checklist

## 🎯 Your Mission: Set up 5 database tables in 5-7 minutes

---

## 📍 Where to Go
1. Open: **https://supabase.com/dashboard**
2. Select project: **mifwuugvljzhbuavhnbf**
3. Click: **SQL Editor** (left sidebar)
4. Click: **New Query** (top right)

---

## 📝 5 Queries to Run (Copy-Paste Each)

### ☑️ Query 1: Profiles Table
**File**: Open `SUPABASE_PROFILES_TABLE.sql`
- Copy entire file content
- Paste in SQL Editor
- Click **RUN**
- ✅ See "Success. No rows returned"

---

### ☑️ Query 2: Lands Table
**Action**: Click "New Query", then copy-paste this:

```sql
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

ALTER TABLE public.lands ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own lands" ON public.lands FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own lands" ON public.lands FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own lands" ON public.lands FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own lands" ON public.lands FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_lands_user_id ON public.lands(user_id);
CREATE TRIGGER update_lands_updated_at BEFORE UPDATE ON public.lands FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

Click **RUN** ✅

---

### ☑️ Query 3: Loans Table
**Action**: Click "New Query", then copy-paste this:

```sql
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

ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own loans" ON public.loans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own loans" ON public.loans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own loans" ON public.loans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own loans" ON public.loans FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_loans_user_id ON public.loans(user_id);
CREATE TRIGGER update_loans_updated_at BEFORE UPDATE ON public.loans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

Click **RUN** ✅

---

### ☑️ Query 4: Chat History Table
**Action**: Click "New Query", then copy-paste this:

```sql
CREATE TABLE IF NOT EXISTS public.chat_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  response TEXT NOT NULL,
  image_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own chat history" ON public.chat_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own chat history" ON public.chat_history FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own chat history" ON public.chat_history FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_chat_history_user_id ON public.chat_history(user_id);
CREATE INDEX idx_chat_history_created_at ON public.chat_history(created_at DESC);
```

Click **RUN** ✅

---

### ☑️ Query 5: Forum Posts Table
**Action**: Click "New Query", then copy-paste this:

```sql
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

ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view forum posts" ON public.forum_posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert posts" ON public.forum_posts FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can update own posts" ON public.forum_posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON public.forum_posts FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_forum_posts_user_id ON public.forum_posts(user_id);
CREATE INDEX idx_forum_posts_created_at ON public.forum_posts(created_at DESC);
CREATE TRIGGER update_forum_posts_updated_at BEFORE UPDATE ON public.forum_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

Click **RUN** ✅

---

## 🔍 Verify Setup (Quick Check)

**Click "New Query" and run**:

```sql
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'lands', 'loans', 'chat_history', 'forum_posts')
ORDER BY tablename;
```

**Expected result**: 5 rows showing all table names ✅

---

## 🎉 Done! Now:

```bash
cd C:\KrishiBondhuAI
flutter run
```

---

## 📖 Full Detailed Guide

For screenshots and detailed explanations, see:
- **[SUPABASE_VISUAL_SETUP_GUIDE.md](SUPABASE_VISUAL_SETUP_GUIDE.md)**

---

## 🆘 Quick Help

**Error: "relation already exists"**  
→ Table exists. Skip that query.

**Error: "function does not exist"**  
→ Run Query 1 first (creates the trigger function).

**Tables not showing?**  
→ Refresh page (F5) or check Table Editor in left sidebar.

---

**Time Required**: 5-7 minutes  
**Difficulty**: Easy (just copy-paste!)  
**Status after completion**: ✅ Ready to run app
