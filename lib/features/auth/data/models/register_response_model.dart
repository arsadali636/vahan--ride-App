import 'package:equatable/equatable.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/storage/session_service.dart';
import '../../domain/entities/auth_session.dart';

/// Response body for `POST /api/v1/auth/register/`.
///
/// Matches the backend `RegisterResponse` schema. Unlike a plain
/// `TokenResponse`, registration also returns the created user's id, role and
/// whether a profile was auto-created.
class RegisterResponseModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final UserRole userType;
  final bool profileCreated;

  const RegisterResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.userType,
    required this.profileCreated,
    this.tokenType = 'bearer',
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      userId: json['user_id'] as String? ?? '',
      userType: UserRole.fromWire(json['user_type'] as String? ?? ''),
      profileCreated: json['profile_created'] as bool? ?? false,
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      tokens: AuthTokenPair(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
      userId: userId.isEmpty ? null : userId,
      userRole: userType,
      profileCreated: profileCreated,
    );
  }

  @override
  List<Object?> get props =>
      [accessToken, refreshToken, tokenType, userId, userType, profileCreated];
}
