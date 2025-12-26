class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://mifwuugvljzhbuavhnbf.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pZnd1dWd2bGp6aGJ1YXZobmJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0Njg1MTQsImV4cCI6MjA4MjA0NDUxNH0.5rsTyO7jNh1jZvKLIb-1lymtt7L4BKl5RDSzynsTp4s';
  
  // Gemini Configuration
  static const String geminiApiKey = 'AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU';
  
  // App Configuration
  static const String appName = 'KrishiBondhu AI';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = true;
  
  // Database Configuration
  static const String databaseName = 'krishibondhu_ai.db';
  static const int databaseVersion = 1;
  
  // Computed properties
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY';
}
