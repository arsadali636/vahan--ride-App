import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight application logger.
///
/// Never logs tokens, passwords, or other sensitive payloads. Log output is
/// enabled only in debug builds.
class AppLogger {
  AppLogger._();

  static void info(String message) => _log('INFO', message);

  static void warn(String message) => _log('WARN', message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message);
    if (error != null) {
      _log('ERROR', error.toString());
    }
    if (stackTrace != null) {
      developer.log(stackTrace.toString(), name: _kTag, level: 1000);
    }
  }

  static void _log(String level, String message) {
    if (!kDebugMode) return;
    developer.log('[$level] $message', name: _kTag);
  }

  static const String _kTag = 'MedNexus';
}
