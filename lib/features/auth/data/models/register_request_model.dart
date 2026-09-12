import 'package:equatable/equatable.dart';

import '../../../../core/enums/user_role.dart';

/// Request body for `POST /api/v1/auth/register/`.
///
/// Matches the backend `RegisterRequest` schema. `email` is optional; it is
/// omitted from the payload when null.
class RegisterRequestModel extends Equatable {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final UserRole userType;
  final String? email;

  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    this.userType = UserRole.doctor,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'password': password,
      'user_type': userType.wire,
      if (email != null) 'email': email,
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, phone, password, userType, email];
}
