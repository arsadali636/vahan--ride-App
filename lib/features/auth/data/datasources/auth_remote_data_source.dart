import 'package:dio/dio.dart';

import '../../../../app/app_config.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/session_service.dart';
import '../models/otp_verify_request_model.dart';
import '../models/password_login_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/send_otp_request_model.dart';
import '../models/send_otp_response_model.dart';
import '../models/token_response_model.dart';

/// Remote data source for authentication endpoints.
abstract class AuthRemoteDataSource {
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request);
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<AuthTokenPair> passwordLogin(PasswordLoginRequestModel request);
  Future<AuthTokenPair> verifyOtp(OtpVerifyRequestModel request);
  Future<AuthTokenPair> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request) async {
    final data = await _apiClient.post(
      ApiEndpoints.authSendOtp,
      data: request.toJson(),
      requiresAuth: false,
    );
    return SendOtpResponseModel.fromJson((data as Map).cast<String, dynamic>());
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final data = await _apiClient.post(
      ApiEndpoints.authRegister,
      data: request.toJson(),
      requiresAuth: false,
    );
    return RegisterResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<AuthTokenPair> passwordLogin(PasswordLoginRequestModel request) async {
    final data = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: request.toJson(),
      requiresAuth: false,
    );
    final tokenPair = TokenResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    ).toTokenPair();

    // Perform web session login to capture sessionid for Django endpoints (/api/posts/)
    try {
      final dio = _apiClient.dio;
      final baseUrl = AppConfig.instance.environmentConfig.apiBaseUrl;

      final getRes = await dio.get<String>(
        '$baseUrl/login/',
        options: Options(
          responseType: ResponseType.plain,
          extra: {'requiresAuth': false},
        ),
      );

      final csrfCookie = getRes.headers['set-cookie']?.firstWhere(
        (c) => c.contains('csrftoken='),
        orElse: () => '',
      );
      final csrfMatch = RegExp(
        r'csrftoken=([^;]+)',
      ).firstMatch(csrfCookie ?? '');
      final csrfToken = csrfMatch?.group(1);

      if (csrfToken != null && csrfToken.isNotEmpty) {
        final postRes = await dio.post<dynamic>(
          '$baseUrl/login/',
          data:
              'csrfmiddlewaretoken=$csrfToken&phone=${Uri.encodeComponent(request.phone)}&password=${Uri.encodeComponent(request.password)}',
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            followRedirects: false,
            validateStatus: (status) => status != null && status < 500,
            extra: {'requiresAuth': false},
            headers: {
              'Cookie': 'csrftoken=$csrfToken',
              'Referer': '$baseUrl/login/',
            },
          ),
        );

        final sessionCookies = postRes.headers['set-cookie'];
        if (sessionCookies != null) {
          for (final c in sessionCookies) {
            if (c.contains('sessionid=')) {
              final match = RegExp(r'sessionid=([^;]+)').firstMatch(c);
              if (match != null && match.group(1) != null) {
                final sessionId = match.group(1)!;
                dio.options.headers['Cookie'] = 'sessionid=$sessionId';
              }
            }
          }
        }
      }
    } catch (_) {
      // Best-effort session acquisition
    }

    return tokenPair;
  }

  @override
  Future<AuthTokenPair> verifyOtp(OtpVerifyRequestModel request) async {
    final data = await _apiClient.post(
      ApiEndpoints.authVerifyOtp,
      data: request.toJson(),
      requiresAuth: false,
    );
    return TokenResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    ).toTokenPair();
  }

  @override
  Future<AuthTokenPair> refreshToken(String refreshToken) async {
    final data = await _apiClient.post(
      ApiEndpoints.authRefresh,
      data: RefreshTokenRequestModel(refreshToken: refreshToken).toJson(),
      requiresAuth: false,
    );
    return TokenResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    ).toTokenPair();
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.authLogout);
  }
}
