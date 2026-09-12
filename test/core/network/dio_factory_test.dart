import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/network/dio_factory.dart';
import 'package:doc_connect_app/core/network/interceptors/api_error_interceptor.dart';
import 'package:doc_connect_app/core/network/interceptors/auth_interceptor.dart';
import 'package:doc_connect_app/core/network/interceptors/debug_dio_logger.dart';
import 'package:doc_connect_app/core/network/interceptors/refresh_token_interceptor.dart';

import '../../helpers/fake_session_service.dart';

void main() {
  test('configures base URL, timeouts, response type and headers', () {
    final dio = DioFactory.create(
      baseUrl: 'http://test',
      sessionService: FakeSessionService(),
      refreshHandler: (_) async => null,
    );

    expect(dio.options.baseUrl, 'http://test');
    expect(dio.options.connectTimeout, const Duration(seconds: 20));
    expect(dio.options.sendTimeout, const Duration(seconds: 20));
    expect(dio.options.receiveTimeout, const Duration(seconds: 20));
    expect(dio.options.responseType, ResponseType.json);
    expect(dio.options.headers['Accept'], 'application/json');
    expect(dio.options.headers['Content-Type'], 'application/json');
  });

  test('installs the full interceptor chain', () {
    final dio = DioFactory.create(
      baseUrl: 'http://test',
      sessionService: FakeSessionService(),
      refreshHandler: (_) async => null,
    );

    expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
    expect(
      dio.interceptors.whereType<RefreshTokenInterceptor>(),
      hasLength(1),
    );
    expect(dio.interceptors.whereType<DebugDioLogger>(), hasLength(1));
    expect(dio.interceptors.whereType<ApiErrorInterceptor>(), hasLength(1));

    final requestOrder = dio.interceptors
        .where((i) => i is AuthInterceptor || i is RefreshTokenInterceptor)
        .toList();
    expect(requestOrder.first, isA<AuthInterceptor>());
    expect(requestOrder.last, isA<RefreshTokenInterceptor>());
  });

  test('can disable logging explicitly', () {
    final dio = DioFactory.create(
      baseUrl: 'http://test',
      sessionService: FakeSessionService(),
      refreshHandler: (_) async => null,
      enableLogging: false,
    );

    expect(dio.interceptors.whereType<DebugDioLogger>(), hasLength(1));
    final logger = dio.interceptors
        .whereType<DebugDioLogger>()
        .single;
    expect(logger.enabled, isFalse);
  });
}
