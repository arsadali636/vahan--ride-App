import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';

import '../../helpers/fake_session_service.dart';
/// Adapter that returns 401 for protected requests until a refresh happens,
/// then succeeds. The refresh endpoint responds 200 unless [failRefresh].
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({
    this.failRefresh = false,
    this.protectedStatus = 401,
  });

  final bool failRefresh;
  final int protectedStatus;

  int protectedCalls = 0;
  int refreshCalls = 0;

  bool _refreshed = false;

  static const String refreshPath = '/api/v1/auth/refresh/';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == refreshPath) {
      refreshCalls++;
      if (failRefresh) {
        return _body(
          '{"detail":"refresh token expired"}',
          401,
        );
      }
      _refreshed = true;
      return _body(
        '{"access_token":"new-access","refresh_token":"new-refresh"}',
        200,
      );
    }
    protectedCalls++;
    if (!_refreshed) {
      return _body('{"detail":"expired"}', protectedStatus);
    }
    return _body('{"ok":true}', 200);
  }

  ResponseBody _body(String json, int status) {
    return ResponseBody.fromString(
      json,
      status,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeSessionService session;
  late _FakeAdapter adapter;
  late Dio dio;

  setUp(() {
    session = FakeSessionService(
      session: const SessionData(
        tokens: AuthTokenPair(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        ),
      ),
    );
    adapter = _FakeAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter;
  });

  RefreshTokenInterceptor buildInterceptor({Future<void> Function()? onExpired}) {
    return RefreshTokenInterceptor(
      dio: dio,
      sessionService: session,
      refreshHandler: (refreshToken) async {
        final response = await dio.post<dynamic>(
          _FakeAdapter.refreshPath,
          data: {'refresh_token': refreshToken},
        );
        return AuthTokenPair.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        );
      },
      onSessionExpired: onExpired,
    );
  }

  test('refreshes once and retries the 401 request', () async {
    dio.interceptors.add(buildInterceptor());

    final response = await dio.get<dynamic>('/protected');

    expect(response.statusCode, 200);
    expect(adapter.refreshCalls, 1);
    expect(adapter.protectedCalls, 2);
    expect(session.session!.tokens.accessToken, 'new-access');
    expect(session.session!.tokens.refreshToken, 'new-refresh');
  });

  test('concurrent 401s trigger a single refresh', () async {
    dio.interceptors.add(buildInterceptor());

    final results =
        await Future.wait<Response<dynamic>>([dio.get('/a'), dio.get('/b')]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(adapter.refreshCalls, 1);
    expect(adapter.protectedCalls, 4);
  });

  test('clears session and notifies on refresh failure', () async {
    adapter = _FakeAdapter(failRefresh: true);
    var expiredNotified = false;
    dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        buildInterceptor(onExpired: () async => expiredNotified = true),
      );

    await expectLater(dio.get('/protected'), throwsA(isA<DioException>()));

    expect(adapter.refreshCalls, 1);
    expect(session.session, isNull);
    expect(expiredNotified, isTrue);
  });

  test('does not refresh for non-401 errors', () async {
    adapter = _FakeAdapter(protectedStatus: 403);
    dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(buildInterceptor());

    await expectLater(dio.get('/protected'), throwsA(isA<DioException>()));

    expect(adapter.refreshCalls, 0);
    expect(adapter.protectedCalls, 1);
    expect(session.session, isNotNull);
  });

  test('refreshes even when there is no session to clear', () async {
    session = FakeSessionService();
    dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(buildInterceptor());

    await expectLater(dio.get('/protected'), throwsA(isA<DioException>()));

    expect(adapter.refreshCalls, 0);
    expect(session.session, isNull);
  });
}
