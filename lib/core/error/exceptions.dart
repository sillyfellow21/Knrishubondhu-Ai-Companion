class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error occurred']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error occurred']);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException([this.message = 'Database error occurred']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Validation failed']);
}
