import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

const _accessKey = 'gesper_access_token';
const _refreshKey = 'gesper_refresh_token';

/// Stockage des tokens JWT.
///
/// - Mobile (Android/iOS) : chiffré par le Keystore/Keychain natif via
///   `flutter_secure_storage`.
/// - Web/PWA : `flutter_secure_storage` n'a pas de backend natif et casse avec
///   un `OperationError` (Web Crypto). On retombe donc sur `GetStorage`
///   (localStorage), déjà initialisé dans `main`.
abstract class TokenStorage {
  factory TokenStorage() =>
      kIsWeb ? _WebTokenStorage() : _SecureTokenStorage();

  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> clear();
}

class _SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }
}

class _WebTokenStorage implements TokenStorage {
  final GetStorage _box = GetStorage();

  @override
  Future<String?> readAccessToken() async => _box.read<String>(_accessKey);

  @override
  Future<String?> readRefreshToken() async => _box.read<String>(_refreshKey);

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _box.write(_accessKey, accessToken);
    await _box.write(_refreshKey, refreshToken);
  }

  @override
  Future<void> clear() async {
    await _box.remove(_accessKey);
    await _box.remove(_refreshKey);
  }
}
