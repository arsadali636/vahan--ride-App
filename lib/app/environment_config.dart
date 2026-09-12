/// Build environments supported by the application.
///
/// Values are resolved from compile-time definitions (`--dart-define`) so that
/// backend URLs are never hardcoded in the source tree.
enum AppEnvironment { development, staging, production }

/// Resolves build-time configuration for the active environment.
///
/// Configuration is injected at build time via `--dart-define`:
///
/// ```sh
/// flutter run --dart-define=ENVIRONMENT=development \
///             --dart-define=API_BASE_URL=https://api.example.com
/// ```
class EnvironmentConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String apiBasePath;

  const EnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.apiBasePath,
  });

  /// Builds the config from `--dart-define` values.
  ///
  /// `ENVIRONMENT`  -> one of: development | staging | production
  /// `API_BASE_URL` -> backend host, e.g. https://api.example.com
  /// `API_BASE_PATH`-> optional API path prefix (defaults to the FastAPI `/api/v1`).
  ///
  /// When `API_BASE_URL` is not provided, development falls back to the
  /// project's FastAPI backend so the app runs out of the box. Staging and
  /// production must always supply an explicit URL.
  factory EnvironmentConfig.fromDartDefines() {
    final environment = _resolveEnvironment();
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
    return EnvironmentConfig._(
      environment: environment,
      apiBaseUrl: configuredBaseUrl.isNotEmpty
          ? configuredBaseUrl
          : _defaultBaseUrl(environment),
      apiBasePath: const String.fromEnvironment(
        'API_BASE_PATH',
        defaultValue: '/api/v1',
      ),
    );
  }

  /// Project FastAPI backend for local development.
  static const String kDevelopmentApiBaseUrl = 'http://65.1.134.1';

  static String _defaultBaseUrl(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return kDevelopmentApiBaseUrl;
      case AppEnvironment.staging:
      case AppEnvironment.production:
        return '';
    }
  }

  /// Defaults for unit tests and local development.
  const EnvironmentConfig.development({
    this.apiBaseUrl = '',
    this.apiBasePath = '/api/v1',
  }) : environment = AppEnvironment.development;

  const EnvironmentConfig.staging({
    this.apiBaseUrl = '',
    this.apiBasePath = '/api/v1',
  }) : environment = AppEnvironment.staging;

  const EnvironmentConfig.production({
    this.apiBaseUrl = '',
    this.apiBasePath = '/api/v1',
  }) : environment = AppEnvironment.production;

  static AppEnvironment _resolveEnvironment() {
    switch (const String.fromEnvironment('ENVIRONMENT').toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.development;
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      default:
        return AppEnvironment.development;
    }
  }

  @override
  String toString() => 'EnvironmentConfig(environment: $environment, '
      'apiBaseUrl: $apiBaseUrl, apiBasePath: $apiBasePath)';
}
