import '../../domain/entities/weather.dart';

/// Weather Model for OpenWeatherMap API
class WeatherModel extends Weather {
  const WeatherModel({
    required super.temperature,
    required super.humidity,
    required super.description,
    required super.icon,
    required super.windSpeed,
    required super.pressure,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.cityName,
  });

  /// Create from OpenWeatherMap API response
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final wind = json['wind'];
    final weather = json['weather'][0];

    return WeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      humidity: main['humidity'] as int,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      windSpeed: (wind['speed'] as num).toDouble(),
      pressure: main['pressure'] as int,
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      cityName: json['name'] as String? ?? '',
    );
  }
}
