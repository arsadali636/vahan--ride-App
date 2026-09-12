import 'package:equatable/equatable.dart';

import '../../../../core/enums/user_role.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Creates a new doctor/hospital account and signs the user in.
///
/// Backed by `POST /api/v1/auth/register/`.
class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<AuthSession> call(RegisterParams params) {
    return repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      password: params.password,
      userType: params.userType,
      email: params.email,
    );
  }
}

class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final UserRole userType;
  final String? email;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    this.userType = UserRole.doctor,
    this.email,
  });

  @override
  List<Object?> get props =>
      [firstName, lastName, phone, password, userType, email];
}
