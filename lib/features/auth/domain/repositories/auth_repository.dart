import '../../../../core/enums/user_role.dart';
import '../../../../core/storage/session_service.dart';
import '../entities/auth_session.dart';
import '../entities/otp_purpose.dart';
import '../entities/send_otp_result.dart';

abstract class AuthRepository {
  /// Requests an OTP for [phone] with the given [purpose].
  Future<SendOtpResult> sendOtp({
    required String phone,
    required OtpPurpose purpose,
  });

  /// Creates a new account (doctor/hospital) and signs the user in.
  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    UserRole userType = UserRole.doctor,
    String? email,
  });

  /// Signs the user in with phone + password.
  Future<AuthSession> passwordLogin({
    required String phone,
    required String password,
    String? deviceId,
  });

  /// Exchanges an OTP for an authenticated session.
  Future<AuthSession> verifyOtp({
    required String phone,
    required String otp,
    OtpPurpose purpose = OtpPurpose.login,
    UserRole userType = UserRole.doctor,
    String? deviceId,
  });

  /// Exchanges [refreshToken] for a fresh token pair.
  Future<AuthTokenPair> refreshToken(String refreshToken);

  /// Revokes the current session on the server. Failing to reach the server
  /// is not an error — callers must clear the local session regardless.
  Future<void> logout();
}
