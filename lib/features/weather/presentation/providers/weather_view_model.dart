import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/usecases/get_cached_weather_usecase.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';
import '../../domain/usecases/get_weather_forecast_usecase.dart';
import 'weather_state.dart';

/// Weather View Model
class WeatherViewModel extends StateNotifier<WeatherState> {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  final GetWeatherForecastUseCase getWeatherForecastUseCase;
  final GetCachedWeatherUseCase getCachedWeatherUseCase;
  
  WeatherViewModel({
    required this.getCurrentWeatherUseCase,
    required this.getWeatherForecastUseCase,
    required this.getCachedWeatherUseCase,
  }) : super(const WeatherInitial());
  
  /// Check and request location permission
  Future<bool> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.location.request();
        return result.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        // User has permanently denied permission
        Logger.warning('Location permission permanently denied');
        return false;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error checking location permission', error: e);
      return false;
    }
  }

  /// Load weather data
  Future<void> loadWeather() async {
    state = const WeatherLoading();
    
    try {
      // Check location permission first
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        state = const WeatherError('আবহাওয়া তথ্য দেখতে অবস্থান অনুমতি প্রয়োজন। অনুগ্রহ করে সেটিংস থেকে অনুমতি দিন।');
        return;
      }
      
      Logger.info('Loading weather data...');
      
      // Fetch current weather and forecast in parallel
      final results = await Future.wait([
        getCurrentWeatherUseCase.call(),
        getWeatherForecastUseCase.call(),
      ]);
      
      final currentWeatherResult = results[0];
      final forecastResult = results[1];
      
      // Handle current weather result
      currentWeatherResult.fold(
        (error) {
          Logger.error('Weather error: $error');
          state = WeatherError(error);
        },
        (currentWeather) {
          // Handle forecast result
          forecastResult.fold(
            (error) {
              Logger.error('Forecast error: $error');
              state = WeatherError(error);
            },
            (forecast) {
              Logger.info('Weather loaded successfully');
              state = WeatherLoaded(
                currentWeather: currentWeather as Weather,
                forecast: forecast as List<WeatherForecast>,
              );
            },
          );
        },
      );
    } catch (e) {
      Logger.error('Unexpected error loading weather: $e');
      state = WeatherError('আবহাওয়া তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }
  
  /// Load cached weather data
  Future<void> loadCachedWeather() async {
    state = const WeatherLoading();
    
    try {
      Logger.info('Loading cached weather data...');
      
      final result = await getCachedWeatherUseCase.call();
      
      result.fold(
        (error) {
          Logger.error('Cached weather error: $error');
          state = WeatherError(error);
        },
        (cachedWeather) {
          Logger.info('Cached weather loaded');
          state = WeatherCached(cachedWeather);
        },
      );
    } catch (e) {
      Logger.error('Unexpected error loading cached weather: $e');
      state = const WeatherError('সংরক্ষিত আবহাওয়া তথ্য লোড করতে ব্যর্থ হয়েছে।');
    }
  }
  
  /// Refresh weather data
  Future<void> refresh() async {
    await loadWeather();
  }
}
