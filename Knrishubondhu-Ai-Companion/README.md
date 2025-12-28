# KrishiBondhu AI

An AI-powered agricultural assistant mobile application built with Flutter.

## Features

- 🌾 AI-powered agricultural assistance
- 📱 Cross-platform (Android & iOS)
- 🔐 Secure authentication with Supabase
- 💾 Local storage with SQLite
- 🎨 Modern, rounded UI design
- 🔙 Intuitive back button navigation with stack management
- ⚡ Smooth user experience with proper navigation flow

## Tech Stack

- **Framework**: Flutter (Dart 3+)
- **State Management**: Riverpod
- **Architecture**: Clean Architecture
- **Backend**: Supabase (Auth + Database)
- **Local Storage**: SQLite (sqflite)
- **Navigation**: Go Router with PopScope for back button handling
- **UI**: Google Fonts, Material 3

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── constants/       # App constants
│   ├── error/          # Error handling
│   ├── router/         # Navigation routing
│   ├── theme/          # App theming
│   └── utils/          # Utility functions
├── features/           # Feature modules (Clean Architecture)
│   └── [feature_name]/
│       ├── data/       # Data layer (repositories, data sources, models)
│       ├── domain/     # Domain layer (entities, use cases, repositories)
│       └── presentation/ # Presentation layer (screens, widgets, providers)
└── main.dart          # App entry point
```

## Setup

1. **Clone the repository**

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a project at [supabase.com](https://supabase.com)
   - Update `lib/core/config/app_config.dart` with your Supabase URL and Anon Key

4. **Generate code (if needed)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Supabase Setup
Update the following in `lib/core/config/app_config.dart`:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### OpenWeatherMap API Setup
To enable weather features, you need an OpenWeatherMap API key:

1. Go to [OpenWeatherMap](https://openweathermap.org/api) and create a free account
2. Navigate to "API Keys" in your account dashboard
3. Generate a new API key (free tier allows 1,000 calls/day)
4. Update `lib/core/services/weather_service.dart`:
```dart
static const String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
```

> **Note**: The free tier is sufficient for development and personal use.

## Development

### Code Generation
When adding new Riverpod providers with annotations, run:
```bash
flutter pub run build_runner watch
```

### Clean Architecture Principles
- **Domain Layer**: Contains business logic, entities, and repository interfaces
- **Data Layer**: Implements repositories, handles data sources (API, local DB)
- **Presentation Layer**: UI components, screens, and state management

## Theme

- **Primary Color**: #10B981 (Emerald Green)
- **Background**: White
- **UI Style**: Rounded corners, Material 3 design

## License

This project is private and proprietary.
