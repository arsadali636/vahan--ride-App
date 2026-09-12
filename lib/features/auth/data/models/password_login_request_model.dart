import 'package:equatable/equatable.dart';

/// Request body for `POST /api/v1/auth/login/`.
///
/// Matches the backend `PasswordLoginRequest` schema. `device_id` is optional.
class PasswordLoginRequestModel extends Equatable {
  final String phone;
  final String password;
  final String? deviceId;

  const PasswordLoginRequestModel({
    required this.phone,
    required this.password,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      if (deviceId != null) 'device_id': deviceId,
    };
  }

  @override
  List<Object?> get props => [phone, password, deviceId];
}
