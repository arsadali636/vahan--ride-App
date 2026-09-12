import 'package:equatable/equatable.dart';

/// Request body for `POST /api/v1/auth/refresh/`.
///
/// Matches the backend `RefreshRequest` schema (`refresh_token`).
class RefreshTokenRequestModel extends Equatable {
  final String refreshToken;

  const RefreshTokenRequestModel({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken};
  }

  @override
  List<Object?> get props => [refreshToken];
}
