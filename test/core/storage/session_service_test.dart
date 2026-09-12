import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/core/enums/verification_status.dart';
import 'package:doc_connect_app/core/models/user_model.dart';
import 'package:doc_connect_app/core/storage/secure_storage_service.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';
import 'package:doc_connect_app/core/storage/storage_keys.dart';

class _MemorySecureStorage implements SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> clear() async => _store.clear();
}

void main() {
  late _MemorySecureStorage storage;
  late SessionServiceImpl service;

  setUp(() {
    storage = _MemorySecureStorage();
    service = SessionServiceImpl(storage);
  });

  const profile = UserModel(
    id: 'u-1',
    firstName: 'Ada',
    lastName: 'Lovelace',
    email: 'ada@mednexus.io',
    professionalHeadline: 'Cardiologist',
    verificationStatus: VerificationStatus.verified,
  );

  const tokens = AuthTokenPair(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  );

  test('isLoggedIn is false before a session exists', () async {
    expect(await service.isLoggedIn(), isFalse);
    expect(await service.restoreSession(), isNull);
  });

  test('saveSession then restoreSession round-trips the full session',
      () async {
    await service.saveSession(
      tokens: tokens,
      userId: 'u-1',
      userRole: UserRole.doctor,
      profile: profile,
    );

    final restored = await service.restoreSession();
    expect(restored, isNotNull);
    expect(restored!.tokens, tokens);
    expect(restored.userId, 'u-1');
    expect(restored.userRole, UserRole.doctor);
    expect(restored.profile, profile);

    expect(await service.isLoggedIn(), isTrue);
    expect(await service.getAccessToken(), 'access-token');
    expect(await service.getRefreshToken(), 'refresh-token');
    expect(await service.getUserId(), 'u-1');
    expect(await service.getUserRole(), UserRole.doctor);
    expect(await service.getCurrentUser(), profile);
  });

  test('saveTokens updates tokens without touching the rest of the session',
      () async {
    await service.saveSession(
      tokens: tokens,
      userId: 'u-1',
      userRole: UserRole.doctor,
      profile: profile,
    );
    const rotated = AuthTokenPair(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );

    await service.saveTokens(rotated);

    final restored = await service.restoreSession();
    expect(restored!.tokens, rotated);
    expect(restored.userId, 'u-1');
    expect(restored.userRole, UserRole.doctor);
    expect(restored.profile, profile);
  });

  test('clearSession wipes every persisted key', () async {
    await service.saveSession(
      tokens: tokens,
      userId: 'u-1',
      userRole: UserRole.doctor,
      profile: profile,
    );

    await service.clearSession();

    expect(await service.restoreSession(), isNull);
    expect(await service.isLoggedIn(), isFalse);
    expect(await service.getCurrentUser(), isNull);
    expect(await storage.read(StorageKeys.accessToken), isNull);
  });

  test('restoreSession returns null when tokens are incomplete', () async {
    await storage.write(StorageKeys.accessToken, 'only-access');
    expect(await service.restoreSession(), isNull);
  });

  test('corrupt cached profile does not break restoreSession', () async {
    await service.saveSession(tokens: tokens, userId: 'u-1');
    await storage.write(StorageKeys.userProfile, 'not-json{');

    final restored = await service.restoreSession();
    expect(restored, isNotNull);
    expect(restored!.tokens, tokens);
    expect(restored.profile, isNull);
  });
}
