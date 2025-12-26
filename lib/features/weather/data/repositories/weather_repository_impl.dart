import 'package:dartz/dartz.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weather_forecast_model.dart';
import '../models/weather_model.dart';

/// Weather Repository Implementation
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService weatherService;
  final DatabaseService databaseService;
  
  WeatherRepositoryImpl({
    required this.weatherService,
    required this.databaseService,
  });
  
  @override
  Future<Either<String, Weather>> getCurrentWeather() async {
    try {
      // Get current location
      final position = await weatherService.getCurrentLocation();
      
      // Fetch weather data from API
      final weatherData = await weatherService.getWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      // Parse weather model
      final weather = WeatherModel.fromJson(weatherData);
      
      // Cache weather data to database
      await _cacheWeather(weather);
      
      Logger.info('Current weather fetched and cached successfully');
      return Right(weather);
    } catch (e) {
      Logger.error('Error getting current weather: $e');
      
      // Try to return cached data on error
      final cachedResult = await getCachedWeather();
      
      return cachedResult.fold(
        (error) => Left('আবহাওয়া তথ্য আনতে ব্যর্থ হয়েছে। ইন্টারনেট সংযোগ পরীক্ষা করুন।'),
        (cachedWeather) {
          Logger.info('Returning cached weather data');
          return Right(cachedWeather);
        },
      );
    }
  }
  
  @override
  Future<Either<String, List<WeatherForecast>>> getWeatherForecast() async {
    try {
      // Get current location
      final position = await weatherService.getCurrentLocation();
      
      // Fetch weather data from API (includes forecast)
      final weatherData = await weatherService.getWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      // Parse forecast data
      final forecasts = WeatherForecastModel.fromApiResponse(weatherData);
      
      Logger.info('Weather forecast fetched successfully: ${forecasts.length} days');
      return Right(forecasts);
    } catch (e) {
      Logger.error('Error getting weather forecast: $e');
      return Left('আবহাওয়া পূর্বাভাস আনতে ব্যর্থ হয়েছে। ইন্টারনেট সংযোগ পরীক্ষা করুন।');
    }
  }
  
  @override
  Future<Either<String, Weather>> getCachedWeather() async {
    try {
      final db = await databaseService.database;
      
      // Get most recent cached weather
      final results = await db.query(
        'weather_cache',
        orderBy: 'cached_at DESC',
        limit: 1,
      );
      
      if (results.isEmpty) {
        return const Left('কোনো সংরক্ষিত আবহাওয়া তথ্য পাওয়া যায়নি।');
      }
      
      final weather = WeatherModel.fromDatabase(results.first);
      Logger.info('Cached weather retrieved');
      return Right(weather);
    } catch (e) {
      Logger.error('Error getting cached weather: $e');
      return const Left('সংরক্ষিত আবহাওয়া তথ্য পড়তে ব্যর্থ হয়েছে।');
    }
  }
  
  /// Cache weather data to local database
  Future<void> _cacheWeather(WeatherModel weather) async {
    try {
      final db = await databaseService.database;
      
      // Clear old cached data (keep only latest)
      await db.delete('weather_cache');
      
      // Insert new weather data
      await db.insert('weather_cache', weather.toDatabase());
      
      Logger.info('Weather data cached successfully');
    } catch (e) {
      Logger.error('Error caching weather: $e');
      // Don't throw - caching failure shouldn't break the flow
    }
  }
}
