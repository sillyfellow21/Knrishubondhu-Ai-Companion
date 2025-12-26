import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Gemini AI Service - Centralized service for all Gemini AI operations
class GeminiService {
  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();

  GeminiService._();

  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  /// Initialize Gemini service
  void initialize() {
    Logger.info('Initializing Gemini AI service...');

    // Text-only model
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: AppConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );

    // Vision model (text + image)
    _visionModel = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: AppConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 0.9,
        maxOutputTokens: 1024,
      ),
    );

    Logger.info('Gemini AI service initialized');
  }

  /// Send text message to Gemini
  Future<String> sendMessage(String message) async {
    try {
      Logger.info('Sending message to Gemini: ${message.substring(0, 50)}...');

      final prompt = _buildPrompt(message);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text ?? 'দুঃখিত, আমি উত্তর দিতে পারছি না।';
      Logger.info('Received response from Gemini');

      return responseText;
    } catch (e) {
      Logger.error('Error sending message to Gemini', error: e);
      return 'দুঃখিত, একটি ত্রুটি হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
    }
  }

  /// Send message with image to Gemini
  Future<String> sendMessageWithImage({
    required String message,
    required File imageFile,
  }) async {
    try {
      Logger.info('Sending message with image to Gemini');

      final imageBytes = await imageFile.readAsBytes();
      final prompt = _buildPromptWithImage(message);

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      final responseText = response.text ?? 'দুঃখিত, আমি ছবি বিশ্লেষণ করতে পারছি না।';

      Logger.info('Received response with image from Gemini');
      return responseText;
    } catch (e) {
      Logger.error('Error sending message with image to Gemini', error: e);
      return 'দুঃখিত, ছবি বিশ্লেষণে ত্রুটি হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
    }
  }

  /// Send message with image bytes to Gemini
  Future<String> sendMessageWithImageBytes({
    required String message,
    required Uint8List imageBytes,
  }) async {
    try {
      Logger.info('Sending message with image bytes to Gemini');

      final prompt = _buildPromptWithImage(message);

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _visionModel.generateContent(content);
      final responseText = response.text ?? 'দুঃখিত, আমি ছবি বিশ্লেষণ করতে পারছি না।';

      Logger.info('Received response with image bytes from Gemini');
      return responseText;
    } catch (e) {
      Logger.error('Error sending message with image bytes to Gemini', error: e);
      return 'দুঃখিত, ছবি বিশ্লেষণে ত্রুটি হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
    }
  }

  /// Build Bengali prompt for agriculture context
  String _buildPrompt(String userMessage) {
    return '''
আপনি একজন বিশেষজ্ঞ কৃষি পরামর্শদাতা। আপনি বাংলাদেশের কৃষকদের সাহায্য করেন।

নিয়মাবলী:
- সবসময় বাংলায় উত্তর দিন
- সহজ ও স্পষ্ট ভাষা ব্যবহার করুন
- ব্যবহারিক ও কার্যকর পরামর্শ দিন
- প্রয়োজনে ধাপে ধাপে ব্যাখ্যা করুন
- স্থানীয় প্রেক্ষাপট বিবেচনা করুন

কৃষকের প্রশ্ন: $userMessage

উত্তর:''';
  }

  /// Build Bengali prompt for image analysis
  String _buildPromptWithImage(String userMessage) {
    return '''
আপনি একজন বিশেষজ্ঞ কৃষি পরামর্শদাতা। আপনি ছবি দেখে ফসল, পোকামাকড়, রোগ, মাটি ইত্যাদি বিশ্লেষণ করেন।

নির্দেশনা:
- ছবিতে কী দেখছেন তা বাংলায় বর্ণনা করুন
- যদি কোনো সমস্যা দেখেন, তা চিহ্নিত করুন
- সমাধান বা পরামর্শ দিন
- সহজ ও বোধগম্য ভাষা ব্যবহার করুন

কৃষকের বার্তা: $userMessage

বিশ্লেষণ:''';
  }

  /// Check if service is initialized
  bool get isInitialized => AppConfig.isGeminiConfigured;
}
