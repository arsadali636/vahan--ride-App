import 'package:equatable/equatable.dart';

import '../../../../core/enums/user_role.dart';
import '../entities/auth_session.dart';
import '../entities/otp_purpose.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a one-time password for an authenticated session.
///
/// Backed by `POST /api/v1/auth/verify-otp/`.
class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<AuthSession> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      phone: params.phone,
      otp: params.otp,
      purpose: params.purpose,
      userType: params.userType,
      deviceId: params.deviceId,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otp;
  final OtpPurpose purpose;
  final UserRole userType;
  final String? deviceId;

  const VerifyOtpParams({
    required this.phone,
    required this.otp,
    this.purpose = OtpPurpose.login,
    this.userType = UserRole.doctor,
    this.deviceId,
  });

  @override
  List<Object?> get props => [phone, otp, purpose, userType, deviceId];
}
