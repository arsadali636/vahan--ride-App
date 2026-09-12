import 'package:equatable/equatable.dart';

import '../../domain/entities/otp_purpose.dart';

/// Request body for `POST /api/v1/auth/send-otp/`.
///
/// Matches the backend `OTPRequest` schema.
class SendOtpRequestModel extends Equatable {
  final String phone;
  final OtpPurpose purpose;

  const SendOtpRequestModel({
    required this.phone,
    required this.purpose,
  });

  factory SendOtpRequestModel.fromJson(Map<String, dynamic> json) {
    return SendOtpRequestModel(
      phone: json['phone'] as String? ?? '',
      purpose: OtpPurpose.fromWire(json['purpose'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'purpose': purpose.wire,
    };
  }

  @override
  List<Object?> get props => [phone, purpose];
}
