import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/constants/api_constants.dart';
import 'package:doc_connect_app/core/constants/api_endpoints.dart';
import 'package:doc_connect_app/core/network/interceptors/auth_interceptor.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';

import '../../helpers/fake_http_client_adapter.dart';
import '../../helpers/fake_session_service.dart';

void main() {
  late FakeSessionService session;
  late RecordingHttpClientAdapter adapter;
  late Dio dio;

  setUp(() {
    session = FakeSessionService(
      session: const SessionData(
        tokens: AuthTokenPair(
          accessToken: 'secret-access-token',
          refreshToken: 'secret-refresh-token',
        ),
      ),
    );
    adapter = RecordingHttpClientAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(session));
  });

  Future<void> request(String path, {Options? options}) async {
    await dio.get<dynamic>(path, options: options);
  }

  String? sentAuthorization() =>
      adapter.captured.single.headers['Authorization'] as String?;

  test('attaches the bearer access token to authenticated requests', () async {
    await request('/secure');

    expect(sentAuthorization(), 'Bearer secret-access-token');
  });

  test('does not attach a token when the session is empty', () async {
    session.session = null;

    await request('/secure');

    expect(sentAuthorization(), isNull);
  });

  test('does not attach a token to public endpoints', () async {
    await request(
      '/public',
      options: Options(
        extra: {ApiConstants.requiresAuthExtraKey: false},
      ),
    );

    expect(sentAuthorization(), isNull);
  });

  test('does not attach a token to the refresh request', () async {
    await request(ApiEndpoints.authRefresh);

    expect(sentAuthorization(), isNull);
  });

  test('leaves an existing Authorization header untouched', () async {
    await request(
      '/basic',
      options: Options(headers: {'Authorization': 'Basic dXNlcjpwYXNz'}),
    );

    expect(sentAuthorization(), 'Basic dXNlcjpwYXNz');
  });
}
