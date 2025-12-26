import 'package:equatable/equatable.dart';

/// Daily Weather Forecast Entity
class WeatherForecast extends Equatable {
  final DateTime date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final double precipitation;
  
  const WeatherForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitation,
  });
  
  @override
  List<Object?> get props => [
    date,
    weatherCode,
    maxTemperature,
    minTemperature,
    precipitation,
  ];
}
