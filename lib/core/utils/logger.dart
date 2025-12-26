import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String tag = 'KrishiBondhuAI'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void error(String message, {String tag = 'KrishiBondhuAI', Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[$tag] ERROR: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  static void warning(String message, {String tag = 'KrishiBondhuAI'}) {
    if (kDebugMode) {
      print('[$tag] WARNING: $message');
    }
  }

  static void info(String message, {String tag = 'KrishiBondhuAI'}) {
    if (kDebugMode) {
      print('[$tag] INFO: $message');
    }
  }
}
