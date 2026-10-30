import 'package:flutter/foundation.dart';

import 'environment_config.dart';

/// Global application configuration.
///
/// Initialized once during bootstrap (`main()`), before the widget tree and
/// the dependency injection container are set up. Access via `AppConfig.instance`.
class AppConfig {
  AppConfig._({required this.appTitle, required this.environmentConfig});

  static late final AppConfig instance;

  static bool _initialized = false;

  final String appTitle;
  final EnvironmentConfig environmentConfig;

  static void initialize({
    String appTitle = 'MedNexus',
    EnvironmentConfig? environmentConfig,
  }) {
    if (_initialized) return;
    _initialized = true;
    instance = AppConfig._(
      appTitle: appTitle,
      environmentConfig:
          environmentConfig ?? EnvironmentConfig.fromDartDefines(),
    );
  }

  /// Test-only reset that allows re-initialization between test cases.
  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }
}
