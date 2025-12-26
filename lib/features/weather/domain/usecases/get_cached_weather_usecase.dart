import 'package:dartz/dartz.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting cached weather data
class GetCachedWeatherUseCase {
  final WeatherRepository repository;
  
  GetCachedWeatherUseCase(this.repository);
  
  Future<Either<String, Weather>> call() async {
    return await repository.getCachedWeather();
  }
}
