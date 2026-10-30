import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/session_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_purpose.dart';
import '../../domain/entities/send_otp_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/otp_verify_request_model.dart';
import '../models/password_login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/send_otp_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SendOtpResult> sendOtp({
    required String phone,
    required OtpPurpose purpose,
  }) async {
    try {
      final response = await remoteDataSource.sendOtp(
        SendOtpRequestModel(phone: phone, purpose: purpose),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
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
    try {
      final response = await remoteDataSource.register(
        RegisterRequestModel(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          password: password,
          userType: userType,
          email: email,
        ),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<AuthSession> passwordLogin({
    required String phone,
    required String password,
    UserRole? userType,
    String? deviceId,
  }) async {
    try {
      final tokens = await remoteDataSource.passwordLogin(
        PasswordLoginRequestModel(
          phone: phone,
          password: password,
          userType: userType,
          deviceId: deviceId,
        ),
      );
      return AuthSession(tokens: tokens, userRole: userType);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phone,
    required String otp,
    OtpPurpose purpose = OtpPurpose.login,
    UserRole userType = UserRole.doctor,
    String? deviceId,
  }) async {
    try {
      final tokens = await remoteDataSource.verifyOtp(
        OtpVerifyRequestModel(
          phone: phone,
          otp: otp,
          purpose: purpose,
          userType: userType,
          deviceId: deviceId,
        ),
      );
      return AuthSession(tokens: tokens);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<AuthTokenPair> refreshToken(String refreshToken) async {
    try {
      return await remoteDataSource.refreshToken(refreshToken);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on ApiException {
      // The session is cleared by the caller regardless of the server result.
    }
  }
}
