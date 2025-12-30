# 🌾 KrishiBondhu AI - Farming Companion App

A comprehensive Flutter-based farming companion application designed to help Bangladeshi farmers manage crops, finances, and tasks efficiently with AI-powered assistance.

## 🚀 Features

### 1. **Crop Management (ফসল ব্যবস্থাপনা)**
- Track multiple crops with detailed information
- Record planting dates, varieties, and cultivation area
- Maintain crop event logs and timelines
- Monitor crop health and growth stages

### 2. **Financial Tracker (আর্থিক হিসাব)**
- Track income and expenses
- Categorize transactions
- Visual charts for financial analysis
- Calculate net profit automatically

### 3. **Task Planner (কাজের তালিকা)**
- Create and manage farming tasks
- Set due dates and priorities
- Mark tasks as complete
- Never miss important farming activities

### 4. **AI Assistant (AI সহায়তা)**
- Powered by Google Gemini AI
- Expert farming advice in Bengali
- Crop disease identification from images
- Weather-based recommendations
- 24/7 farming consultation

### 5. **Weather Integration**
- Real-time weather data
- Location-based forecasts
- Weather alerts for farming activities

### 6. **Community Forum (কমিউনিটি ফোরাম)**
- Connect with other farmers
- Share experiences and tips
- Ask questions and get answers
- Build a farming community

## 🛠️ Tech Stack

- **Framework**: Flutter (Latest Stable)
- **Backend**: Supabase (Authentication, Database, Storage)
- **AI**: Google Gemini AI
- **Weather**: OpenWeatherMap API
- **State Management**: Provider
- **Local Database**: SQLite (Offline-first)
- **Charts**: fl_chart

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Git

## 🔧 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/krishibondhu-ai.git
cd krishibondhu-ai
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Keys
**IMPORTANT**: This project requires API keys that are NOT included in the repository for security.

Follow the detailed setup guide: **[API_SETUP_GUIDE.md](API_SETUP_GUIDE.md)**

Quick summary:
1. Copy `lib/core/config/app_config.example.dart` to `lib/core/config/app_config.dart`
2. Add your Supabase URL and keys
3. Add your Gemini AI API key
4. Update OpenWeatherMap API key in `weather_service.dart`

### 4. Run the App
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart          # API keys (NOT in Git)
│   │   └── app_config.example.dart  # Template for API keys
│   ├── services/
│   │   ├── gemini_service.dart      # AI service
│   │   ├── weather_service.dart     # Weather API
│   │   └── database_helper.dart     # SQLite operations
│   ├── constants/
│   └── utils/
├── features/
│   ├── auth/                         # Authentication
│   ├── crops/                        # Crop management
│   ├── finance/                      # Financial tracker
│   ├── tasks/                        # Task planner
│   ├── ai_chat/                      # AI assistant
│   ├── weather/                      # Weather info
│   └── forum/                        # Community forum
├── models/
├── providers/
└── main.dart
```

## 🔐 Security Notes

**Files that are NOT committed to Git (for security):**
- `lib/core/config/app_config.dart` - Contains actual API keys
- `android/app/google-services.json` - Firebase config
- `ios/Runner/GoogleService-Info.plist` - Firebase config

These files are listed in `.gitignore` and will remain on your local machine only.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. **DO NOT** commit sensitive files (they're already in .gitignore)
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## 📝 Database Schema

### SQLite Tables (Offline-first)
- `user_crops` - Crop information
- `crop_logs` - Crop event timeline
- `transactions` - Financial records
- `farm_tasks` - Task management

### Supabase Tables (Cloud sync)
- `profiles` - User profiles
- `forum_posts` - Community posts
- `forum_comments` - Post comments
- `crop_data` - Crop master data

## 🌐 API Integrations

1. **Supabase** - Backend as a Service
   - User authentication
   - Real-time database
   - File storage

2. **Google Gemini AI** - AI Assistant
   - Natural language processing
   - Image recognition for crop diseases
   - Farming consultation

3. **OpenWeatherMap** - Weather Data
   - Current weather
   - Weather forecasts
   - Location-based data

## 📱 Screenshots

(Add screenshots of your app here)

## 🐛 Known Issues

Check [POTENTIAL_ISSUES_AND_FIXES.md](POTENTIAL_ISSUES_AND_FIXES.md) for known issues and their solutions.

## 📖 Additional Documentation

- [Technical Documentation](TECHNICAL_DOCUMENTATION.md)
- [Project Report](PROJECT_REPORT.md)
- [API Setup Guide](API_SETUP_GUIDE.md)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- Thanks to all farmers who inspired this project
- Flutter and Dart communities
- Supabase team
- Google Gemini AI team

## 📞 Support

For support, email your-email@example.com or open an issue in the repository.

---

**Made with ❤️ for Bangladeshi Farmers**
