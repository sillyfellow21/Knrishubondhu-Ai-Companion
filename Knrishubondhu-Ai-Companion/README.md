# 🌾 KrishiBondhu AI (কৃষিবন্ধু AI)

**AI-Powered Agricultural Assistant for Bangladeshi Farmers**

An intelligent mobile application that combines the power of plant databases, AI technology, and modern farming practices to help farmers make better decisions and improve their agricultural productivity.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue.svg)](https://dart.dev)
[![Version](https://img.shields.io/badge/Version-1.0.2%2B3-green.svg)](https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)](https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion)

---

## 🚀 Features

### 🤖 **AI-Powered Chatbot (Primary: Perenual Plant Database)**
- **10,000+ plant species database** with verified agricultural data
- **7-step detailed cultivation guides** from soil to harvest
- **Bengali to English translation** for 30+ common crops
- **Special care instructions** for tomato, rice, corn, and more
- Real-time plant care recommendations (watering, sunlight, fertilizer)
- Optional Gemini AI fallback for complex queries
- Complete offline support with chat history

### 🌤️ **Weather Dashboard**
- Real-time weather data with OpenWeatherMap API
- 7-day weather forecast
- GPS-based location detection
- Bengali weather descriptions
- Temperature, humidity, wind speed display
- Offline caching

### 🌱 **Land Management**
- Track multiple land parcels
- Soil type and area management
- Seasonal crop recommendations (6 seasons)
- Crop planning and rotation tracking
- Offline-first with cloud sync

### 📅 **Crop Calendar**
- 18+ crop varieties with planting schedules
- Seasonal recommendations
- Bengali crop names and descriptions
- Best planting times for each season
- JSON-based crop database

### 💰 **Loan Tracker**
- Agricultural loan management
- Track amounts, payments, due dates
- Visual bar charts (fl_chart)
- Loan status tracking
- Lender details management

### 👥 **Community Forum**
- Share experiences with other farmers
- Ask questions and get answers
- Real-time updates
- Offline post creation
- User-based post management

### 📊 **Advanced Reporting**
- Weather trend visualization
- Loan tracking charts
- Land statistics
- Export-ready data
- Historical tracking

### 📱 **User Experience**
- 🔐 Secure Supabase authentication
- 💾 Offline-first architecture (SQLite + Cloud)
- 🌐 Full Bengali language support
- 🎨 Modern Material 3 design
- 🔙 Intuitive navigation with back button handling
- ⚡ Fast and responsive UI

---

## 🛠️ Tech Stack

### **Core Technologies**
- **Framework**: Flutter 3.x (Dart 3+)
- **State Management**: Riverpod 2.5.1
- **Architecture**: Clean Architecture (Domain-Driven Design)
- **Navigation**: Go Router with PopScope

### **Backend & APIs**
- **Database**: Supabase (PostgreSQL + Auth + Storage)
- **Local Storage**: SQLite (sqflite)
- **Plant Data**: Perenual Plant API (10,000+ species) 🌱 **PRIMARY**
- **AI Assistant**: Google Gemini AI (gemini-1.5-flash) - Optional fallback
- **Weather**: OpenWeatherMap API
- **Charts**: FL Chart

### **Security**
- Row Level Security (RLS) in Supabase
- SQL injection prevention
- XSS pattern detection
- Secure API key management
- Input validation and sanitization

---

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities and services
│   ├── config/             # App configuration & API keys
│   │   ├── app_config.dart           # Main config (excluded from Git)
│   │   └── app_config.example.dart   # Template for setup
│   ├── services/           # Backend services
│   │   ├── perenual_service.dart     # Plant database API
│   │   ├── gemini_service.dart       # AI assistant (optional)
│   │   ├── weather_service.dart      # Weather API
│   │   └── supabase_service.dart     # Supabase operations
│   ├── router/             # Navigation routing
│   ├── theme/              # UI theming
│   └── utils/              # Utility functions
│
├── features/               # Feature modules (Clean Architecture)
│   ├── auth/              # Authentication
│   ├── chat/              # AI Chatbot
│   ├── weather/           # Weather Dashboard
│   ├── lands/             # Land Management
│   ├── loans/             # Loan Tracker
│   ├── crop_calendar/     # Crop Calendar
│   ├── forum/             # Community Forum
│   └── profile/           # User Profile
│
└── main.dart              # App entry point
```

---

## 🔧 Setup & Installation

### **1. Prerequisites**
- Flutter SDK 3.0+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart SDK 3.0+
- Android Studio or VS Code
- Git

### **2. Clone the Repository**
```bash
git clone https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion.git
cd Knrishubondhu-Ai-Companion/Knrishubondhu-Ai-Companion
```

### **3. Install Dependencies**
```bash
flutter pub get
```

### **4. Configure API Keys**

⚠️ **IMPORTANT**: This project requires API keys that are NOT included in the repository.

#### **Step-by-Step Setup:**

1. **Copy the template configuration:**
   ```bash
   copy lib\core\config\app_config.example.dart lib\core\config\app_config.dart
   ```

2. **Get API Keys:**

   **a) Perenual Plant API (Required - FREE):**
   - Go to: https://perenual.com/docs/api
   - Sign up for free account
   - Copy your API key (format: `sk-xxxx`)
   - Free tier: 300 requests/day

   **b) Supabase (Required - FREE):**
   - Go to: https://supabase.com
   - Create a new project
   - Get URL and Anon Key from Project Settings → API

   **c) OpenWeatherMap (Required - FREE):**
   - Go to: https://openweathermap.org/api
   - Sign up and generate API key
   - Free tier: 1,000 calls/day

   **d) Google Gemini AI (Optional):**
   - Go to: https://aistudio.google.com/app/apikey
   - Create API key (optional fallback)

3. **Update Configuration:**
   
   Edit `lib/core/config/app_config.dart`:
   ```dart
   class AppConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_KEY';
     static const String perenualApiKey = 'sk-xxxx-YOUR_PERENUAL_KEY';
     static const String geminiApiKey = 'YOUR_GEMINI_KEY'; // Optional
     // ...
   }
   ```

   Edit `lib/core/services/weather_service.dart` (line 9):
   ```dart
   static const String apiKey = 'YOUR_OPENWEATHERMAP_KEY';
   ```

📖 **Detailed Setup Guide**: See [API_SETUP_GUIDE.md](API_SETUP_GUIDE.md)

### **5. Run the App**
```bash
flutter run
```

---

## 📚 Documentation

- **[API_SETUP_GUIDE.md](API_SETUP_GUIDE.md)** - Complete API configuration guide
- **[PERENUAL_API_GUIDE.md](PERENUAL_API_GUIDE.md)** - Perenual integration details
- **[AI_SERVICE_CONFIG.md](AI_SERVICE_CONFIG.md)** - AI service configuration
- **[PROJECT_REPORT.md](PROJECT_REPORT.md)** - Complete project documentation
- **[TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md)** - Technical details

---

## 🎯 How It Works

### **AI Chatbot Flow:**

1. **User asks a plant question** (e.g., "টমেটো চাষ করতে কি লাগে?")
2. **System detects plant keywords** (টমেটো, ধান, ভুট্টা, etc.)
3. **Translates to English** ("tomato") using built-in dictionary
4. **Queries Perenual API** for verified plant data
5. **Generates 7-step cultivation guide**:
   - 🌱 Soil preparation
   - 🌾 Planting guidelines
   - 💧 Watering schedule
   - ☀️ Sunlight requirements
   - 🌿 Fertilizer application
   - 🐛 Pest control
   - 🌾 Harvesting tips
6. **Adds special care** for specific crops (tomato, rice, corn)
7. **Returns comprehensive guide** in Bengali

**If Perenual fails** → Falls back to Gemini AI (if configured)

---

## 🌟 Key Features Explained

### **1. Offline-First Architecture**
- All data stored locally in SQLite
- Automatic sync when online
- Works without internet connection
- Network detection with visual indicators

### **2. Plant Database (Perenual)**
- 10,000+ verified plant species
- Accurate watering, sunlight data
- No AI hallucinations
- Database-backed information
- 30+ Bengali crop translations

### **3. Detailed Cultivation Guides**
Every plant query returns:
- Scientific name
- Lifecycle information
- Complete growing instructions
- Fertilizer schedule (NPK ratios)
- Pest control methods
- Harvesting guidelines

### **4. Security & Privacy**
- API keys excluded from Git
- Row Level Security (RLS)
- User data isolation
- Secure authentication

---

## 🔐 Security Notes

### **Files NOT in Git (Private):**
- ❌ `lib/core/config/app_config.dart` - Your actual API keys
- ❌ `android/app/google-services.json` - Firebase config
- ❌ `MY_API_KEYS_BACKUP.txt` - Key backup

### **Files IN Git (Safe to share):**
- ✅ `lib/core/config/app_config.example.dart` - Template
- ✅ All source code
- ✅ Documentation
- ✅ Project structure

---

## 🚀 Development

### **Code Generation (Riverpod)**
```bash
flutter pub run build_runner watch
```

### **Clean Architecture Layers**
- **Domain**: Business logic, entities, repository interfaces
- **Data**: Repository implementations, data sources (API, SQLite)
- **Presentation**: UI, screens, widgets, state management

### **Run Tests**
```bash
flutter test
```

### **Build APK**
```bash
flutter build apk --release
```

---

## 📊 Project Stats

- **Screens**: 10+
- **Code**: 12,000+ lines
- **Dependencies**: 27+ packages
- **Language**: Bengali (বাংলা)
- **Platform**: Android (iOS ready)
- **Database Tables**: 11 (7 SQLite + 4 Supabase)
- **API Integrations**: 4
- **Plant Database**: 10,000+ species
- **Translation Dictionary**: 30+ crops
- **Architecture**: Clean Architecture + SOLID

---

## 🤝 Contributing

This is a private project. For collaboration inquiries, please contact the repository owner.

---

## 📝 Version History

### **v1.0.2 (Current)** - December 31, 2025
- ✅ Integrated Perenual Plant API as primary source
- ✅ Added 30+ Bengali crop name translations
- ✅ Implemented 7-step cultivation guides
- ✅ Special care for tomato, rice, corn
- ✅ Made Gemini AI optional
- ✅ Updated to OpenWeatherMap API
- ✅ Enhanced API key security

### **v1.0.1** - December 28, 2025
- Initial production release
- Core features implemented
- Supabase integration
- Offline support

---

## 🐛 Known Issues

See [POTENTIAL_ISSUES_AND_FIXES.md](POTENTIAL_ISSUES_AND_FIXES.md) for known issues and solutions.

---

## 📧 Support

For issues or questions:
- Open an issue on GitHub
- Check documentation files
- Review [PROJECT_REPORT.md](PROJECT_REPORT.md)

---

## 🙏 Acknowledgments

- **Perenual** - Plant database API
- **OpenWeatherMap** - Weather data
- **Supabase** - Backend infrastructure
- **Google Gemini AI** - AI assistance
- **Flutter Community** - Framework and packages
- **Bangladeshi Farmers** - Inspiration and feedback

---

## 📄 License

This project is private and proprietary.

---

**Made with ❤️ for Bangladeshi Farmers**

**Repository**: https://github.com/sillyfellow21/Knrishubondhu-Ai-Companion

**Version**: 1.0.2+3 | **Status**: ✅ Production Ready | **Last Updated**: December 31, 2025
