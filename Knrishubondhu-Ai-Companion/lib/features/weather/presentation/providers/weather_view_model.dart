import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';
import 'weather_state.dart';

/// Weather View Model
class WeatherViewModel extends StateNotifier<WeatherState> {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;

  WeatherViewModel({
    required this.getCurrentWeatherUseCase,
  }) : super(const WeatherInitial());

  /// Load weather data
  Future<void> loadWeather() async {
    state = const WeatherLoading();

    try {
      Logger.info('Loading weather...');

      final result = await getCurrentWeatherUseCase.call();

      result.fold(
        (error) {
          Logger.error('Weather error: $error');
          state = WeatherError(error);
        },
        (weather) {
          Logger.info('Weather loaded successfully');
          state = WeatherLoaded(currentWeather: weather);
        },
      );
    } catch (e) {
      Logger.error('Unexpected error: $e');
      state = const WeatherError('আবহাওয়া তথ্য লোড করতে ব্যর্থ');
    }
  }

  /// Refresh weather data
  Future<void> refresh() async {
    await loadWeather();
  }

  /// Get farming tips based on weather conditions
  List<String> getFarmingTips(double temp, int humidity, String description) {
    List<String> tips = [];

    // Temperature based tips
    if (temp > 35) {
      tips.add('🌡️ অতিরিক্ত গরম: ফসলে বেশি করে পানি দিন');
      tips.add('🌾 দুপুরবেলা সেচ এড়িয়ে চলুন');
      tips.add('🥬 শাকসবজি ছায়াযুক্ত জায়গায় রাখুন');
    } else if (temp > 30) {
      tips.add('☀️ গরম আবহাওয়া: নিয়মিত সেচ দিন');
      tips.add('🌱 গাছের গোড়ায় মালচিং করুন');
    } else if (temp < 15) {
      tips.add('❄️ ঠান্ডা আবহাওয়া: শীতকালীন ফসল রোপণের উপযুক্ত সময়');
      tips.add('🥔 আলু, টমেটো চাষের ভালো সময়');
    } else {
      tips.add('🌤️ আদর্শ তাপমাত্রা: বেশিরভাগ ফসলের জন্য উপযুক্ত');
    }

    // Humidity based tips
    if (humidity > 80) {
      tips.add('💧 উচ্চ আর্দ্রতা: ছত্রাকনাশক স্প্রে করুন');
      tips.add('🍄 রোগ-পোকার আক্রমণ থেকে সতর্ক থাকুন');
    } else if (humidity < 40) {
      tips.add('🏜️ কম আর্দ্রতা: ঘন ঘন পানি দিন');
      tips.add('💦 স্প্রিংকলার ব্যবহার করুন');
    }

    // Weather condition based tips
    String lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('rain') || lowerDesc.contains('বৃষ্টি')) {
      tips.add('🌧️ বৃষ্টির পূর্বাভাস: জমিতে পানি জমতে দেবেন না');
      tips.add('☔ নিকাশ ব্যবস্থা পরীক্ষা করুন');
      tips.add('🚜 কীটনাশক স্প্রে করবেন না');
    } else if (lowerDesc.contains('clear') || lowerDesc.contains('পরিষ্কার')) {
      tips.add('☀️ স্বচ্ছ আকাশ: কীটনাশক স্প্রে করার ভালো সময়');
      tips.add('🌾 ধান শুকানোর উপযুক্ত আবহাওয়া');
    } else if (lowerDesc.contains('cloud') || lowerDesc.contains('মেঘ')) {
      tips.add('☁️ মেঘলা আবহাওয়া: সার প্রয়োগের ভালো সময়');
      tips.add('🌱 চারা রোপণের উপযুক্ত');
    }

    // General tips
    tips.add('📱 নিয়মিত আবহাওয়া পরীক্ষা করুন');
    tips.add('🌾 মৌসুম অনুযায়ী ফসল নির্বাচন করুন');

    return tips;
  }
}
