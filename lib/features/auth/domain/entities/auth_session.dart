import 'package:equatable/equatable.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/storage/session_service.dart';

/// Result of a successful sign-in (register, password login or OTP verify).
///
/// Carries the token pair and, when the backend returns them (registration),
/// the created user's id and role. Persisting the session is the
/// responsibility of the presentation layer via [SessionService].
class AuthSession extends Equatable {
  final AuthTokenPair tokens;
  final String? userId;
  final UserRole? userRole;
  final bool profileCreated;

  const AuthSession({
    required this.tokens,
    this.userId,
    this.userRole,
    this.profileCreated = false,
  });

  @override
  List<Object?> get props => [tokens, userId, userRole, profileCreated];
}
