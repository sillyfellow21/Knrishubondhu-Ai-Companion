import 'package:dartz/dartz.dart';
import '../entities/weather.dart';
import '../entities/weather_forecast.dart';

/// Weather Repository Interface
abstract class WeatherRepository {
  /// Get current weather for user's location
  Future<Either<String, Weather>> getCurrentWeather();
  
  /// Get 7-day weather forecast for user's location
  Future<Either<String, List<WeatherForecast>>> getWeatherForecast();
  
  /// Get cached weather data (for offline mode)
  Future<Either<String, Weather>> getCachedWeather();
}
