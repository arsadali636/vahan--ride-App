import 'package:equatable/equatable.dart';

import '../../../../core/enums/user_role.dart';
import '../../domain/entities/otp_purpose.dart';

/// Request body for `POST /api/v1/auth/verify-otp/`.
///
/// Matches the backend `OTPVerify` schema. `user_type` is only
/// DOCTOR|HOSPITAL_ADMIN per the contract. `device_id` is optional.
class OtpVerifyRequestModel extends Equatable {
  final String phone;
  final String otp;
  final OtpPurpose purpose;
  final UserRole userType;
  final String? deviceId;

  const OtpVerifyRequestModel({
    required this.phone,
    required this.otp,
    this.purpose = OtpPurpose.login,
    this.userType = UserRole.doctor,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'purpose': purpose.wire,
      'user_type': userType.wire,
      if (deviceId != null) 'device_id': deviceId,
    };
  }

  @override
  List<Object?> get props => [phone, otp, purpose, userType, deviceId];
}
