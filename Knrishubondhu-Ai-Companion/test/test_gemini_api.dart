import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // Test Gemini API Key
  const apiKey = 'AIzaSyAK8-yBQYPcZ99KWakv-c2agrocUSENYgA';
  
  print('🔍 Testing Gemini API...');
  print('API Key: ${apiKey.substring(0, 20)}...');
  print('');
  
  try {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    
    print('✅ Model created successfully');
    print('📤 Sending test message...');
    
    final response = await model.generateContent([
      Content.text('Say hello in Bengali')
    ]);
    
    print('✅ SUCCESS! API is working!');
    print('📨 Response: ${response.text}');
    print('');
    print('✨ Your Gemini API is configured correctly!');
  } catch (e) {
    print('❌ ERROR: $e');
    print('');
    print('🔧 Solutions:');
    print('1. Get NEW API key from: https://aistudio.google.com/app/apikey');
    print('2. Check internet connection');
    print('3. Verify API is enabled in Google Cloud Console');
    print('4. Check if billing is required');
  }
}
