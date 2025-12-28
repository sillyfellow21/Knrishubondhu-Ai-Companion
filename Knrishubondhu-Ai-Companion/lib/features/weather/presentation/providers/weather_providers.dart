import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/weather_service.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';
import 'weather_state.dart';
import 'weather_view_model.dart';

/// Weather Service Provider
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

/// Weather Repository Provider
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    weatherService: ref.read(weatherServiceProvider),
  );
});

/// Get Current Weather Use Case Provider
final getCurrentWeatherUseCaseProvider =
    Provider<GetCurrentWeatherUseCase>((ref) {
  return GetCurrentWeatherUseCase(ref.read(weatherRepositoryProvider));
});

/// Weather View Model Provider
final weatherViewModelProvider =
    StateNotifierProvider<WeatherViewModel, WeatherState>((ref) {
  return WeatherViewModel(
    getCurrentWeatherUseCase: ref.read(getCurrentWeatherUseCaseProvider),
  );
});
