import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../constants/api_endpoints.dart';
import '../../storage/session_service.dart';

/// Attaches the bearer access token to outgoing requests.
///
/// Reads the token from [SessionService] so repositories never have to manage
/// `Authorization` headers manually. Requests that already carry an
/// Authorization header (e.g. a basic auth upload) are left untouched. The
/// token refresh request is never given an access token — it authenticates
/// with the refresh token in its body. Requests marked public via
/// `ApiConstants.requiresAuthExtraKey` (see [ApiClient.requiresAuth]) are also
/// left without an Authorization header.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionService);

  final SessionService _sessionService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final isRefreshRequest =
          options.path == ApiEndpoints.authRefresh;
      final isPublic =
          options.extra[ApiConstants.requiresAuthExtraKey] == false;
      final hasAuthHeader = options.headers.containsKey('Authorization');
      if (!hasAuthHeader && !isRefreshRequest && !isPublic) {
        final accessToken = await _sessionService.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
      }
    } catch (_) {
      // Never block a request because of storage errors — let it fail later.
    }
    handler.next(options);
  }
}
