class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://anozsiaikrftgxhsgooo.supabase.co';
  static const String supabaseAnonKey ='sb_publishable_4-35Y2vQGQexCP1_CwKd_g_RSIJJB5V'
      '';

  // Gemini Configuration
  static const String geminiApiKey = 'AIzaSyCuFSL0bFvUDLZKaeXV21nvVtyAbCempV8';

  // App Configuration
  static const String appName = 'KrishiBondhu AI';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = true;

  // Database Configuration
  static const String databaseName = 'krishibondhu_ai.db';
  static const int databaseVersion = 4;

  // Computed properties
  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY';
}
