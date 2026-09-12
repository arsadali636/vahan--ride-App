// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../utils/logger.dart';
import '../logging/log_sanitizer.dart';

/// Debug-only pretty logger for the shared [Dio] instance.
///
/// This replaces stock `pretty_dio_logger` because that package cannot mask
/// sensitive values; every request/response/error body and header passes
/// through [LogSanitizer] first, large payloads are truncated, and binary
/// content (uploads/downloads) is reduced to metadata only.
///
/// In release builds ([enabled] defaults to `kDebugMode`) nothing is logged.
class DebugDioLogger extends Interceptor {
  DebugDioLogger({bool enabled = kDebugMode}) : _enabled = enabled;

  final bool _enabled;

  /// Whether verbose logging is currently enabled for this instance.
  bool get enabled => _enabled;

  static const String _kStartKey = 'debug_logger_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_enabled) {
      options.extra[_kStartKey] = DateTime.now();
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_enabled) _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_enabled) _logError(err);
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    AppLogger.info('REQUEST ${options.method} ${options.uri}');
    AppLogger.info(
      'query: ${_queryParameters(options)} '
      'headers:\n${LogSanitizer.sanitizeHeaders(options.headers)} '
      'body: ${_requestBody(options)}',
    );
  }

  void _logResponse(Response<dynamic> response) {
    final request = response.requestOptions;
    AppLogger.info(
      'RESPONSE ${response.statusCode ?? '-'} ${request.method} '
      '${request.uri} in ${_durationSince(request)}ms '
      'body: ${_responseBody(response)}',
    );
  }

  void _logError(DioException err) {
    final request = err.requestOptions;
    AppLogger.warn(
      'ERROR ${err.response?.statusCode ?? '-'} ${request.method} '
      '${request.uri} in ${_durationSince(request)}ms '
      'type=${err.type} message=${err.message ?? ''} '
      'request body: ${_requestBody(request)} '
      'response body: ${_errorBody(err)}',
    );
  }

  String _queryParameters(RequestOptions options) {
    if (options.queryParameters.isEmpty) return '(none)';
    return LogSanitizer.sanitizeJson(options.queryParameters);
  }

  String _requestBody(RequestOptions options) {
    final data = options.data;
    if (data == null) return '(none)';
    if (data is FormData) return _formDataSummary(data);
    if (data is List<int>) return '(binary ${data.length} bytes)';
    if (data is String) return _sanitizeStringData(data);
    return LogSanitizer.sanitizeJson(data);
  }

  String _responseBody(Response<dynamic> response) {
    final data = response.data;
    if (data == null) return '(none)';
    if (data is List<int>) return '(binary ${data.length} bytes)';
    if (data is String) return _sanitizeStringData(data);
    return LogSanitizer.sanitizeJson(data);
  }

  String _errorBody(DioException err) {
    final data = err.response?.data;
    if (data == null) return '(none)';
    if (data is List<int>) return '(binary ${data.length} bytes)';
    if (data is String) return _sanitizeStringData(data);
    return LogSanitizer.sanitizeJson(data);
  }

  /// Pretty-prints a JSON body string after sanitization; falls back to a
  /// truncated plain string for non-JSON payloads.
  String _sanitizeStringData(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map || decoded is List) {
        return LogSanitizer.sanitizeJson(decoded);
      }
    } catch (_) {
      // Not JSON — fall through to plain truncation.
    }
    return LogSanitizer.truncate(data);
  }

  /// Uploads are reduced to metadata: field/file names, sizes and content
  /// types. File contents and sensitive field values are never logged.
  String _formDataSummary(FormData data) {
    final buffer = StringBuffer('(multipart)');
    if (data.fields.isNotEmpty) {
      buffer.write(' fields:');
      for (final entry in data.fields) {
        final value = LogSanitizer.isSensitiveKey(entry.key)
            ? LogSanitizer.mask
            : LogSanitizer.truncate(entry.value);
        buffer.write(' ${entry.key}=$value');
      }
    }
    if (data.files.isNotEmpty) {
      buffer.write(' files:');
      for (final entry in data.files) {
        final file = entry.value;
        buffer.write(
          ' ${entry.key}=${file.filename ?? '(unnamed)'} '
          '(${file.contentType}, ${_formatBytes(file.length)})',
        );
      }
    }
    return buffer.toString();
  }

  static String _durationSince(RequestOptions request) {
    final startedAt = request.extra[_kStartKey] as DateTime?;
    if (startedAt == null) return '-';
    return '${DateTime.now().difference(startedAt).inMilliseconds}';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
