import '../../app/app_config.dart';

/// Utilities for resolving backend asset and media URLs.
class UrlUtils {
  UrlUtils._();

  /// Resolves relative or absolute asset/media URLs against the active
  /// environment's API base URL.
  ///
  /// - Data URIs (`data:image/...`) and absolute URLs starting with `http://` or
  ///   `https://` are returned as is.
  /// - Relative URLs are resolved against the origin host (scheme + host + port)
  ///   of `EnvironmentConfig.apiBaseUrl`, preserving `/media/` or `/uploads/`
  ///   without duplicating `/api/v1`.
  /// - Null, empty, or whitespace-only inputs return `null`.
  static String? resolveUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('data:image/') ||
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://')) {
      return trimmed;
    }

    final baseUrl = AppConfig.instance.environmentConfig.apiBaseUrl;
    if (baseUrl.isEmpty) return trimmed;

    try {
      final uri = Uri.parse(baseUrl);
      final portSuffix = uri.hasPort ? ':${uri.port}' : '';
      final origin = '${uri.scheme}://${uri.host}$portSuffix';

      if (trimmed.startsWith('/')) {
        return '$origin$trimmed';
      }
      return '$origin/$trimmed';
    } catch (_) {
      return trimmed;
    }
  }
}
