import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/core/models/user_model.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';

/// Configurable in-memory [SessionService] for tests.
class FakeSessionService implements SessionService {
  FakeSessionService({this.session});

  SessionData? session;
  bool? _profileCreated;

  @override
  Future<void> clearSession() async {
    session = null;
    _profileCreated = null;
  }

  @override
  Future<String?> getAccessToken() async {
    final token = session?.tokens.accessToken;
    return (token == null || token.isEmpty) ? null : token;
  }

  @override
  Future<String?> getRefreshToken() async {
    final token = session?.tokens.refreshToken;
    return (token == null || token.isEmpty) ? null : token;
  }

  @override
  Future<UserModel?> getCurrentUser() async => session?.profile;

  @override
  Future<String?> getUserId() async => session?.userId;

  @override
  Future<UserRole?> getUserRole() async => session?.userRole;

  @override
  Future<bool> isLoggedIn() async => session != null;

  @override
  Future<SessionData?> restoreSession() async => session;

  @override
  Future<bool> getProfileCreated() async =>
      _profileCreated ?? session?.profileCreated ?? false;

  @override
  Future<void> saveProfileCreated(bool profileCreated) async {
    _profileCreated = profileCreated;
    final current = session;
    if (current == null) return;
    session = SessionData(
      tokens: current.tokens,
      userId: current.userId,
      userRole: current.userRole,
      profile: current.profile,
      profileCreated: profileCreated,
    );
  }

  @override
  Future<void> saveSession({
    required AuthTokenPair tokens,
    String? userId,
    UserRole? userRole,
    UserModel? profile,
    bool? profileCreated,
  }) async {
    session = SessionData(
      tokens: tokens,
      userId: userId,
      userRole: userRole,
      profile: profile,
      profileCreated: profileCreated ?? false,
    );
  }

  @override
  Future<void> saveTokens(AuthTokenPair tokens) async {
    final current = session;
    session = SessionData(
      tokens: tokens,
      userId: current?.userId,
      userRole: current?.userRole,
      profile: current?.profile,
    );
  }
}
