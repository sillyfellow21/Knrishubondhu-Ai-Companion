import 'package:dartz/dartz.dart';
import '../entities/weather.dart';

/// Weather Repository Interface
abstract class WeatherRepository {
  /// Get current weather for user's location
  Future<Either<String, Weather>> getCurrentWeather();
}
