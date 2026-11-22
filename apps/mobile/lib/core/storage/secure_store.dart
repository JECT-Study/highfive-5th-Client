import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 인증 정보 저장소. 토큰은 여기에만 둔다 (prefs·로그 금지).
/// 키 이름은 이 파일의 상수만 쓴다.
class SecureStore {
  SecureStore(this._storage);

  final FlutterSecureStorage _storage;

  static const accessTokenKey = 'auth.accessToken';
  static const refreshTokenKey = 'auth.refreshToken';

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);
}
