import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/weather_service.dart';
import '../../domain/entities/weather.dart';

/// Current Weather Card Widget
class CurrentWeatherCard extends StatelessWidget {
  final Weather weather;
  final WeatherService weatherService;
  
  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.weatherService,
  });
  
  @override
  Widget build(BuildContext context) {
    final weatherDesc = weatherService.getWeatherDescription(weather.weatherCode);
    final weatherIcon = weatherService.getWeatherIcon(weather.weatherCode);
    final dateFormat = DateFormat('EEEE, d MMMM', 'bn_BD');
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withAlpha((0.7 * 255).toInt()),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Text(
                dateFormat.format(weather.timestamp),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Weather icon and temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Temperature
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.temperature.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '°C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        weatherDesc,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  // Weather Icon
                  Text(
                    weatherIcon,
                    style: const TextStyle(fontSize: 80),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(color: Colors.white38),
              const SizedBox(height: 16),
              
              // Additional info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    icon: Icons.water_drop,
                    label: 'আর্দ্রতা',
                    value: '${weather.humidity}%',
                  ),
                  _buildInfoItem(
                    icon: Icons.air,
                    label: 'বাতাসের গতি',
                    value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
