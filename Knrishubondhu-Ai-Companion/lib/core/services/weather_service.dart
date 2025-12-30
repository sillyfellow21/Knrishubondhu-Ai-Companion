import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

/// Weather Service for OpenWeatherMap API integration
class WeatherService {
  // TODO: Add your OpenWeatherMap API key here
  static const String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY_HERE';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Get current weather data from OpenWeatherMap
  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenWeatherMap API কী যোগ করুন');
    }

    try {
      final uri = Uri.parse('$_baseUrl/weather').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'appid': apiKey,
          'units': 'metric',
          'lang': 'bn',
        },
      );

      Logger.info('Fetching weather from OpenWeatherMap');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('সময় শেষ');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Weather data fetched successfully');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('অবৈধ API কী');
      } else {
        Logger.error('Weather API error: ${response.statusCode}');
        throw Exception('আবহাওয়া তথ্য লোড করতে ব্যর্থ');
      }
    } catch (e) {
      Logger.error('Weather service error: $e');
      rethrow;
    }
  }

  /// Get 5-day weather forecast
  Future<Map<String, dynamic>> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenWeatherMap API কী যোগ করুন');
    }

    try {
      final uri = Uri.parse('$_baseUrl/forecast').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'appid': apiKey,
          'units': 'metric',
          'lang': 'bn',
          'cnt': '16', // 2 days (8 forecasts per day)
        },
      );

      Logger.info('Fetching forecast from OpenWeatherMap');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('সময় শেষ');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Forecast data fetched successfully');
        return data;
      } else {
        Logger.error('Forecast API error: ${response.statusCode}');
        throw Exception('পূর্বাভাস লোড করতে ব্যর্থ');
      }
    } catch (e) {
      Logger.error('Forecast service error: $e');
      rethrow;
    }
  }

  /// Get weather for Badda, Dhaka (default location)
  /// Coordinates: 23.7808° N, 90.4250° E
  Future<Position> getCurrentLocation() async {
    try {
      // Return Badda, Dhaka coordinates directly
      Logger.info('Using default location: Badda, Dhaka');
      return Position(
        latitude: 23.7808,
        longitude: 90.4250,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } catch (e) {
      Logger.error('Location error: $e');
      rethrow;
    }
  }
}
