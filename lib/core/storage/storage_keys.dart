/// Well-known keys used by [SecureStorageService] for persisted session data.
///
/// These are the only keys the app may write; they are collected here so the
/// key namespace stays stable across storage-layer refactors.
abstract class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'session.access_token';
  static const String refreshToken = 'session.refresh_token';
  static const String sessionId = 'session.session_id';
  static const String userId = 'session.user_id';
  static const String userRole = 'session.user_role';
  static const String userProfile = 'session.user_profile';
  static const String profileCreated = 'session.profile_created';
}
