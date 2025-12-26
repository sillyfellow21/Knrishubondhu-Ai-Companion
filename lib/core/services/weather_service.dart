import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

/// Weather Service for Open-Meteo API integration
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  /// Get current weather and 7-day forecast
  /// 
  /// Returns weather data from Open-Meteo API
  /// Throws exception if API call fails
  Future<Map<String, dynamic>> getWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum',
          'timezone': 'Asia/Dhaka',
        },
      );
      
      Logger.info('Fetching weather data from: $uri');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('আবহাওয়া তথ্য আনতে সময় শেষ');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Weather data fetched successfully');
        return data;
      } else {
        Logger.error('Weather API error: ${response.statusCode}');
        throw Exception('আবহাওয়া তথ্য আনতে ব্যর্থ হয়েছে');
      }
    } catch (e) {
      Logger.error('Weather service error: $e');
      rethrow;
    }
  }
  
  /// Get current device location
  /// 
  /// Returns Position with latitude and longitude
  /// Handles permission requests automatically
  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Logger.warning('Location services are disabled');
        throw Exception('লোকেশন সার্ভিস বন্ধ আছে। দয়া করে চালু করুন।');
      }
      
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Logger.warning('Location permission denied');
          throw Exception('লোকেশন অনুমতি প্রয়োজন।');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        Logger.error('Location permission denied forever');
        throw Exception('লোকেশন অনুমতি স্থায়ীভাবে বন্ধ করা আছে। সেটিংস থেকে চালু করুন।');
      }
      
      // Get current position
      Logger.info('Getting current location');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      
      Logger.info('Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      Logger.error('Location error: $e');
      rethrow;
    }
  }
  
  /// Get weather description in Bengali from weather code
  /// 
  /// Open-Meteo weather codes: https://open-meteo.com/en/docs
  String getWeatherDescription(int code) {
    if (code == 0) return 'পরিষ্কার আকাশ';
    if (code >= 1 && code <= 3) return 'আংশিক মেঘলা';
    if (code >= 45 && code <= 48) return 'কুয়াশা';
    if (code >= 51 && code <= 55) return 'গুঁড়ি গুঁড়ি বৃষ্টি';
    if (code >= 56 && code <= 57) return 'হিমশীতল গুঁড়ি বৃষ্টি';
    if (code >= 61 && code <= 65) return 'বৃষ্টি';
    if (code >= 66 && code <= 67) return 'হিমশীতল বৃষ্টি';
    if (code >= 71 && code <= 75) return 'তুষারপাত';
    if (code >= 77 && code <= 77) return 'শিলাবৃষ্টি';
    if (code >= 80 && code <= 82) return 'বর্ষণ';
    if (code >= 85 && code <= 86) return 'তুষার ঝড়';
    if (code >= 95 && code <= 99) return 'বজ্রঝড়';
    return 'অজানা';
  }
  
  /// Get weather icon based on weather code
  String getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code >= 1 && code <= 3) return '🌤️';
    if (code >= 45 && code <= 48) return '🌫️';
    if (code >= 51 && code <= 57) return '🌦️';
    if (code >= 61 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '⛈️';
    if (code >= 85 && code <= 86) return '🌨️';
    if (code >= 95 && code <= 99) return '⚡';
    return '🌡️';
  }
}
