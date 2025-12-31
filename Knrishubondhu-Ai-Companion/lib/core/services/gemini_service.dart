import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import 'perenual_service.dart';

/// Gemini AI Service - Now with Perenual as PRIMARY source
/// Perenual Plant Database is the main data source
/// Gemini AI is used as optional fallback for non-plant or complex queries
class GeminiService {
  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();

  GeminiService._();

  late final GenerativeModel _model;
  ChatSession? _chatSession;
  final List<Content> _chatHistory = [];
  final PerenualService _perenualService = PerenualService();

  /// System instruction for farming expert
  static const String _systemInstruction = '''
আপনি "কৃষিবন্ধু" - একজন অভিজ্ঞ ও বিশ্বস্ত কৃষি বিশেষজ্ঞ AI সহায়ক। আপনার কাজ হলো বাংলাদেশের কৃষকদের সাহায্য করা।

## আপনার বিশেষত্ব:
- ফসল চাষাবাদ (ধান, গম, ভুট্টা, সবজি, ফল)
- রোগ ও পোকামাকড় দমন
- সার ও কীটনাশক ব্যবহার
- আধুনিক কৃষি প্রযুক্তি
- জৈব কৃষি পদ্ধতি
- মাটির স্বাস্থ্য ও পরিচর্যা
- সেচ ব্যবস্থাপনা
- ফসল কাটা ও সংরক্ষণ
- বাজারজাতকরণ পরামর্শ
- আবহাওয়া ভিত্তিক চাষাবাদ

## নিয়মাবলী:
1. সবসময় বাংলায় উত্তর দিন
2. সহজ, প্রাঞ্জল ভাষা ব্যবহার করুন যা গ্রামের কৃষকরা বুঝতে পারবে
3. ব্যবহারিক ও কার্যকর পরামর্শ দিন
4. প্রয়োজনে ধাপে ধাপে ব্যাখ্যা করুন
5. স্থানীয় প্রেক্ষাপট ও বাংলাদেশের আবহাওয়া বিবেচনা করুন
6. নিরাপদ কৃষি পদ্ধতি উৎসাহিত করুন
7. প্রশ্ন বুঝতে না পারলে স্পষ্ট করে জিজ্ঞাসা করুন
8. কৃষি বহির্ভূত প্রশ্নে ভদ্রভাবে জানান যে আপনি শুধু কৃষি বিষয়ে সাহায্য করতে পারবেন
''';

  /// Initialize service
  void initialize() {
    Logger.info('Initializing AI service...');
    Logger.info('Perenual configured: ${AppConfig.isPerenualConfigured}');
    Logger.info('Gemini configured: ${AppConfig.isGeminiConfigured}');

    // Gemini DISABLED - Using Perenual only
    /*
    if (AppConfig.isGeminiConfigured) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppConfig.geminiApiKey,
        systemInstruction: Content.text(_systemInstruction),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );
      _startNewChat();
      Logger.info('Gemini initialized as fallback');
    }
    */

    if (AppConfig.isPerenualConfigured) {
      Logger.info('Perenual initialized as PRIMARY and ONLY source');
    } else {
      Logger.warning('Perenual not configured! Add API key to use chatbot.');
    }
  }

  /// Start a new chat session
  void _startNewChat() {
    _chatHistory.clear();
    _chatSession = _model.startChat(history: _chatHistory);
  }

  /// Send text message - Perenual ONLY (Gemini disabled)
  /// Uses Perenual plant database only
  Future<String> sendMessage(String message) async {
    Logger.info('Processing message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
    
    // Check if plant-related and Perenual is configured
    if (_isPlantRelatedQuery(message) && AppConfig.isPerenualConfigured) {
      try {
        // Try Perenual (ONLY SOURCE)
        final plantResponse = await _getPerenualResponse(message);
        if (plantResponse != null) {
          Logger.info('Responded using Perenual data');
          return plantResponse;
        } else {
          return 'দুঃখিত, এই উদ্ভিদ সম্পর্কে তথ্য পাওয়া যায়নি। অন্য নাম দিয়ে চেষ্টা করুন।';
        }
      } catch (e) {
        Logger.error('Perenual error: $e');
        return 'দুঃখিত, উদ্ভিদ তথ্য লোড করতে ব্যর্থ। ইন্টারনেট সংযোগ পরীক্ষা করুন।';
      }
    }
    
    // Not plant-related or Perenual not configured
    if (!AppConfig.isPerenualConfigured) {
      return 'দুঃখিত, Perenual API key কনফিগার করা হয়নি। অনুগ্রহ করে API key যোগ করুন।';
    }
    
    return 'দুঃখিত, আমি শুধুমাত্র উদ্ভিদ/ফসল সম্পর্কিত প্রশ্নের উত্তর দিতে পারি। (গাছ, ফসল, টমেটো, ধান ইত্যাদি)';
    
    /* GEMINI DISABLED - Uncomment to enable fallback
    // Fallback to Gemini (OPTIONAL)
    if (AppConfig.isGeminiConfigured) {
      try {
        return await _sendWithRetry(() => _sendToGemini(message));
      } catch (e) {
        Logger.error('Gemini fallback failed', error: e);
        return 'দুঃখিত, AI সেবা বর্তমানে উপলব্ধ নেই। অনুগ্রহ করে পরে চেষ্টা করুন।';
      }
    }
    
    return 'দুঃখিত, কোন AI সেবা কনফিগার করা নেই। অনুগ্রহ করে API key যোগ করুন।';
    */
  }

  /// Get response from Perenual database
  Future<String?> _getPerenualResponse(String query) async {
    try {
      // Try to translate Bengali/local names to English for better search
      String searchQuery = _translatePlantName(query);
      
      Logger.info('Searching Perenual for: $searchQuery (original: $query)');
      
      final plants = await _perenualService.searchPlants(searchQuery);
      
      if (plants.isEmpty) {
        // Try original query if translation failed
        if (searchQuery != query) {
          Logger.info('No results, trying original query');
          final plantsOriginal = await _perenualService.searchPlants(query);
          if (plantsOriginal.isNotEmpty) {
            return _formatPlantResponse(plantsOriginal.first);
          }
        }
        Logger.info('No plants found in Perenual for: $query');
        return null;
      }
      
      return _formatPlantResponse(plants.first);
    } catch (e) {
      Logger.error('Error getting Perenual response', error: e);
      return null;
    }
  }

  /// Translate Bengali/local plant names to English
  String _translatePlantName(String query) {
    final translations = {
      'টমেটো': 'tomato',
      'টমাটো': 'tomato',
      'ধান': 'rice',
      'চাল': 'rice',
      'ভুট্টা': 'corn',
      'ভুট্টা': 'maize',
      'আলু': 'potato',
      'গম': 'wheat',
      'পাট': 'jute',
      'আখ': 'sugarcane',
      'লাউ': 'bottle gourd',
      'মিষ্টি আলু': 'sweet potato',
      'বেগুন': 'eggplant',
      'মরিচ': 'chili',
      'পেঁয়াজ': 'onion',
      'রসুন': 'garlic',
      'শাক': 'spinach',
      'আম': 'mango',
      'কলা': 'banana',
      'পেঁপে': 'papaya',
      'লিচু': 'lychee',
      'আনারস': 'pineapple',
      'গাজর': 'carrot',
      'শসা': 'cucumber',
      'কুমড়া': 'pumpkin',
    };
    
    String lowerQuery = query.toLowerCase();
    
    // Check if query contains any Bengali plant name
    for (var entry in translations.entries) {
      if (lowerQuery.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    return query; // Return original if no translation found
  }

  /// Format plant response from Perenual data with detailed cultivation info
  String _formatPlantResponse(Map<String, dynamic> plant) {
    final name = plant['common_name'] ?? 'Unknown';
    final scientificName = plant['scientific_name'] ?? '';
    final watering = plant['watering'] ?? 'Moderate';
    final sunlight = plant['sunlight']?.join(', ') ?? 'Full sun';
    final cycle = plant['cycle'] ?? 'Annual';
    
    // Build comprehensive cultivation guide
    String response = '🌱 **$name চাষাবাদ সম্পূর্ণ গাইড**\n';
    
    if (scientificName.isNotEmpty) {
      response += '🔬 বৈজ্ঞানিক নাম: $scientificName\n';
    }
    
    response += '\n📋 **মূল তথ্য:**';
    response += '\n🔄 জীবনচক্র: $cycle';
    response += '\n☀️ সূর্যালোক: $sunlight';
    response += '\n💧 পানির চাহিদা: $watering';
    
    // Add detailed cultivation steps based on plant type
    response += _getDetailedCultivationSteps(name.toLowerCase(), watering, sunlight, cycle);
    
    // Add watering frequency if available
    if (plant['watering_period'] != null) {
      response += '\n💦 পানি দেওয়ার সময়: ${plant['watering_period']}';
    }
    
    response += '\n\n✅ তথ্য সূত্র: Perenual Plant Database + কৃষি বিশেষজ্ঞ জ্ঞান';
    
    return response;
  }

  /// Get detailed cultivation steps based on plant characteristics
  String _getDetailedCultivationSteps(String plantName, String watering, String sunlight, String cycle) {
    String steps = '\n\n🌾 **চাষাবাদ পদ্ধতি:**';
    
    // Soil preparation
    steps += '\n\n1️⃣ **মাটি প্রস্তুতি:**';
    steps += '\n   • উর্বর দো-আঁশ মাটি সবচেয়ে ভালো';
    steps += '\n   • মাটিতে জৈব সার মিশিয়ে নিন';
    steps += '\n   • pH লেভেল: ৬.০-৭.০ রাখুন';
    
    // Planting
    steps += '\n\n2️⃣ **রোপণ:**';
    if (cycle.toLowerCase().contains('annual') || cycle.toLowerCase().contains('perennial')) {
      steps += '\n   • বীজ বা চারা রোপণ করুন';
      steps += '\n   • সারি থেকে সারির দূরত্ব: ৪৫-৬০ সেমি';
      steps += '\n   • গাছ থেকে গাছের দূরত্ব: ৩০-৪৫ সেমি';
    }
    
    // Watering guide
    steps += '\n\n3️⃣ **পানি সেচ:**';
    if (watering.toLowerCase().contains('frequent') || watering.toLowerCase().contains('average')) {
      steps += '\n   • নিয়মিত পানি দিন (সপ্তাহে ৩-৪ বার)';
      steps += '\n   • মাটি সবসময় ঈষৎ ভেজা রাখুন';
      steps += '\n   • ফুল ও ফল ধরার সময় বেশি পানি দিন';
    } else if (watering.toLowerCase().contains('minimum')) {
      steps += '\n   • কম পানির প্রয়োজন';
      steps += '\n   • শুধু মাটি শুকিয়ে গেলে পানি দিন';
    }
    
    // Sunlight
    steps += '\n\n4️⃣ **আলো:**';
    if (sunlight.toLowerCase().contains('full sun')) {
      steps += '\n   • দিনে ৬-৮ ঘণ্টা সরাসরি সূর্যালোক প্রয়োজন';
      steps += '\n   • খোলা জায়গায় চাষ করুন';
    } else if (sunlight.toLowerCase().contains('part')) {
      steps += '\n   • আংশিক ছায়াতেও জন্মায়';
      steps += '\n   • ৪-৬ ঘণ্টা সূর্যালোক যথেষ্ট';
    }
    
    // Fertilizer
    steps += '\n\n5️⃣ **সার প্রয়োগ:**';
    steps += '\n   • রোপণের ১৫ দিন পর প্রথম সার দিন';
    steps += '\n   • NPK সার (১০:২৬:২৬) ব্যবহার করুন';
    steps += '\n   • জৈব সার মাসে একবার প্রয়োগ করুন';
    steps += '\n   • ইউরিয়া প্রতি ১৫ দিনে স্প্রে করুন';
    
    // Pest control
    steps += '\n\n6️⃣ **রোগ ও পোকা দমন:**';
    steps += '\n   • নিম তেল স্প্রে করুন (জৈব পদ্ধতি)';
    steps += '\n   • আক্রান্ত পাতা তুলে ফেলুন';
    steps += '\n   • প্রয়োজনে কীটনাশক ব্যবহার করুন';
    steps += '\n   • সকালে গাছ পরীক্ষা করুন';
    
    // Harvesting
    if (cycle.toLowerCase().contains('annual')) {
      steps += '\n\n7️⃣ **ফসল তোলা:**';
      steps += '\n   • ফল পরিপক্ক হলে তুলুন';
      steps += '\n   • সকালে ফসল সংগ্রহ করা ভালো';
      steps += '\n   • নিয়মিত তুললে বেশি ফলন পাবেন';
    }
    
    // Special care for common crops
    if (plantName.contains('tomato') || plantName.contains('টমেটো')) {
      steps += '\n\n⚠️ **বিশেষ যত্ন (টমেটো):**';
      steps += '\n   • ঠেক/খুঁটি দিয়ে গাছ বাঁধুন';
      steps += '\n   • পার্শ্ব শাখা ছাঁটাই করুন';
      steps += '\n   • ক্যালসিয়াম স্প্রে করুন (ফাটা রোধে)';
    } else if (plantName.contains('rice') || plantName.contains('ধান')) {
      steps += '\n\n⚠️ **বিশেষ যত্ন (ধান):**';
      steps += '\n   • জমিতে ২-৩ ইঞ্চি পানি ধরে রাখুন';
      steps += '\n   • আগাছা নিয়ন্ত্রণ করুন';
      steps += '\n   • কুশি বের হলে ইউরিয়া দিন';
    } else if (plantName.contains('corn') || plantName.contains('maize') || plantName.contains('ভুট্টা')) {
      steps += '\n\n⚠️ **বিশেষ যত্ন (ভুট্টা):**';
      steps += '\n   • গোড়ায় মাটি তুলে দিন';
      steps += '\n   • ফুল আসার সময় বেশি পানি দিন';
      steps += '\n   • পাখি থেকে রক্ষা করুন';
    }
    
    return steps;
  }

  /// Send to Gemini (DISABLED - commented out)
  /*
  Future<String> _sendToGemini(String message) async {
    Logger.info('Using Gemini as fallback');
    
    // Ensure chat session exists
    _chatSession ??= _model.startChat(history: _chatHistory);

    // Send message through chat session
    final response = await _chatSession!.sendMessage(Content.text(message));

    final responseText = response.text ?? 'দুঃখিত, আমি উত্তর দিতে পারছি না।';
    Logger.info('Received response from Gemini');

    return responseText;
  }
  */

  /// Check if query is plant-related
  bool _isPlantRelatedQuery(String message) {
    final plantKeywords = [
      // Bengali - General
      'গাছ', 'ফসল', 'চাষ', 'বীজ', 'চারা', 'রোপণ',
      // Bengali - Crops
      'ধান', 'গম', 'ভুট্টা', 'পাট', 'আখ',
      // Bengali - Vegetables
      'টমেটো', 'আলু', 'শাক', 'লাউ', 'মিষ্টি আলু', 'বেগুন', 'মরিচ', 'পেঁয়াজ', 'রসুন',
      // Bengali - Fruits
      'আম', 'কলা', 'পেঁপে', 'লিচু', 'আনারস',
      // English - General
      'plant', 'crop', 'grow', 'seed', 'farming', 'cultivation', 'harvest'
    ];
    final lowerMessage = message.toLowerCase();
    return plantKeywords.any((keyword) => lowerMessage.contains(keyword.toLowerCase()));
  }

  /// Fetch plant data from Perenual for the query
  Future<String?> _fetchPlantDataForQuery(String query) async {
    try {
      // Extract potential plant name (simple approach)
      final plants = await _perenualService.searchPlants(query);
      if (plants.isNotEmpty) {
        final firstPlant = plants.first;
        return _perenualService.formatPlantInfoForAI(firstPlant);
      }
    } catch (e) {
      Logger.error('Error fetching Perenual data', error: e);
    }
    return null;
  }

  /// Retry logic with exponential backoff for rate limiting
  Future<String> _sendWithRetry(Future<String> Function() operation,
      {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        final errorMessage = e.toString().toLowerCase();
        final isRateLimitError = errorMessage.contains('429') ||
            errorMessage.contains('quota') ||
            errorMessage.contains('rate limit');

        if (isRateLimitError && attempt < maxRetries - 1) {
          // Exponential backoff: 2^attempt seconds
          final delaySeconds = (1 << attempt); // 1, 2, 4 seconds
          Logger.warning(
              'Rate limit hit, retrying in $delaySeconds seconds (attempt ${attempt + 1}/$maxRetries)');
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        }

        Logger.error('Error sending message to Gemini', error: e);

        if (isRateLimitError) {
          return 'দুঃখিত, অনেক বেশি অনুরোধ হয়েছে। অনুগ্রহ করে কিছুক্ষণ পর আবার চেষ্টা করুন।';
        }

        return 'দুঃখিত, একটি ত্রুটি হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
      }
    }
    return 'দুঃখিত, একটি ত্রুটি হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
  }

  /// Send message with image to Gemini with retry logic
  Future<String> sendMessageWithImage({
    required String message,
    required File imageFile,
  }) async {
    return _sendWithRetry(
        () => _sendMessageWithImageInternal(message, imageFile));
  }

  /// Internal method to send message with image
  Future<String> _sendMessageWithImageInternal(
      String message, File imageFile) async {
    Logger.info('Sending message with image to Gemini');

    final imageBytes = await imageFile.readAsBytes();
    final imagePrompt = _buildImageAnalysisPrompt(message);

    // Create multimodal content
    final content = Content.multi([
      TextPart(imagePrompt),
      DataPart('image/jpeg', imageBytes),
    ]);

    // Send through chat session for context
    _chatSession ??= _model.startChat(history: _chatHistory);
    final response = await _chatSession!.sendMessage(content);

    final responseText =
        response.text ?? 'দুঃখিত, আমি ছবি বিশ্লেষণ করতে পারছি না।';

    Logger.info('Received response with image from Gemini');
    return responseText;
  }

  /// Send message with image bytes to Gemini with retry logic
  Future<String> sendMessageWithImageBytes({
    required String message,
    required Uint8List imageBytes,
  }) async {
    return _sendWithRetry(
        () => _sendMessageWithImageBytesInternal(message, imageBytes));
  }

  /// Internal method to send message with image bytes
  Future<String> _sendMessageWithImageBytesInternal(
      String message, Uint8List imageBytes) async {
    Logger.info('Sending message with image bytes to Gemini');

    final imagePrompt = _buildImageAnalysisPrompt(message);

    // Create multimodal content
    final content = Content.multi([
      TextPart(imagePrompt),
      DataPart('image/jpeg', imageBytes),
    ]);

    // Send through chat session for context
    _chatSession ??= _model.startChat(history: _chatHistory);
    final response = await _chatSession!.sendMessage(content);

    final responseText =
        response.text ?? 'দুঃখিত, আমি ছবি বিশ্লেষণ করতে পারছি না।';

    Logger.info('Received response with image bytes from Gemini');
    return responseText;
  }

  /// Build prompt for image analysis (farming context)
  String _buildImageAnalysisPrompt(String userMessage) {
    if (userMessage.trim().isEmpty) {
      return 'এই ছবিটি বিশ্লেষণ করুন। যদি এটি ফসল, গাছ, পোকা, রোগ, মাটি বা কৃষি সংক্রান্ত কিছু হয় তাহলে বিস্তারিত পরামর্শ দিন।';
    }
    return userMessage;
  }

  /// Clear chat history and start fresh
  void clearChat() {
    _startNewChat();
    Logger.info('Chat history cleared');
  }

  /// Check if service is initialized
  bool get isInitialized => AppConfig.isGeminiConfigured;
}
