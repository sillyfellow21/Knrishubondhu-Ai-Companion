import '../../domain/entities/weather.dart';

/// Weather Model for data layer
class WeatherModel extends Weather {
  const WeatherModel({
    required super.temperature,
    required super.humidity,
    required super.weatherCode,
    required super.windSpeed,
    required super.timestamp,
    required super.latitude,
    required super.longitude,
  });
  
  /// Create from API response
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    
    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: current['relative_humidity_2m'] as int,
      weatherCode: current['weather_code'] as int,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      timestamp: DateTime.parse(current['time']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
  
  /// Create from database
  factory WeatherModel.fromDatabase(Map<String, dynamic> map) {
    return WeatherModel(
      temperature: map['temperature'] as double,
      humidity: map['humidity'] as int,
      weatherCode: map['weather_code'] as int,
      windSpeed: map['wind_speed'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
  
  /// Convert to database map
  Map<String, dynamic> toDatabase() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'weather_code': weatherCode,
      'wind_speed': windSpeed,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
