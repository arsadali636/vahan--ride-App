import '../../../../core/storage/session_service.dart';
import '../repositories/auth_repository.dart';

/// Signs the user out.
///
/// Best-effort call to `POST /api/v1/auth/logout/` (which may fail when the
/// access token is already expired), followed by clearing the persisted local
/// session so the user is signed out on-device regardless of the server
/// result.
class Logout {
  final AuthRepository repository;
  final SessionService sessionService;

  Logout(this.repository, this.sessionService);

  Future<void> call() async {
    try {
      await repository.logout();
    } catch (_) {
      // Local sign-out must still happen even if the server rejects the call.
    } finally {
      await sessionService.clearSession();
    }
  }
}
