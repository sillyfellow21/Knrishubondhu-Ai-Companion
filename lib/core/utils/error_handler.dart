import 'dart:async';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'একটি অজানা ত্রুটি ঘটেছে';
    
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('socket') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'ইন্টারনেট সংযোগ নেই। দয়া করে আপনার সংযোগ পরীক্ষা করুন।';
    }
    
    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'অনুরোধ সময় শেষ হয়ে গেছে। আবার চেষ্টা করুন।';
    }
    
    // Auth errors
    if (errorString.contains('auth') || 
        errorString.contains('unauthorized') ||
        errorString.contains('credential')) {
      return 'লগইন করুন অথবা পুনরায় লগইন করুন।';
    }
    
    // Database errors
    if (errorString.contains('database') || errorString.contains('sql')) {
      return 'ডেটা সংরক্ষণে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
    }
    
    // Permission errors
    if (errorString.contains('permission')) {
      return 'অনুমতি প্রয়োজন। সেটিংস থেকে অনুমতি দিন।';
    }
    
    // Storage errors
    if (errorString.contains('storage') || errorString.contains('space')) {
      return 'পর্যাপ্ত স্টোরেজ নেই। কিছু ফাইল মুছে ফেলুন।';
    }
    
    // Rate limit
    if (errorString.contains('rate') || errorString.contains('limit')) {
      return 'অনেক বেশি অনুরোধ। কিছুক্ষণ পরে চেষ্টা করুন।';
    }
    
    return 'একটি ত্রুটি ঘটেছে। আবার চেষ্টা করুন।';
  }
  
  static void handleError(dynamic error, StackTrace? stackTrace) {
    // Log error for debugging
    print('Error: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
    
    // In production, you might want to send to error tracking service
    // Example: Sentry.captureException(error, stackTrace: stackTrace);
  }
  
  static Future<T?> tryCatch<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return defaultValue;
    }
  }
}
