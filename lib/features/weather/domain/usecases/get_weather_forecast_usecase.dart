import 'package:dartz/dartz.dart';
import '../entities/weather_forecast.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting 7-day weather forecast
class GetWeatherForecastUseCase {
  final WeatherRepository repository;
  
  GetWeatherForecastUseCase(this.repository);
  
  Future<Either<String, List<WeatherForecast>>> call() async {
    return await repository.getWeatherForecast();
  }
}
