import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/api/api_client.dart';
import 'package:doc_connect_app/core/constants/api_constants.dart';
import 'package:doc_connect_app/core/errors/exceptions.dart';

import '../../helpers/fake_http_client_adapter.dart';

void main() {
  late RecordingHttpClientAdapter adapter;
  late ApiClient apiClient;

  setUp(() {
    adapter = RecordingHttpClientAdapter(body: '{"ok":true}');
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter;
    apiClient = ApiClient(dio);
  });

  test('returns the response data on a successful request', () async {
    final data = await apiClient.get('/hospitals');

    expect(data, {'ok': true});
    expect(adapter.captured.single.path, '/hospitals');
  });

  test('requires auth by default (no public marker)', () async {
    await apiClient.get('/hospitals');

    expect(
      adapter.captured.single.extra[ApiConstants.requiresAuthExtraKey],
      isNot(false),
    );
  });

  test(
    'marks a public request so the auth interceptor skips the token',
    () async {
      await apiClient.get('/auth/send-otp', requiresAuth: false);

      expect(
        adapter.captured.single.extra[ApiConstants.requiresAuthExtraKey],
        isFalse,
      );
    },
  );

  test('sends query parameters and a request body', () async {
    await apiClient.post(
      '/hospitals/jobs',
      data: {'title': 'Cardiologist'},
      queryParameters: {'page': 2},
    );

    final captured = adapter.captured.single;
    expect(captured.queryParameters['page'], 2);
    expect(captured.data, {'title': 'Cardiologist'});
  });

  test('throws a typed ApiException when the backend responds 4xx', () async {
    adapter
      ..statusCode = 401
      ..body = '{"detail":"session expired"}';

    await expectLater(
      apiClient.get('/hospitals'),
      throwsA(
        isA<UnauthorizedException>().having(
          (e) => e.message,
          'message',
          'session expired',
        ),
      ),
    );
  });

  test(
    'falls back to mapping when no error interceptor wrapped the failure',
    () async {
      adapter.throwError = DioException(
        requestOptions: RequestOptions(path: '/hospitals'),
        type: DioExceptionType.connectionTimeout,
      );

      await expectLater(
        apiClient.get('/hospitals'),
        throwsA(isA<NetworkTimeoutException>()),
      );
    },
  );

  test('throws a typed ApiException for a 5xx response', () async {
    adapter
      ..statusCode = 503
      ..body = '{"detail":"service unavailable"}';

    await expectLater(
      apiClient.post('/hospitals/jobs', data: const {}),
      throwsA(isA<ServerException>()),
    );
  });
}
