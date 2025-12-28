# Quick Start Guide - Weather Feature

## 📍 Location: `/lib/features/weather/`

## 🚀 Getting Started

### Step 1: Add OpenWeatherMap API Key

1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Get your free API key
3. Open `lib/core/services/weather_service.dart`
4. Add your API key:

```dart
class WeatherService {
  static const String apiKey = 'YOUR_API_KEY_HERE'; // ← Add here
  ...
}
```

### Step 2: Run the App

```bash
flutter pub get
flutter run
```

### Step 3: Navigate to Weather Screen

From your app's main navigation, tap on the Weather option to see:
- ✅ Current weather information
- ✅ Temperature, humidity, wind speed
- ✅ Farming tips based on weather

## 🎨 UI Components

### 1. Weather Card (Top)
- Current temperature with large display
- Weather icon from OpenWeatherMap
- Location name
- Feels-like temperature
- Beautiful gradient background

### 2. Details Card (Middle)
- Humidity percentage
- Wind speed
- Atmospheric pressure
- Min/Max temperature

### 3. Farming Tips Card (Bottom)
- Smart recommendations based on:
  - Temperature conditions
  - Humidity levels
  - Weather type (rain, clear, cloudy)
- Tips in Bengali (বাংলা)

## 🌾 Farming Tips Logic

The app automatically generates farming advice based on:

| Condition | Tip Type |
|-----------|----------|
| Temp > 35°C | Heat warnings, frequent irrigation |
| Temp 30-35°C | Regular watering, mulching |
| Temp < 15°C | Winter crops, potato/tomato season |
| Humidity > 80% | Fungicide spray, disease prevention |
| Humidity < 40% | Frequent watering, sprinklers |
| Rain forecast | Drainage check, no pesticides |
| Clear sky | Pesticide application, crop drying |
| Cloudy | Fertilizer application, seedling planting |

## 🔧 Technical Details

### Architecture
- **Clean Architecture** with separation of concerns
- **Repository Pattern** for data management
- **Use Cases** for business logic
- **Riverpod** for state management

### Key Classes
- `WeatherService` - API calls to OpenWeatherMap
- `WeatherRepository` - Data access layer
- `WeatherViewModel` - Business logic & farming tips
- `WeatherScreen` - UI presentation

### API Endpoints Used
- Current Weather: `api.openweathermap.org/data/2.5/weather`
- Units: Metric (°C, m/s)
- Language: Bengali (bn)

## 🐛 Troubleshooting

### "OpenWeatherMap API কী যোগ করুন"
**Solution:** Add your API key in `weather_service.dart`

### "লোকেশন সার্ভিস বন্ধ আছে"
**Solution:** Enable location services on your device

### "লোকেশন অনুমতি প্রয়োজন"
**Solution:** Grant location permission to the app

### No weather data showing
**Solution:** 
1. Check internet connection
2. Verify API key is correct
3. Ensure location services are enabled

## 📱 Features at a Glance

✅ Real-time weather data  
✅ Location-based information  
✅ Beautiful Bengali UI  
✅ Pull-to-refresh  
✅ Smart farming recommendations  
✅ Weather icons  
✅ Detailed weather metrics  
✅ No database required  

## 🔄 How to Refresh

- **Pull down** on the screen to refresh
- Or tap the **refresh icon** in the app bar

## 📊 Data Displayed

### Weather Metrics
- 🌡️ Temperature (°C)
- 💧 Humidity (%)
- 💨 Wind Speed (m/s)
- 📊 Pressure (hPa)
- 🌡️ Feels Like (°C)
- 📈 Min/Max Temperature

### Location Info
- City name
- Current date and time
- Weather description

## 🌍 API Limits

**Free Tier:**
- 60 calls/minute
- 1,000,000 calls/month
- Current weather data
- 5 day / 3 hour forecast

## 📝 Notes

- All text is in Bengali (বাংলা)
- Requires active internet connection
- Location permission is mandatory
- No offline mode (direct API calls)
- Weather data updates on refresh

## 🎯 Next Steps

After adding your API key:
1. Test the weather screen
2. Verify location permissions work
3. Review farming tips accuracy
4. Customize tips if needed (edit `weather_view_model.dart`)

## 📚 Further Reading

- [OpenWeatherMap API Docs](https://openweathermap.org/api)
- [Weather Feature README](./README.md)
- [Project Documentation](../../WEATHER_REDESIGN_SUMMARY.md)

---

**Need Help?** Check the full [README.md](./README.md) for detailed architecture and setup information.
