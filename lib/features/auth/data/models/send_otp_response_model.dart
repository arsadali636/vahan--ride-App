import 'package:equatable/equatable.dart';

import '../../domain/entities/send_otp_result.dart';

/// Response body for `POST /api/v1/auth/send-otp/`.
///
/// `otp` is only present in development (SMS disabled) and must be treated as
/// nullable.
class SendOtpResponseModel extends Equatable {
  final bool success;
  final String message;
  final int expiresIn;
  final String? otp;

  const SendOtpResponseModel({
    required this.success,
    required this.message,
    required this.expiresIn,
    this.otp,
  });

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return SendOtpResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      otp: json['otp'] as String?,
    );
  }

  SendOtpResult toEntity() {
    return SendOtpResult(
      success: success,
      message: message,
      expiresIn: expiresIn,
      otp: otp,
    );
  }

  @override
  List<Object?> get props => [success, message, expiresIn, otp];
}
