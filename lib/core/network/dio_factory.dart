import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/session_service.dart';
import 'interceptors/api_error_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';
import 'network_info.dart';

/// Builds the single, fully-configured [Dio] instance used by every
/// data source in the app.
///
/// Interceptor chain (request direction):
///   Auth → Refresh → PrettyLogger → ApiError
/// Errors flow in reverse, so ApiError maps first, the logger records the
/// failure, then refresh/retry runs before the outcome is propagated.
class DioFactory {
  DioFactory._();

  static Dio create({
    required String baseUrl,
    required SessionService sessionService,
    required TokenRefreshHandler refreshHandler,
    NetworkInfo? networkInfo,
    Future<void> Function()? onSessionExpired,
    bool enableLogging = kDebugMode,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(sessionService),
      RefreshTokenInterceptor(
        dio: dio,
        sessionService: sessionService,
        refreshHandler: refreshHandler,
        networkInfo: networkInfo,
        onSessionExpired: onSessionExpired,
      ),
      if (enableLogging)
        PrettyDioLogger(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      ApiErrorInterceptor(),
    ]);

    return dio;
  }
}
