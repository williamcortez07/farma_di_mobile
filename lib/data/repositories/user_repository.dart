
import 'package:farma_di_mobile/core/network/api_client.dart';

class UserRepository {
  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
  }) async {
    final response = await _api.post(
      'api/Auth/login',
      body: {
        'UserName': userName.trim(),
        'Password': password,
      },
    );

    if (response is! Map) {
      throw Exception('La respuesta de autenticaci├│n no es v├ílida.');
    }

    final data = Map<String, dynamic>.from(response);

    String value(String key) {
      final entry = data.entries.where(
        (e) => e.key.toLowerCase() == key.toLowerCase(),
      );

      return entry.isEmpty ? '' : '${entry.first.value ?? ''}';
    }

    final token = value('Token');

    if (token.isEmpty) {
      throw Exception('La API no devolvi├│ el token de acceso.');
    }

    _api.setToken(token);

    return {
      'id': value('Id'),
      'userName': value('UserName'),
      'email': value('Email'),
      'token': token,
      'roles': data['Roles'] ?? data['roles'] ?? [],
    };
  }

  void logout() {
    _api.setToken(null);
  }
}
