import '../../../../core/storage/session_service.dart';

/// Restores the persisted session (tokens, user id, role) from secure storage
/// at application startup.
class RestoreSession {
  final SessionService sessionService;

  RestoreSession(this.sessionService);

  Future<SessionData?> call() => sessionService.restoreSession();
}
