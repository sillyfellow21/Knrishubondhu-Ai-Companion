import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/weather_service.dart';
import '../providers/weather_providers.dart';
import '../providers/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';

/// Weather Dashboard Screen
class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});
  
  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    // Load weather data on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherViewModelProvider.notifier).loadWeather();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherViewModelProvider);
    final weatherService = ref.read(weatherServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আবহাওয়া',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(weatherViewModelProvider.notifier).refresh();
            },
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      body: _buildBody(weatherState, weatherService),
    );
  }
  
  Widget _buildBody(WeatherState state, WeatherService weatherService) {
    if (state is WeatherLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'আবহাওয়া তথ্য লোড হচ্ছে...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    if (state is WeatherError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(weatherViewModelProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('আবার চেষ্টা করুন'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  ref.read(weatherViewModelProvider.notifier).loadCachedWeather();
                },
                icon: const Icon(Icons.storage),
                label: const Text('সংরক্ষিত ডেটা দেখুন'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (state is WeatherCached) {
      return SingleChildScrollView(
        child: Column(
          children: [
            // Offline banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'অফলাইন মোড - সংরক্ষিত ডেটা দেখানো হচ্ছে',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            CurrentWeatherCard(
              weather: state.cachedWeather,
              weatherService: weatherService,
            ),
          ],
        ),
      );
    }
    
    if (state is WeatherLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(weatherViewModelProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Current Weather
              CurrentWeatherCard(
                weather: state.currentWeather,
                weatherService: weatherService,
              ),
              
              // 7-day Forecast
              ForecastList(
                forecasts: state.forecast,
                weatherService: weatherService,
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
    
    return const Center(
      child: Text('আবহাওয়া তথ্য পাওয়া যায়নি'),
    );
  }
}
