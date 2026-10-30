import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/api/api_client.dart';
import 'package:doc_connect_app/core/constants/api_constants.dart';
import 'package:doc_connect_app/core/constants/api_endpoints.dart';
import 'package:doc_connect_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doc_connect_app/features/auth/data/models/otp_verify_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/password_login_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/register_request_model.dart';

import '../helpers/fake_http_client_adapter.dart';

/// Records outgoing calls and returns a canned body per endpoint.
class _RecordingApiClient extends ApiClient {
  _RecordingApiClient(this.canned)
    : super(Dio(BaseOptions(baseUrl: 'http://test')));

  final Map<String, dynamic> canned;
  final List<({String path, Object? data, bool requiresAuth})> posts = [];

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    posts.add((path: path, data: data, requiresAuth: requiresAuth));
    return canned[path];
  }
}

void main() {
  late _RecordingApiClient apiClient;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    apiClient = _RecordingApiClient(const {
      ApiEndpoints.authRegister: {
        'access_token': 'at-1',
        'refresh_token': 'rt-1',
        'user_id': 'u-1',
        'user_type': 'DOCTOR',
        'profile_created': true,
      },
      ApiEndpoints.authLogin: {
        'access_token': 'at-1',
        'refresh_token': 'rt-1',
        'token_type': 'bearer',
      },
      ApiEndpoints.authVerifyOtp: {
        'access_token': 'at-2',
        'refresh_token': 'rt-2',
        'token_type': 'bearer',
      },
      ApiEndpoints.authRefresh: {
        'access_token': 'at-3',
        'refresh_token': 'rt-3',
        'token_type': 'bearer',
      },
    });
    dataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  });

  test('register posts to the register path as a public request', () async {
    final response = await dataSource.register(
      const RegisterRequestModel(
        firstName: 'Ada',
        lastName: 'Lovelace',
        phone: '9876543210',
        password: 'secret123',
      ),
    );

    final call = apiClient.posts.single;
    expect(call.path, ApiEndpoints.authRegister);
    expect(call.requiresAuth, isFalse);
    expect((call.data as Map)['phone'], '9876543210');
    expect((call.data as Map)['user_type'], 'DOCTOR');
    expect(response.userId, 'u-1');
    expect(response.profileCreated, isTrue);
  });

  test('passwordLogin posts to the login path as a public request', () async {
    final pair = await dataSource.passwordLogin(
      const PasswordLoginRequestModel(phone: '9876543210', password: 'pass'),
    );

    final call = apiClient.posts.single;
    expect(call.path, ApiEndpoints.authLogin);
    expect(call.requiresAuth, isFalse);
    expect(pair.accessToken, 'at-1');
    expect(pair.refreshToken, 'rt-1');
  });

  test('verifyOtp posts to the verify-otp path as a public request', () async {
    final pair = await dataSource.verifyOtp(
      const OtpVerifyRequestModel(phone: '9876543210', otp: '123456'),
    );

    final call = apiClient.posts.single;
    expect(call.path, ApiEndpoints.authVerifyOtp);
    expect(call.requiresAuth, isFalse);
    expect((call.data as Map)['otp'], '123456');
    expect(pair.accessToken, 'at-2');
  });

  test('refreshToken posts to the refresh path as a public request', () async {
    final pair = await dataSource.refreshToken('old-refresh');

    final call = apiClient.posts.single;
    expect(call.path, ApiEndpoints.authRefresh);
    expect(call.requiresAuth, isFalse);
    expect((call.data as Map)['refresh_token'], 'old-refresh');
    expect(pair.accessToken, 'at-3');
  });

  test('logout posts to the logout path as an authenticated request', () async {
    await dataSource.logout();

    final call = apiClient.posts.single;
    expect(call.path, ApiEndpoints.authLogout);
    expect(call.requiresAuth, isTrue);
  });

  test('sendOtp is marked public through ApiClient', () async {
    // A plain Dio with the ApiErrorInterceptor/AuthInterceptor would normally
    // honor the requiresAuth flag; here we verify the extra key is set by
    // ApiClient itself when requiresAuth is false.
    final adapter = RecordingHttpClientAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter;
    final client = ApiClient(dio);

    await client.post('/api/v1/auth/send-otp/', data: {}, requiresAuth: false);

    expect(
      adapter.captured.single.extra[ApiConstants.requiresAuthExtraKey],
      isFalse,
    );
  });
}
