# KrishiBondhu AI - Setup Guide

## 🔐 API Keys Configuration

This project requires several API keys to function properly. Follow these steps to configure them:

### 1. **Supabase Setup**
1. Go to [https://supabase.com](https://supabase.com) and create a new project
2. Once created, navigate to Project Settings → API
3. Copy your `Project URL` and `anon public` key

### 2. **Google Gemini AI Setup**
1. Visit [https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)
2. Create a new API key for Gemini
3. Copy the generated API key

### 3. **OpenWeatherMap Setup**
1. Go to [https://openweathermap.org/api](https://openweathermap.org/api)
2. Sign up for a free account
3. Generate an API key from your account dashboard

### 4. **Configure Your App**

#### Step 1: Create `app_config.dart`
1. Copy the template file:
   ```bash
   cp lib/core/config/app_config.example.dart lib/core/config/app_config.dart
   ```
   
2. Open `lib/core/config/app_config.dart` and replace the placeholders:
   ```dart
   class AppConfig {
     static const String supabaseUrl = 'your_actual_supabase_url';
     static const String supabaseAnonKey = 'your_actual_supabase_anon_key';
     static const String geminiApiKey = 'your_actual_gemini_api_key';
     // ... rest of the config
   }
   ```

#### Step 2: Update Weather Service
Open `lib/core/services/weather_service.dart` and add your OpenWeatherMap API key:
```dart
static const String apiKey = 'your_openweathermap_api_key';
```

### 5. **Firebase Setup (Optional for Authentication)**
If using Firebase Authentication:
1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Add an Android app to your project
3. Download `google-services.json` 
4. Place it in `android/app/` directory

## ⚠️ Important Security Notes

- **NEVER** commit `app_config.dart` to version control
- **NEVER** commit `google-services.json` to version control
- The `.gitignore` file is already configured to exclude these files
- Always use the example template for sharing code

## 📝 Files to Keep Private

These files contain sensitive information and are already in `.gitignore`:
- `lib/core/config/app_config.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## ✅ Ready to Commit

Once you've set up your API keys locally:
1. The sensitive files will be automatically ignored by Git
2. You can safely commit and push your code
3. Share the `app_config.example.dart` as a template for others

## 🚀 Running the App

After configuring all API keys:
```bash
flutter pub get
flutter run
```

---

**Need Help?** Check the main README.md for more information about the app features and architecture.
