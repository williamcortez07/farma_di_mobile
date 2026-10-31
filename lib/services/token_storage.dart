import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _tokenKey);
  Future<void> save(String token) => _storage.write(key: _tokenKey, value: token);

  Future<int?> readUserId() async {
    final str = await _storage.read(key: _userIdKey);
    if (str == null) return null;
    return int.tryParse(str);
  }

  Future<void> saveUserId(int id) => _storage.write(key: _userIdKey, value: id.toString());

  Future<UserModel?> readUser() async {
    final str = await _storage.read(key: _userKey);
    if (str == null || str.isEmpty) return null;
    try {
      final json = jsonDecode(str) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userKey);
  }
}
