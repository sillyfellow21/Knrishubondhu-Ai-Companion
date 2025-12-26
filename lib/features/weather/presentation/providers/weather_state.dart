import 'package:equatable/equatable.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/weather_forecast.dart';

/// Weather Screen State
abstract class WeatherState extends Equatable {
  const WeatherState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// Loading state
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// Success state with weather data
class WeatherLoaded extends WeatherState {
  final Weather currentWeather;
  final List<WeatherForecast> forecast;
  
  const WeatherLoaded({
    required this.currentWeather,
    required this.forecast,
  });
  
  @override
  List<Object?> get props => [currentWeather, forecast];
}

/// Error state
class WeatherError extends WeatherState {
  final String message;
  
  const WeatherError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Cached data state (offline mode)
class WeatherCached extends WeatherState {
  final Weather cachedWeather;
  
  const WeatherCached(this.cachedWeather);
  
  @override
  List<Object?> get props => [cachedWeather];
}
