// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../storage/session_service.dart';
import '../network_info.dart';

/// Attempts to refresh the session when a request fails with HTTP 401, then
/// retries the original request once with the new access token.
///
/// Refresh is performed through [refreshHandler], which calls the real
/// backend endpoint (`POST /api/v1/auth/refresh/` per the OpenAPI contract)
/// using the refresh token read from [SessionService].
///
/// Concurrent 401s share a single refresh via an in-flight future lock, so the
/// backend is never hit with simultaneous refresh requests. On refresh failure
/// the session is cleared, [onSessionExpired] is notified (AuthBloc), and the
/// router redirects to login.
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required Dio dio,
    required SessionService sessionService,
    required TokenRefreshHandler refreshHandler,
    NetworkInfo? networkInfo,
    Future<void> Function()? onSessionExpired,
  }) : _dio = dio,
       _sessionService = sessionService,
       _refreshHandler = refreshHandler,
       _networkInfo = networkInfo,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final SessionService _sessionService;
  final TokenRefreshHandler _refreshHandler;
  final NetworkInfo? _networkInfo;
  final Future<void> Function()? _onSessionExpired;

  static const String _kRetryKey = 'refresh_retried';

  /// In-flight refresh future; concurrent 401s await the same refresh instead
  /// of starting their own. Reset when the refresh completes.
  Future<AuthTokenPair?>? _refreshInFlight;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldAttemptRefresh(err)) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        try {
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }
    }
    handler.next(err);
  }

  bool _shouldAttemptRefresh(DioException err) {
    final statusCode = err.response?.statusCode;
    if (statusCode != 401) return false;

    // Never refresh in response to a failure of the refresh request itself.
    if (err.requestOptions.path == ApiEndpoints.authRefresh) return false;

    // Only retry each request once.
    if (err.requestOptions.extra[_kRetryKey] == true) return false;

    return true;
  }

  Future<bool> _refreshTokens() async {
    if (_networkInfo != null && !await _networkInfo.isConnected) {
      return false;
    }
    final pair = await (_refreshInFlight ??= _performRefresh().whenComplete(
      () => _refreshInFlight = null,
    ));
    return pair != null;
  }

  Future<AuthTokenPair?> _performRefresh() async {
    try {
      final refreshToken = await _sessionService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _expireSession();
        return null;
      }
      final newPair = await _refreshHandler(refreshToken);
      if (newPair == null || newPair.accessToken.isEmpty) {
        await _expireSession();
        return null;
      }
      await _sessionService.saveTokens(newPair);
      return newPair;
    } catch (_) {
      await _expireSession();
      return null;
    }
  }

  /// Clears the persisted session and notifies the app (AuthBloc → redirect
  /// to login).
  Future<void> _expireSession() async {
    await _sessionService.clearSession();
    await _onSessionExpired?.call();
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = requestOptions..extra[_kRetryKey] = true;
    return _dio.fetch<dynamic>(options);
  }
}

/// Signature for the auth module's token refresh implementation.
///
/// Receives the current refresh token and returns the new [AuthTokenPair], or
/// `null` when the refresh token is invalid/expired. Returned tokens are
/// persisted automatically by the interceptor.
typedef TokenRefreshHandler =
    Future<AuthTokenPair?> Function(String refreshToken);
