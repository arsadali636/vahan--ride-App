import 'dart:convert';

/// Redacts sensitive values before they reach log output.
///
/// Used by [DebugDioLogger] so request/response bodies and headers are logged
/// without ever exposing tokens, passwords, OTPs, patient documents, etc.
class LogSanitizer {
  LogSanitizer._();

  /// Universal replacement for anything sensitive.
  static const String mask = '********';

  /// Keys whose values are masked, matched case-insensitively (top-level and
  /// nested). Values under these keys are replaced with [mask].
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'access_token',
    'accesstoken',
    'refresh_token',
    'refreshtoken',
    'token',
    'password',
    'pass',
    'passcode',
    'otp',
    'otp_code',
    'pin',
    'secret',
    'client_secret',
    'api_key',
    'apikey',
    'x_api_key',
    'medical_document',
    'medicaldocument',
    'medical_report',
    'prescription',
    'private_message',
    'privatemessage',
  };

  /// Header names whose values are masked.
  static const Set<String> _sensitiveHeaderNames = {
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token',
    'x-access-token',
  };

  /// Maximum recursion depth when traversing a body; deeper branches are
  /// collapsed so cyclic/absurdly-nested data cannot blow the stack.
  static const int defaultMaxDepth = 6;

  /// Maximum characters kept from a single logged value/body.
  static const int defaultMaxLength = 4000;

  /// Returns true when [key] should be masked.
  static bool isSensitiveKey(String key) {
    return _sensitiveKeys.contains(key.toLowerCase());
  }

  /// Encodes [value] as a compact JSON string with sensitive keys masked.
  ///
  /// Non-JSON-encodable values fall back to a truncated [toString] so logging
  /// never throws. Long output is truncated via [truncate].
  static String sanitizeJson(
    dynamic value, {
    int maxLength = defaultMaxLength,
  }) {
    try {
      final sanitized = _sanitizeValue(value, 0);
      return truncate(jsonEncode(sanitized), maxLength: maxLength);
    } catch (_) {
      return truncate('$value', maxLength: maxLength);
    }
  }

  /// Renders a header map with sensitive header values replaced by [mask].
  static String sanitizeHeaders(
    Map<String, dynamic> headers, {
    int maxLength = defaultMaxLength,
  }) {
    final buffer = StringBuffer();
    headers.forEach((name, value) {
      buffer.write('  $name: ');
      final raw = value is List ? value.join(', ') : '$value';
      buffer.writeln(maskHeaderValue(name, raw));
    });
    return truncate(buffer.toString().trimRight(), maxLength: maxLength);
  }

  /// Masks a single header value, preserving the `Bearer ` prefix so logs
  /// still show the auth scheme without the secret.
  static String maskHeaderValue(String name, String value) {
    final trimmed = value.trim();
    if (!_isSensitiveHeader(name)) return value;
    if (trimmed.toLowerCase().startsWith('bearer ')) return 'Bearer $mask';
    return mask;
  }

  /// Truncates [value] to [maxLength] characters, appending a marker when it
  /// was cut so the log shows how much was suppressed.
  static String truncate(String value, {int maxLength = defaultMaxLength}) {
    if (value.length <= maxLength) return value;
    final truncated = value.substring(0, maxLength);
    return '$truncated... [truncated ${value.length - maxLength} chars]';
  }

  static dynamic _sanitizeValue(dynamic value, int depth) {
    if (depth > defaultMaxDepth) return '[depth exceeded]';
    if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((key, item) {
        final keyName = '$key';
        result[keyName] = isSensitiveKey(keyName)
            ? mask
            : _sanitizeValue(item, depth + 1);
      });
      return result;
    }
    if (value is List) {
      return value.map((item) => _sanitizeValue(item, depth + 1)).toList();
    }
    if (value is Iterable) {
      return value.map((item) => _sanitizeValue(item, depth + 1)).toList();
    }
    return value;
  }

  static bool _isSensitiveHeader(String name) {
    return _sensitiveHeaderNames.contains(name.toLowerCase());
  }
}
