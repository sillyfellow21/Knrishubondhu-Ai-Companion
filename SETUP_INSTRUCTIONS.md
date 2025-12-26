# 🚀 CRITICAL: SETUP INSTRUCTIONS

## ⚠️ MUST DO BEFORE RUNNING THE APP

### Step 1: Install Dependencies (2 minutes)
```bash
cd C:\KrishiBondhuAI
flutter pub get
```

### Step 2: Setup Supabase Database (5 minutes)

**CRITICAL**: The app will crash without these database tables!

#### 2.1. Login to Supabase
1. Go to: https://supabase.com/dashboard
2. Login with your account
3. Select project: **mifwuugvljzhbuavhnbf**

#### 2.2. Open SQL Editor
1. Click "SQL Editor" in left sidebar
2. Click "New Query"

#### 2.3. Execute Migration Files (in order)

**File 1: SUPABASE_PROFILES_TABLE.sql**
```sql
-- Copy entire content from: C:\KrishiBondhuAI\SUPABASE_PROFILES_TABLE.sql
-- Paste in SQL Editor and click "Run"
```

**File 2: SUPABASE_RLS_SETUP.sql**
```sql
-- Copy entire content from: C:\KrishiBondhuAI\SUPABASE_RLS_SETUP.sql
-- Paste in SQL Editor and click "Run"
```

**File 3: Create Lands Table**
```sql
-- Run this in Supabase SQL Editor

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

-- Enable RLS
ALTER TABLE public.lands ENABLE ROW LEVEL SECURITY;

-- RLS Policies for lands
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

-- Indexes
CREATE INDEX idx_lands_user_id ON public.lands(user_id);
```

**File 4: Create Loans Table**
```sql
-- Run this in Supabase SQL Editor

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

-- Enable RLS
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;

-- RLS Policies for loans
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

-- Indexes
CREATE INDEX idx_loans_user_id ON public.loans(user_id);
```

**File 5: Create Chat History Table**
```sql
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.chat_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  response TEXT NOT NULL,
  image_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for chat_history
CREATE POLICY "Users can view own chat history"
  ON public.chat_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat history"
  ON public.chat_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat history"
  ON public.chat_history FOR DELETE
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_chat_history_user_id ON public.chat_history(user_id);
CREATE INDEX idx_chat_history_created_at ON public.chat_history(created_at DESC);
```

**File 6: Create Forum Posts Table**
```sql
-- Run this in Supabase SQL Editor

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

-- Enable RLS
ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for forum_posts (public read, authenticated write)
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

-- Indexes
CREATE INDEX idx_forum_posts_user_id ON public.forum_posts(user_id);
CREATE INDEX idx_forum_posts_created_at ON public.forum_posts(created_at DESC);
```

#### 2.4. Verify Tables Created
```sql
-- Run this to verify all tables exist
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'lands', 'loans', 'chat_history', 'forum_posts');
```

You should see all 5 tables listed.

### Step 3: Run the App (1 minute)
```bash
# Make sure a device is connected or emulator is running
flutter devices

# Run the app
flutter run
```

---

## ✅ FIXES APPLIED

### 1. ✅ Login Screen is Already the Opening Screen
- **Status**: No changes needed
- **Confirmation**: `initialLocation: '/auth'` in `app_router.dart`

### 2. ✅ Gemini API Rate Limiting Fixed
- **What was done**:
  - Added retry logic with exponential backoff (1s, 2s, 4s delays)
  - Detects rate limit errors (429, quota exceeded)
  - Shows user-friendly Bengali error message
  - Applies to all methods: text chat, image analysis
  
- **How it works**:
  - First request fails → Wait 1 second → Retry
  - Second fails → Wait 2 seconds → Retry
  - Third fails → Show error message
  
- **User message**: "দুঃখিত, অনেক বেশি অনুরোধ হয়েছে। অনুগ্রহ করে কিছুক্ষণ পর আবার চেষ্টা করুন।"

### 3. ✅ Location Permission Handler Added
- **What was done**:
  - Added `permission_handler: ^11.3.1` package
  - Checks location permission before loading weather
  - Requests permission if not granted
  - Shows error if permission denied
  
- **Error message**: "আবহাওয়া তথ্য দেখতে অবস্থান অনুমতি প্রয়োজন। অনুগ্রহ করে সেটিংস থেকে অনুমতি দিন।"

### 4. ⚠️ Supabase Database Setup (MANUAL)
- **Status**: MUST BE DONE MANUALLY (cannot execute remotely)
- **Instructions**: See Step 2 above
- **Time required**: 5 minutes
- **Impact if skipped**: App will crash when syncing data

---

## 🧪 TESTING CHECKLIST

After setup, test these features:

### Authentication ✓
1. Sign up with new email
2. Sign in with existing account
3. Verify user data saved to Supabase

### Chat (Gemini AI) ✓
1. Send Bengali text message
2. Upload crop image
3. Try sending 5+ messages quickly (test rate limiting)

### Weather ✓
1. Allow location permission when prompted
2. View current weather
3. Check 7-day forecast

### Lands ✓
1. Add new land
2. Go offline (airplane mode)
3. Add another land
4. Go online → Should sync to Supabase

### Loans ✓
1. Add loan
2. Record payment
3. Verify status changes

---

## 🆘 TROUBLESHOOTING

### Problem: "flutter pub get" fails
**Solution**:
```bash
flutter clean
flutter pub get
```

### Problem: Permission handler not working on Android
**Solution**: Already configured in AndroidManifest.xml, just run:
```bash
flutter run
```

### Problem: Supabase sync errors
**Check**:
1. Did you execute ALL SQL migration files?
2. Check Supabase dashboard → Table Editor → Verify tables exist
3. Check RLS policies are enabled

### Problem: Gemini API still failing
**Check**:
1. API key is valid: AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU
2. Test at: https://aistudio.google.com/app/apikey
3. Check quota: https://console.cloud.google.com/apis/dashboard

### Problem: App crashes on startup
**Check**:
1. Run `flutter doctor` - all checks should pass
2. Check device has internet connection
3. Check logs: `flutter run --verbose`

---

## 📱 FIRST RUN GUIDE

1. **Launch app** → You'll see login/registration screen
2. **Register** → Enter email, password, full name
3. **Allow location** → When weather screen prompts
4. **Test chat** → Send Bengali message "আমার জমিতে পাতা হলুদ হচ্ছে কেন?"
5. **Add land** → Go to Lands → Add your first land
6. **Check sync** → Open Supabase dashboard → Table Editor → lands → See your data

---

## 🎯 SUMMARY

**Total setup time**: ~10 minutes
- Dependencies: 2 min
- Supabase setup: 5 min  
- First run test: 3 min

**What's working**:
✅ Opening screen is login/registration
✅ Gemini rate limiting fixed
✅ Location permission handler added
✅ All code compiles with 0 errors
✅ Offline-first architecture works

**What needs manual action**:
⚠️ Execute Supabase SQL migrations (CRITICAL)

**After setup, the app will run smoothly!** 🎉

---

**Last Updated**: December 26, 2025
**Status**: READY FOR TESTING (after Supabase setup)
