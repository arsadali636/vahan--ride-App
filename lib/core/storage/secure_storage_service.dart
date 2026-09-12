import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Low-level secure key/value storage backed by the platform keychain.
///
/// Used exclusively for sensitive session data (tokens, user identity).
/// Nothing here is meant to be shared with non-secure persistence.
abstract class SecureStorageService {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<void> clear();
}

class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}
