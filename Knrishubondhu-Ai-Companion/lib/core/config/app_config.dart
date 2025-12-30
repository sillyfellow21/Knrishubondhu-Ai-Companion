class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  // Gemini Configuration
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  // App Configuration
  static const String appName = 'KrishiBondhu AI';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = true;

  // Database Configuration
  static const String databaseName = 'krishibondhu_ai.db';
  static const int databaseVersion = 4;

  // Computed properties
  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';
}
