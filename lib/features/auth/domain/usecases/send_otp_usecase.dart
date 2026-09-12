import 'package:equatable/equatable.dart';

import '../entities/otp_purpose.dart';
import '../entities/send_otp_result.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<SendOtpResult> call(SendOtpParams params) {
    return repository.sendOtp(
      phone: params.phone,
      purpose: params.purpose,
    );
  }
}

class SendOtpParams extends Equatable {
  final String phone;
  final OtpPurpose purpose;

  const SendOtpParams({required this.phone, required this.purpose});

  @override
  List<Object?> get props => [phone, purpose];
}
