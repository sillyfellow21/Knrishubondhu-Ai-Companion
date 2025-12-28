import 'package:dartz/dartz.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weather_model.dart';

/// Weather Repository Implementation
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService weatherService;

  WeatherRepositoryImpl({
    required this.weatherService,
  });

  @override
  Future<Either<String, Weather>> getCurrentWeather() async {
    try {
      final position = await weatherService.getCurrentLocation();

      final weatherData = await weatherService.getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final weather = WeatherModel.fromJson(weatherData);

      Logger.info('Weather fetched successfully');
      return Right(weather);
    } catch (e) {
      Logger.error('Error getting weather: $e');
      return Left('আবহাওয়া তথ্য লোড করতে ব্যর্থ। $e');
    }
  }
}
