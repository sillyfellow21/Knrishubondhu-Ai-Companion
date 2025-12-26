import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/weather_service.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_cached_weather_usecase.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';
import '../../domain/usecases/get_weather_forecast_usecase.dart';
import 'weather_state.dart';
import 'weather_view_model.dart';

/// Weather Service Provider
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

/// Database Service Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Weather Repository Provider
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    weatherService: ref.read(weatherServiceProvider),
    databaseService: ref.read(databaseServiceProvider),
  );
});

/// Get Current Weather Use Case Provider
final getCurrentWeatherUseCaseProvider = Provider<GetCurrentWeatherUseCase>((ref) {
  return GetCurrentWeatherUseCase(ref.read(weatherRepositoryProvider));
});

/// Get Weather Forecast Use Case Provider
final getWeatherForecastUseCaseProvider = Provider<GetWeatherForecastUseCase>((ref) {
  return GetWeatherForecastUseCase(ref.read(weatherRepositoryProvider));
});

/// Get Cached Weather Use Case Provider
final getCachedWeatherUseCaseProvider = Provider<GetCachedWeatherUseCase>((ref) {
  return GetCachedWeatherUseCase(ref.read(weatherRepositoryProvider));
});

/// Weather View Model Provider
final weatherViewModelProvider = StateNotifierProvider<WeatherViewModel, WeatherState>((ref) {
  return WeatherViewModel(
    getCurrentWeatherUseCase: ref.read(getCurrentWeatherUseCaseProvider),
    getWeatherForecastUseCase: ref.read(getWeatherForecastUseCaseProvider),
    getCachedWeatherUseCase: ref.read(getCachedWeatherUseCaseProvider),
  );
});
