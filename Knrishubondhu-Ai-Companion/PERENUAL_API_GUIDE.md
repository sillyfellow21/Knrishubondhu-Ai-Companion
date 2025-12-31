# Perenual Plant API Integration Guide

## What is Perenual API?

Perenual is a comprehensive plant database API that provides:
- 🌱 10,000+ plant species data
- 📚 Plant care guides
- 🌿 Watering, sunlight, and growing requirements
- 🔍 Plant search by name

## How It's Integrated

The AI chatbot now uses **both**:
1. **Gemini AI** - For conversational farming advice
2. **Perenual API** - For accurate plant species data

When you ask about a plant, the system:
1. Detects plant-related keywords
2. Fetches real data from Perenual
3. Enhances Gemini's response with accurate plant info

## Setup Instructions

### 1. Get Perenual API Key (FREE)

1. Go to: https://perenual.com/docs/api
2. Sign up for a free account
3. Get your API key from the dashboard
4. Free tier includes: 300 requests/day

### 2. Add API Key to Your App

Open `lib/core/config/app_config.dart` and update line 10:

```dart
static const String perenualApiKey = 'sk-xxxx-your-actual-key';
```

### 3. Test It

Ask the chatbot:
- "টমেটো চাষ করতে কি লাগে?" (What's needed to grow tomatoes?)
- "আলুর যত্ন কিভাবে নিতে হয়?" (How to care for potatoes?)
- "ধান গাছের জন্য কতটা পানি দরকার?" (How much water does rice need?)

The bot will now give accurate, data-backed answers! 🎯

## Features

✅ **Auto-detection** - Automatically fetches plant data when relevant
✅ **Fallback** - Works even if Perenual fails (uses Gemini only)
✅ **Bengali Support** - Searches in both English and Bengali
✅ **Smart Enhancement** - Adds plant data context to AI responses

## API Endpoints Used

1. `/species-list` - Search plants by name
2. `/species/details/{id}` - Get detailed plant info
3. `/species-care-guide-list` - Get care instructions

## Files Modified

1. `lib/core/config/app_config.dart` - Added Perenual API key
2. `lib/core/services/perenual_service.dart` - NEW: Perenual API integration
3. `lib/core/services/gemini_service.dart` - Enhanced with plant data

## Example Query Flow

**User asks:** "গাজর চাষ কিভাবে করব?" (How to grow carrots?)

1. System detects "গাজর" (carrot) keyword
2. Searches Perenual: `searchPlants("গাজর")`
3. Gets carrot data: watering, sunlight, etc.
4. Sends to Gemini: Original question + Plant data
5. Gemini responds with enhanced, accurate advice

## Troubleshooting

**Issue:** "Perenual API key not configured"
- **Fix:** Add your API key in `app_config.dart`

**Issue:** No plant data shown
- **Fix:** Check API key, ensure internet connection

**Issue:** Rate limit exceeded
- **Fix:** Free tier = 300 requests/day, wait or upgrade

## Cost

- **Free Tier:** 300 requests/day
- **Pro Plan:** $20/month for 10,000 requests/day

---

**Note:** Perenual enhances your chatbot but doesn't replace Gemini. You need both APIs for full functionality!
