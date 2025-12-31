import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Perenual Plant API Service
/// Provides plant species data, care guides, and disease information
class PerenualService {
  static const String _baseUrl = 'https://perenual.com/api';

  /// Search for plants by name
  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    if (AppConfig.perenualApiKey.isEmpty || 
        AppConfig.perenualApiKey == 'YOUR_PERENUAL_API_KEY_HERE') {
      throw Exception('Perenual API key not configured');
    }

    try {
      final uri = Uri.parse('$_baseUrl/species-list').replace(
        queryParameters: {
          'key': AppConfig.perenualApiKey,
          'q': query,
        },
      );

      Logger.info('Searching plants: $query');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Plants found: ${data['data']?.length ?? 0}');
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Perenual API key');
      } else {
        throw Exception('Failed to fetch plant data');
      }
    } catch (e) {
      Logger.error('Perenual API error', error: e);
      rethrow;
    }
  }

  /// Get plant details by ID
  Future<Map<String, dynamic>> getPlantDetails(int plantId) async {
    if (AppConfig.perenualApiKey.isEmpty || 
        AppConfig.perenualApiKey == 'YOUR_PERENUAL_API_KEY_HERE') {
      throw Exception('Perenual API key not configured');
    }

    try {
      final uri = Uri.parse('$_baseUrl/species/details/$plantId').replace(
        queryParameters: {
          'key': AppConfig.perenualApiKey,
        },
      );

      Logger.info('Fetching plant details: $plantId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Plant details fetched successfully');
        return data;
      } else {
        throw Exception('Failed to fetch plant details');
      }
    } catch (e) {
      Logger.error('Perenual API error', error: e);
      rethrow;
    }
  }

  /// Get plant care guide
  Future<Map<String, dynamic>> getPlantCareGuide(int plantId) async {
    if (AppConfig.perenualApiKey.isEmpty || 
        AppConfig.perenualApiKey == 'YOUR_PERENUAL_API_KEY_HERE') {
      throw Exception('Perenual API key not configured');
    }

    try {
      final uri = Uri.parse('$_baseUrl/species-care-guide-list').replace(
        queryParameters: {
          'key': AppConfig.perenualApiKey,
          'species_id': plantId.toString(),
        },
      );

      Logger.info('Fetching care guide for plant: $plantId');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Care guide fetched successfully');
        return data;
      } else {
        throw Exception('Failed to fetch care guide');
      }
    } catch (e) {
      Logger.error('Perenual API error', error: e);
      rethrow;
    }
  }

  /// Format plant info for AI context
  String formatPlantInfoForAI(Map<String, dynamic> plantData) {
    final name = plantData['common_name'] ?? 'Unknown';
    final scientificName = plantData['scientific_name'] ?? '';
    final watering = plantData['watering'] ?? 'Unknown';
    final sunlight = plantData['sunlight']?.join(', ') ?? 'Unknown';
    
    return '''
Plant Information:
- Common Name: $name
- Scientific Name: $scientificName
- Watering: $watering
- Sunlight: $sunlight
''';
  }
}
