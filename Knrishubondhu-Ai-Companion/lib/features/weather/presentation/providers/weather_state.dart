import 'package:equatable/equatable.dart';
import '../../domain/entities/weather.dart';

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

  const WeatherLoaded({
    required this.currentWeather,
  });

  @override
  List<Object?> get props => [currentWeather];
}

/// Error state
class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}
