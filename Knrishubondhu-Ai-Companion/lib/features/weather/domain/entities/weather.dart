import 'package:equatable/equatable.dart';

/// Current Weather Entity
class Weather extends Equatable {
  final double temperature;
  final int humidity;
  final String description;
  final String icon;
  final double windSpeed;
  final int pressure;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String cityName;

  const Weather({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.pressure,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.cityName,
  });

  @override
  List<Object?> get props => [
        temperature,
        humidity,
        description,
        icon,
        windSpeed,
        pressure,
        feelsLike,
        tempMin,
        tempMax,
        cityName,
      ];
}
