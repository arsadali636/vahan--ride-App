import 'package:equatable/equatable.dart';

/// Result of requesting an OTP.
///
/// `otp` is only populated in development while SMS is disabled; in production
/// it is null and the code is delivered over SMS.
class SendOtpResult extends Equatable {
  final bool success;
  final String message;

  /// OTP validity window in seconds (e.g. 300 = 5 minutes).
  final int expiresIn;

  /// Dev-only OTP value. Null in production (SMS enabled).
  final String? otp;

  const SendOtpResult({
    required this.success,
    required this.message,
    required this.expiresIn,
    this.otp,
  });

  @override
  List<Object?> get props => [success, message, expiresIn, otp];
}
