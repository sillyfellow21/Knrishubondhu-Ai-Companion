import 'package:equatable/equatable.dart';

/// Current Weather Entity
class Weather extends Equatable {
  final double temperature;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  
  const Weather({
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });
  
  @override
  List<Object?> get props => [
    temperature,
    humidity,
    weatherCode,
    windSpeed,
    timestamp,
    latitude,
    longitude,
  ];
}
