import '../../../../core/storage/session_service.dart';
import '../repositories/auth_repository.dart';

/// Exchanges a refresh token for a fresh token pair.
///
/// Used by the networking layer's token refresh mechanism (the
/// `RefreshTokenInterceptor` refresh handler). The actual HTTP call lives in
/// the data layer; AuthBloc never triggers refresh directly.
class RefreshToken {
  final AuthRepository repository;

  RefreshToken(this.repository);

  Future<AuthTokenPair> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}
