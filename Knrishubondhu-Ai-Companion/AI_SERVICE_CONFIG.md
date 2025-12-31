# AI Service Configuration - Perenual PRIMARY

## 🎯 How It Works Now

**NEW BEHAVIOR:**

1. **Plant Questions** → **Perenual API (PRIMARY)** ✅
   - Direct answers from plant database
   - Accurate, data-backed information
   - Fast responses

2. **If Perenual fails** → **Gemini AI (FALLBACK)** 🔄
   - Only used as backup
   - For complex or non-plant questions

3. **Non-plant Questions** → **Gemini AI** 🤖
   - General farming advice
   - Complex agricultural queries

## 📊 Priority Order

```
User Question
     ↓
Is it about plants? (গাছ, ফসল, টমেটো, etc.)
     ↓
   YES → Try Perenual FIRST
     ↓
   Found data? → Return Perenual response ✅
     ↓
   NO data? → Try Gemini as fallback
     ↓
   NO (not plant-related) → Use Gemini only
```

## 🔑 API Key Setup

### **Option 1: Perenual Only (Recommended)**
```dart
// lib/core/config/app_config.dart

static const String perenualApiKey = 'sk-xxxx-your-perenual-key';
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE'; // Optional
```

**Result:** Plant questions work perfectly, general questions show error message

### **Option 2: Both APIs (Full Features)**
```dart
static const String perenualApiKey = 'sk-xxxx-your-perenual-key';
static const String geminiApiKey = 'AIzaXXXX-your-gemini-key';
```

**Result:** Plant questions use Perenual, complex questions use Gemini

### **Option 3: Gemini Only (Old Behavior)**
```dart
static const String perenualApiKey = 'YOUR_PERENUAL_API_KEY_HERE'; // Skip
static const String geminiApiKey = 'AIzaXXXX-your-gemini-key';
```

**Result:** All questions use Gemini (no plant database)

## 🌱 Get Perenual API Key

1. Go to: https://perenual.com/docs/api
2. Sign up (FREE)
3. Copy your API key (format: `sk-xxxx`)
4. Add to `app_config.dart`

**Free Tier:** 300 requests/day

## 🤖 Get Gemini API Key (Optional)

1. Go to: https://aistudio.google.com/app/apikey
2. Create API key
3. Add to `app_config.dart`

**Free Tier:** Good for testing

## ✅ Benefits of Perenual Primary

- ✅ **Accurate Data** - Real plant database, not AI guesses
- ✅ **Fast** - Direct database lookup
- ✅ **Reliable** - Structured, verified information
- ✅ **Cost Effective** - 300 free requests/day
- ✅ **No AI Hallucinations** - Facts only

## 📝 Example Responses

**User:** "টমেটো চাষ করতে কি লাগে?"

**Perenual Response:**
```
🌱 Tomato
🔬 বৈজ্ঞানিক নাম: Solanum lycopersicum

💧 পানি প্রয়োজন: Average
☀️ সূর্যালোক: Full sun
🔄 জীবনচক্র: Annual

✅ তথ্য সূত্র: Perenual Plant Database
```

## 🚨 Error Messages

**No API configured:**
> "দুঃখিত, কোন AI সেবা কনফিগার করা নেই। অনুগ্রহ করে API key যোগ করুন।"

**Both APIs failed:**
> "দুঃখিত, AI সেবা বর্তমানে উপলব্ধ নেই। অনুগ্রহ করে পরে চেষ্টা করুন।"

## 🔧 Files Modified

1. `lib/core/services/gemini_service.dart` - Changed to Perenual primary
2. `lib/core/config/app_config.dart` - Added Perenual key config
3. `lib/core/services/perenual_service.dart` - Perenual API integration

---

**Recommendation:** Use **Perenual + Gemini** for best experience! 🌟
