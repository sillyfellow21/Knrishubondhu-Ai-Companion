class SecurityHelper {
  // Rate limiting storage
  static final Map<String, List<DateTime>> _rateLimits = {};
  
  // Check rate limit (max requests in time window)
  static bool checkRateLimit(
    String key, {
    int maxRequests = 10,
    Duration window = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();
    
    if (!_rateLimits.containsKey(key)) {
      _rateLimits[key] = [now];
      return true;
    }
    
    final requests = _rateLimits[key]!;
    
    // Remove old requests outside window
    requests.removeWhere((time) => now.difference(time) > window);
    
    if (requests.length >= maxRequests) {
      return false;
    }
    
    requests.add(now);
    return true;
  }
  
  // Clear rate limit for key
  static void clearRateLimit(String key) {
    _rateLimits.remove(key);
  }
  
  // Sensitive data masking (for logs)
  static String maskSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars) {
      return '****';
    }
    
    final visible = data.substring(0, visibleChars);
    return '$visible${'*' * (data.length - visibleChars)}';
  }
  
  // Check if string contains SQL injection patterns
  static bool hasSQLInjectionPattern(String input) {
    final dangerousPatterns = [
      RegExp(r"(\bUNION\b|\bSELECT\b|\bDROP\b|\bDELETE\b|\bINSERT\b|\bUPDATE\b)", caseSensitive: false),
      RegExp(r'''[;'"\]'''),
      RegExp(r'--'),
      RegExp(r'/\*.*\*/'),
    ];
    
    return dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  // Check if string contains XSS patterns
  static bool hasXSSPattern(String input) {
    final dangerousPatterns = [
      RegExp(r"<script", caseSensitive: false),
      RegExp(r"javascript:", caseSensitive: false),
      RegExp(r"onerror\s*=", caseSensitive: false),
      RegExp(r"onload\s*=", caseSensitive: false),
    ];
    
    return dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  // Validate file upload (image only)
  static bool isValidImageFile(String filename) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final lowerFilename = filename.toLowerCase();
    return validExtensions.any((ext) => lowerFilename.endsWith(ext));
  }
  
  // Maximum file size (5MB)
  static const maxFileSize = 5 * 1024 * 1024;
  
  // Check file size
  static bool isValidFileSize(int bytes) {
    return bytes > 0 && bytes <= maxFileSize;
  }
}
