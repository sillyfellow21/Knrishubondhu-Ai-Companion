import 'package:dartz/dartz.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting current weather
class GetCurrentWeatherUseCase {
  final WeatherRepository repository;
  
  GetCurrentWeatherUseCase(this.repository);
  
  Future<Either<String, Weather>> call() async {
    return await repository.getCurrentWeather();
  }
}
