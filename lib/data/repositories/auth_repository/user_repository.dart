import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/auth_model/login_request.dart';
import 'package:farma_di_mobile/data/models/auth_model/login_response.dart';
import 'package:farma_di_mobile/services/token_storage.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokenStorage);

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  Future<LoginResponse> login(String userName, String password) async {
    try {
      final json = await _api.post(
        ApiConstants.login,
        body: LoginRequest(userName: userName, password: password).toJson(),
      );
      final response = LoginResponse.fromJson(json as Map<String, dynamic>);
      await _tokenStorage.save(response.token);
      await _tokenStorage.saveUserId(response.user.id);
      await _tokenStorage.saveUser(response.user);
      return response;
    } on UnauthorizedException {
      throw const InvalidCredentialsException();
    } on TypeError {
      throw const ParsingException();
    }
  }

  Future<void> logout() => _tokenStorage.clear();
}
