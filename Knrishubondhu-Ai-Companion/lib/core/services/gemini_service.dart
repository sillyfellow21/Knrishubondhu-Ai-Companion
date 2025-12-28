import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Gemini AI Service - Centralized service for all Gemini AI operations
/// Specialized as a Farming Expert AI Assistant
class GeminiService {
  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();

  GeminiService._();

  late final GenerativeModel _model;
  ChatSession? _chatSession;
  final List<Content> _chatHistory = [];

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

  /// Initialize Gemini service
  void initialize() {
    Logger.info('Initializing Gemini AI service (Farming Expert)...');

    // Use gemini-1.5-flash for both text and vision (multimodal)
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: Content.text(_systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );

    // Start a new chat session
    _startNewChat();

    Logger.info('Gemini AI service initialized as Farming Expert');
  }

  /// Start a new chat session
  void _startNewChat() {
    _chatHistory.clear();
    _chatSession = _model.startChat(history: _chatHistory);
  }

  /// Send text message to Gemini with retry logic
  Future<String> sendMessage(String message) async {
    return _sendWithRetry(() => _sendMessageInternal(message));
  }

  /// Internal method to send text message using chat session
  Future<String> _sendMessageInternal(String message) async {
    Logger.info(
        'Sending message to Gemini: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

    // Ensure chat session exists
    _chatSession ??= _model.startChat(history: _chatHistory);

    // Send message through chat session to maintain context
    final response = await _chatSession!.sendMessage(Content.text(message));

    final responseText = response.text ?? 'দুঃখিত, আমি উত্তর দিতে পারছি না।';
    Logger.info('Received response from Gemini');

    return responseText;
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
