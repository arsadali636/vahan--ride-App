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
///
/// All auth endpoints except `logout` are public (no access token required);
/// each call sets `requiresAuth: false` accordingly.
abstract class AuthRemoteDataSource {
  /// Requests an OTP for [request.phone] with the given [request.purpose].
  ///
  /// Path: `POST /api/v1/auth/send-otp/` (public).
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request);

  /// Creates a new account.
  ///
  /// Path: `POST /api/v1/auth/register/` (public).
  Future<RegisterResponseModel> register(RegisterRequestModel request);

  /// Signs in with phone + password.
  ///
  /// Path: `POST /api/v1/auth/login/` (public).
  Future<AuthTokenPair> passwordLogin(PasswordLoginRequestModel request);

  /// Exchanges an OTP for a token pair.
  ///
  /// Path: `POST /api/v1/auth/verify-otp/` (public).
  Future<AuthTokenPair> verifyOtp(OtpVerifyRequestModel request);

  /// Exchanges [refreshToken] for a fresh token pair.
  ///
  /// Path: `POST /api/v1/auth/refresh/` (public).
  Future<AuthTokenPair> refreshToken(String refreshToken);

  /// Revokes the current session.
  ///
  /// Path: `POST /api/v1/auth/logout/` (authenticated).
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this._apiClient});

  final ApiClient _apiClient;

  @override
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request) async {
    final data = await _apiClient.post(
      ApiEndpoints.authSendOtp,
      data: request.toJson(),
      requiresAuth: false,
    );
    return SendOtpResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
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
    return TokenResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    ).toTokenPair();
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
