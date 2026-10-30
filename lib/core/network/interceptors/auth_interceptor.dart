import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../constants/api_endpoints.dart';
import '../../storage/session_service.dart';

/// Attaches bearer access token and Django sessionid cookie to outgoing requests.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionService);

  final SessionService _sessionService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final isRefreshRequest = options.path == ApiEndpoints.authRefresh;
      final isPublic =
          options.extra[ApiConstants.requiresAuthExtraKey] == false;
      final isRetry = options.extra['refresh_retried'] == true;
      final hasAuthHeader = options.headers.containsKey('Authorization');
      if ((!hasAuthHeader || isRetry) && !isRefreshRequest && !isPublic) {
        final accessToken = await _sessionService.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
      }
      final sessionId = await _sessionService.getSessionId();
      if (sessionId != null && sessionId.isNotEmpty) {
        final existingCookie = options.headers['Cookie'] as String?;
        if (existingCookie != null && existingCookie.isNotEmpty) {
          if (isRetry && existingCookie.contains('sessionid=')) {
            options.headers['Cookie'] = existingCookie.replaceAll(
              RegExp(r'sessionid=[^;]+'),
              'sessionid=$sessionId',
            );
          } else if (!existingCookie.contains('sessionid=')) {
            options.headers['Cookie'] = '$existingCookie; sessionid=$sessionId';
          }
        } else {
          options.headers['Cookie'] = 'sessionid=$sessionId';
        }
      }
    } catch (_) {
      // Storage safety
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    await _extractAndSaveSessionId(response);
    handler.next(response);
  }

  Future<void> _extractAndSaveSessionId(Response response) async {
    try {
      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        for (final cookie in cookies) {
          if (cookie.contains('sessionid=')) {
            final match = RegExp(r'sessionid=([^;]+)').firstMatch(cookie);
            if (match != null) {
              final sessionId = match.group(1);
              if (sessionId != null && sessionId.isNotEmpty) {
                await _sessionService.saveSessionId(sessionId);
              }
            }
          }
        }
      }
    } catch (_) {}
  }
}
