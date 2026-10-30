import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';
import 'package:doc_connect_app/features/auth/domain/entities/auth_session.dart';
import 'package:doc_connect_app/features/auth/domain/entities/otp_purpose.dart';
import 'package:doc_connect_app/features/auth/domain/entities/send_otp_result.dart';
import 'package:doc_connect_app/features/auth/domain/repositories/auth_repository.dart';

/// Configurable in-memory [AuthRepository] for usecase/bloc/widget tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.sendOtpResult,
    this.registerResult,
    this.loginResult,
  });

  SendOtpResult? sendOtpResult;
  AuthSession? registerResult;
  AuthSession? loginResult;
  Object? errorToThrow;
  int logoutCalls = 0;
  String? lastPhone;
  String? lastPassword;

  @override
  Future<SendOtpResult> sendOtp({
    required String phone,
    required OtpPurpose purpose,
  }) async {
    lastPhone = phone;
    _maybeThrow();
    return sendOtpResult ??
        const SendOtpResult(success: true, message: 'OTP sent', expiresIn: 300);
  }

  @override
  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    UserRole userType = UserRole.doctor,
    String? email,
  }) async {
    lastPhone = phone;
    _maybeThrow();
    return registerResult ??
        AuthSession(
          tokens: const AuthTokenPair(
            accessToken: 'access',
            refreshToken: 'refresh',
          ),
        );
  }

  @override
  Future<AuthSession> passwordLogin({
    required String phone,
    required String password,
    UserRole? userType,
    String? deviceId,
  }) async {
    lastPhone = phone;
    lastPassword = password;
    _maybeThrow();
    return loginResult ??
        AuthSession(
          tokens: const AuthTokenPair(
            accessToken: 'access',
            refreshToken: 'refresh',
          ),
          userRole: userType,
        );
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phone,
    required String otp,
    OtpPurpose purpose = OtpPurpose.login,
    UserRole userType = UserRole.doctor,
    String? deviceId,
  }) async {
    lastPhone = phone;
    _maybeThrow();
    return loginResult ??
        AuthSession(
          tokens: const AuthTokenPair(
            accessToken: 'access',
            refreshToken: 'refresh',
          ),
        );
  }

  @override
  Future<AuthTokenPair> refreshToken(String refreshToken) async {
    _maybeThrow();
    return const AuthTokenPair(
      accessToken: 'access-refreshed',
      refreshToken: 'refresh-refreshed',
    );
  }

  @override
  Future<void> logout() async {
    _maybeThrow();
    logoutCalls += 1;
  }

  void _maybeThrow() {
    final error = errorToThrow;
    if (error != null) throw error;
  }
}
