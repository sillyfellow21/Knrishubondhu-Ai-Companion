class PerformanceOptimizer {
  // Cache for expensive computations
  static final Map<String, dynamic> _cache = {};
  
  // Get from cache or compute
  static T getOrCompute<T>(String key, T Function() compute) {
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }
    
    final result = compute();
    _cache[key] = result;
    return result;
  }
  
  // Clear specific cache
  static void clearCache(String key) {
    _cache.remove(key);
  }
  
  // Clear all cache
  static void clearAllCache() {
    _cache.clear();
  }
  
  // Debounce function calls
  static void Function() debounce(
    void Function() action,
    Duration duration,
  ) {
    DateTime? lastActionTime;
    
    return () {
      final now = DateTime.now();
      if (lastActionTime == null || 
          now.difference(lastActionTime!) > duration) {
        lastActionTime = now;
        action();
      }
    };
  }
  
  // Throttle function calls
  static void Function() throttle(
    void Function() action,
    Duration duration,
  ) {
    bool isThrottled = false;
    
    return () {
      if (!isThrottled) {
        action();
        isThrottled = true;
        Future.delayed(duration, () => isThrottled = false);
      }
    };
  }
}

// Database query optimization
class DatabaseOptimizer {
  // Batch insert helper
  static Future<void> batchInsert(
    Future<void> Function() operation,
    int batchSize,
  ) async {
    // Implementation depends on specific use case
    await operation();
  }
  
  // Query result cache duration
  static const cacheDuration = Duration(minutes: 5);
  
  // Index suggestions for tables
  static const Map<String, List<String>> indexSuggestions = {
    'users': ['email', 'phone'],
    'lands': ['user_id', 'created_at'],
    'loans': ['user_id', 'status', 'due_date'],
    'chat_history': ['user_id', 'created_at'],
    'weather_cache': ['location_key', 'cached_at'],
    'forum_posts_cache': ['user_id', 'created_at'],
  };
}
