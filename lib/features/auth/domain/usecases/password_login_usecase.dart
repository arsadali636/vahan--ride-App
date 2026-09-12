import 'package:equatable/equatable.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Signs a user in with their phone number and password.
///
/// Backed by `POST /api/v1/auth/login/`.
class PasswordLogin {
  final AuthRepository repository;

  PasswordLogin(this.repository);

  Future<AuthSession> call(PasswordLoginParams params) {
    return repository.passwordLogin(
      phone: params.phone,
      password: params.password,
      deviceId: params.deviceId,
    );
  }
}

class PasswordLoginParams extends Equatable {
  final String phone;
  final String password;
  final String? deviceId;

  const PasswordLoginParams({
    required this.phone,
    required this.password,
    this.deviceId,
  });

  @override
  List<Object?> get props => [phone, password, deviceId];
}
