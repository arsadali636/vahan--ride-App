import 'package:equatable/equatable.dart';

import '../../../../core/enums/user_role.dart';

/// Request body for `POST /api/v1/auth/login/`.
///
/// Matches the backend `PasswordLoginRequest` schema.
class PasswordLoginRequestModel extends Equatable {
  final String phone;
  final String password;
  final UserRole? userType;
  final String? deviceId;

  const PasswordLoginRequestModel({
    required this.phone,
    required this.password,
    this.userType,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      if (userType != null) 'user_type': userType!.wire,
      if (deviceId != null) 'device_id': deviceId,
    };
  }

  @override
  List<Object?> get props => [phone, password, userType, deviceId];
}
