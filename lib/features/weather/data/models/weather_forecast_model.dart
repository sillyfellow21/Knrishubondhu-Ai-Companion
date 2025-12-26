import '../../domain/entities/weather_forecast.dart';

/// Weather Forecast Model for data layer
class WeatherForecastModel extends WeatherForecast {
  const WeatherForecastModel({
    required super.date,
    required super.weatherCode,
    required super.maxTemperature,
    required super.minTemperature,
    required super.precipitation,
  });
  
  /// Create from API response (single day)
  factory WeatherForecastModel.fromJson({
    required String date,
    required int weatherCode,
    required double maxTemp,
    required double minTemp,
    required double precipitation,
  }) {
    return WeatherForecastModel(
      date: DateTime.parse(date),
      weatherCode: weatherCode,
      maxTemperature: maxTemp,
      minTemperature: minTemp,
      precipitation: precipitation,
    );
  }
  
  /// Parse multiple days from API response
  static List<WeatherForecastModel> fromApiResponse(Map<String, dynamic> json) {
    final daily = json['daily'];
    final dates = daily['time'] as List;
    final weatherCodes = daily['weather_code'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final minTemps = daily['temperature_2m_min'] as List;
    final precipitations = daily['precipitation_sum'] as List;
    
    final forecasts = <WeatherForecastModel>[];
    
    for (int i = 0; i < dates.length; i++) {
      forecasts.add(
        WeatherForecastModel.fromJson(
          date: dates[i] as String,
          weatherCode: weatherCodes[i] as int,
          maxTemp: (maxTemps[i] as num).toDouble(),
          minTemp: (minTemps[i] as num).toDouble(),
          precipitation: (precipitations[i] as num).toDouble(),
        ),
      );
    }
    
    return forecasts;
  }
}
