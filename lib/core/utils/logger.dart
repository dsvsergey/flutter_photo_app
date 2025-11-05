import 'dart:developer' as dev;

/// Utility class for logging
class Logger {
  static void log(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: name ?? 'CameraApp',
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: 'CameraApp',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // Error level
    );
  }
  
  static void info(String message) {
    dev.log(
      message,
      name: 'CameraApp',
      level: 800, // Info level
    );
  }
}
