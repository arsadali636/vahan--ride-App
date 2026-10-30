import 'package:equatable/equatable.dart';

import '../../../../core/storage/session_service.dart';

/// Response body for `POST /api/v1/auth/login/` and
/// `POST /api/v1/auth/verify-otp/`.
///
/// Matches the backend `TokenResponse` schema.
class TokenResponseModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }

  AuthTokenPair toTokenPair() {
    return AuthTokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType];
}
