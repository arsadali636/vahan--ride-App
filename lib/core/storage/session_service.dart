import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../enums/user_role.dart';
import '../models/user_model.dart';
import 'secure_storage_service.dart';
import 'storage_keys.dart';

/// Immutable pair of access + refresh tokens returned by the auth backend.
///
/// Wire shape matches `TokenResponse` (`access_token`, `refresh_token`).
class AuthTokenPair extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthTokenPair({required this.accessToken, required this.refreshToken});

  factory AuthTokenPair.fromJson(Map<String, dynamic> json) {
    return AuthTokenPair(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

/// Snapshot of everything persisted for an authenticated session.
class SessionData extends Equatable {
  final AuthTokenPair tokens;
  final String? userId;
  final UserRole? userRole;
  final UserModel? profile;
  final bool profileCreated;

  const SessionData({
    required this.tokens,
    this.userId,
    this.userRole,
    this.profile,
    this.profileCreated = false,
  });

  @override
  List<Object?> get props => [tokens, userId, userRole, profile, profileCreated];
}

/// Centralized access to the authenticated session.
///
/// All sensitive values are persisted through [SecureStorageService]
/// (platform keychain) — never SharedPreferences. Passwords are never stored.
/// This service owns all JSON encode/decode so callers never parse JSON.
abstract class SessionService {
  Future<void> saveSession({
    required AuthTokenPair tokens,
    String? userId,
    UserRole? userRole,
    UserModel? profile,
    bool? profileCreated,
  });

  Future<void> saveTokens(AuthTokenPair tokens);

  Future<SessionData?> restoreSession();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<String?> getUserId();

  Future<UserRole?> getUserRole();

  Future<UserModel?> getCurrentUser();

  /// Whether the registered account already has a professional profile.
  Future<bool> getProfileCreated();

  /// Marks whether the account has a professional profile.
  Future<void> saveProfileCreated(bool profileCreated);

  Future<bool> isLoggedIn();

  Future<void> clearSession();
}

class SessionServiceImpl implements SessionService {
  SessionServiceImpl(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> saveSession({
    required AuthTokenPair tokens,
    String? userId,
    UserRole? userRole,
    UserModel? profile,
    bool? profileCreated,
  }) async {
    await saveTokens(tokens);
    if (userId != null) await _storage.write(StorageKeys.userId, userId);
    if (userRole != null) await _storage.write(StorageKeys.userRole, userRole.name);
    if (profile != null) {
      await _storage.write(
        StorageKeys.userProfile,
        jsonEncode(profile.toJson()),
      );
    }
    if (profileCreated != null) {
      await _storage.write(
        StorageKeys.profileCreated,
        profileCreated.toString(),
      );
    }
  }

  @override
  Future<void> saveTokens(AuthTokenPair tokens) async {
    await _storage.write(StorageKeys.accessToken, tokens.accessToken);
    await _storage.write(StorageKeys.refreshToken, tokens.refreshToken);
  }

  @override
  Future<SessionData?> restoreSession() async {
    final accessToken = await _storage.read(StorageKeys.accessToken);
    final refreshToken = await _storage.read(StorageKeys.refreshToken);
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return null;
    }

    final userId = await _storage.read(StorageKeys.userId);
    final roleName = await _storage.read(StorageKeys.userRole);
    final profileJson = await _storage.read(StorageKeys.userProfile);
    final profileCreated = await _storage.read(StorageKeys.profileCreated);

    UserModel? profile;
    if (profileJson != null && profileJson.isNotEmpty) {
      try {
        profile = UserModel.fromJson(
          (jsonDecode(profileJson) as Map).cast<String, dynamic>(),
        );
      } catch (_) {
        profile = null;
      }
    }

    return SessionData(
      tokens: AuthTokenPair(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
      userId: userId,
      userRole: _userRoleFromName(roleName),
      profile: profile,
      profileCreated: profileCreated == 'true',
    );
  }

  @override
  Future<String?> getAccessToken() => _storage.read(StorageKeys.accessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(StorageKeys.refreshToken);

  @override
  Future<String?> getUserId() => _storage.read(StorageKeys.userId);

  @override
  Future<UserRole?> getUserRole() async {
    final roleName = await _storage.read(StorageKeys.userRole);
    return _userRoleFromName(roleName);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final profileJson = await _storage.read(StorageKeys.userProfile);
    if (profileJson == null || profileJson.isEmpty) return null;
    try {
      return UserModel.fromJson(
        (jsonDecode(profileJson) as Map).cast<String, dynamic>(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> getProfileCreated() async {
    final value = await _storage.read(StorageKeys.profileCreated);
    return value == 'true';
  }

  @override
  Future<void> saveProfileCreated(bool profileCreated) async {
    await _storage.write(StorageKeys.profileCreated, profileCreated.toString());
  }

  @override
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  @override
  Future<void> clearSession() => _storage.clear();

  UserRole? _userRoleFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final role in UserRole.values) {
      if (role.name == name) return role;
    }
    return null;
  }
}
