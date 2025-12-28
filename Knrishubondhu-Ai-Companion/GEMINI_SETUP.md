# 🤖 Gemini AI Chatbot Setup Guide

## 📋 Get Gemini API Key

1. **Visit Google AI Studio**: https://makersuite.google.com/app/apikey
2. **Sign in** with your Google account
3. Click **"Create API Key"**
4. Copy the API key

## ⚙️ Configure API Key

### Option 1: For Development (Quick Test)

Update `lib/core/config/app_config.dart`:

```dart
static const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'YOUR_GEMINI_API_KEY_HERE', // Paste your API key
);
```

### Option 2: For Production (Secure)

Run with dart-define:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

Or add to VS Code launch.json:

```json
{
  "configurations": [
    {
      "name": "Flutter (Development)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=GEMINI_API_KEY=your_api_key_here"
      ]
    }
  ]
}
```

## 📦 Install Dependencies

```bash
cd C:\KrishiBondhuAI
flutter pub get
```

## 🧪 Test Chatbot

```bash
flutter run
```

## ✨ Features

### Text Chat
- Ask questions in Bengali or English
- Receive Bengali responses
- Agriculture-focused AI assistant
- Chat history saved locally

### Image Analysis
- Upload crop images
- AI analyzes diseases, pests, soil
- Get solutions in Bengali
- Image preview before sending

## 🎯 Usage Examples

### Text Questions:
- "ধান চাষের জন্য কী করতে হবে?"
- "আমার জমিতে পোকা দেখা দিয়েছে, কী করবো?"
- "সার কখন দিতে হবে?"

### Image Analysis:
- Upload crop leaf photo → AI identifies disease
- Upload pest photo → AI suggests solution
- Upload soil photo → AI analyzes soil type

## 🔧 Troubleshooting

### API Key Error:
```
Gemini AI is not configured
```
**Solution**: Add valid API key to app_config.dart

### Network Error:
```
Failed to send message
```
**Solution**: Check internet connection

### Image Upload Failed:
```
ছবি নির্বাচন করতে ব্যর্থ হয়েছে
```
**Solution**: Grant storage/camera permissions

## 💡 Tips

- Free tier: 60 requests/minute
- Image size: Max 1024x1024px
- Responses in Bengali by default
- Chat history persists locally

## 🚀 Next Steps

After setup:
1. Test text chat
2. Test image upload
3. Check chat history
4. Customize AI prompts in gemini_service.dart

✅ **Gemini AI Chatbot ready to use!**
