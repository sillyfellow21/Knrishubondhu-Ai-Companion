class AppConstants {
  // API Constants
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Cache Constants
  static const Duration cacheExpiry = Duration(hours: 24);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';
}
