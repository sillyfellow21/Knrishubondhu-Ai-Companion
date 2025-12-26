import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/weather_service.dart';
import '../../domain/entities/weather_forecast.dart';

/// Forecast List Widget
class ForecastList extends StatelessWidget {
  final List<WeatherForecast> forecasts;
  final WeatherService weatherService;
  
  const ForecastList({
    super.key,
    required this.forecasts,
    required this.weatherService,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '৭ দিনের পূর্বাভাস',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: forecasts.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final forecast = forecasts[index];
                return _buildForecastItem(context, forecast);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildForecastItem(BuildContext context, WeatherForecast forecast) {
    final dateFormat = DateFormat('EEEE', 'bn_BD');
    final dayName = dateFormat.format(forecast.date);
    final weatherIcon = weatherService.getWeatherIcon(forecast.weatherCode);
    final weatherDesc = weatherService.getWeatherDescription(forecast.weatherCode);
    
    return Row(
      children: [
        // Day name
        SizedBox(
          width: 80,
          child: Text(
            dayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Weather icon
        Text(
          weatherIcon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(width: 8),
        
        // Weather description
        Expanded(
          child: Text(
            weatherDesc,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        
        // Precipitation
        if (forecast.precipitation > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${forecast.precipitation.toStringAsFixed(1)}mm',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 12),
        
        // Temperature range
        Row(
          children: [
            Text(
              '${forecast.maxTemperature.toStringAsFixed(0)}°',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '/',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black38,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${forecast.minTemperature.toStringAsFixed(0)}°',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
