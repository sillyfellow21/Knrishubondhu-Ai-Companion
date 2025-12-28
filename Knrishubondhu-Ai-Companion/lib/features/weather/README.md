# Weather Feature - OpenWeatherMap Integration

## Overview
Redesigned weather feature that fetches real-time weather data from OpenWeatherMap API and provides farming tips based on current weather conditions.

## Features
✅ Real-time weather data from OpenWeatherMap  
✅ Current temperature, humidity, wind speed, and pressure  
✅ Weather description and icons  
✅ Location-based weather information  
✅ Intelligent farming tips based on weather conditions  
✅ Beautiful and responsive UI  
✅ Pull-to-refresh functionality  
✅ No database caching (direct API calls)  

## Setup Instructions

### 1. Get OpenWeatherMap API Key
1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Go to API Keys section
4. Copy your API key

### 2. Add API Key
Open `lib/core/services/weather_service.dart` and add your API key:

```dart
class WeatherService {
  // Add your OpenWeatherMap API key here
  static const String apiKey = 'YOUR_API_KEY_HERE';
  // ...
}
```

### 3. Run the App
```bash
flutter pub get
flutter run
```

## Farming Tips Logic

The app provides intelligent farming tips based on:

### Temperature-based Tips
- **> 35°C**: Excessive heat warnings, irrigation recommendations
- **30-35°C**: Hot weather tips, mulching suggestions
- **< 15°C**: Cold weather crops, winter farming advice
- **15-30°C**: Ideal temperature acknowledgment

### Humidity-based Tips
- **> 80%**: High humidity warnings, fungicide recommendations
- **< 40%**: Low humidity irrigation tips

### Weather Condition Tips
- **Rain**: Drainage advice, avoid pesticide application
- **Clear**: Good time for pesticide, drying crops
- **Cloudy**: Fertilizer application, seedling planting

## Architecture

```
weather/
├── data/
│   ├── models/
│   │   └── weather_model.dart          # Weather data model
│   └── repositories/
│       └── weather_repository_impl.dart # Repository implementation
├── domain/
│   ├── entities/
│   │   └── weather.dart                 # Weather entity
│   ├── repositories/
│   │   └── weather_repository.dart      # Repository interface
│   └── usecases/
│       └── get_current_weather_usecase.dart
├── presentation/
│   ├── providers/
│   │   ├── weather_providers.dart       # Riverpod providers
│   │   ├── weather_state.dart           # State management
│   │   └── weather_view_model.dart      # Business logic
│   └── screens/
│       └── weather_screen.dart          # UI
└── README.md                            # This file
```

## API Response Structure

### OpenWeatherMap Current Weather API
```json
{
  "main": {
    "temp": 25.5,
    "feels_like": 26.2,
    "temp_min": 24.0,
    "temp_max": 27.0,
    "pressure": 1013,
    "humidity": 65
  },
  "weather": [
    {
      "description": "clear sky",
      "icon": "01d"
    }
  ],
  "wind": {
    "speed": 3.5
  },
  "name": "Dhaka"
}
```

## Removed Features
- ❌ Database caching (direct API calls only)
- ❌ Weather forecast
- ❌ Cached weather usecase
- ❌ Open-Meteo API (switched to OpenWeatherMap)
- ❌ Separate weather card widgets (integrated into screen)

## Dependencies
- `http`: ^1.1.0 - HTTP requests
- `geolocator`: ^10.1.0 - Location services
- `flutter_riverpod`: ^2.4.9 - State management
- `dartz`: ^0.10.1 - Functional programming
- `intl`: ^0.18.1 - Internationalization

## Notes
- Free OpenWeatherMap API has 60 calls/minute limit
- Location permission is required
- Internet connection is mandatory (no offline mode)
- All text is in Bengali (বাংলা)

## Future Enhancements
- [ ] Add 5-day weather forecast
- [ ] Weather alerts and notifications
- [ ] Historical weather data
- [ ] Crop-specific recommendations
- [ ] Share weather tips feature
- [ ] Offline mode with caching
