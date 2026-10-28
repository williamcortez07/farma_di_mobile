import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/auth_model/update_user_dto.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';

class UserService {
  UserService(this._api);

  final ApiClient _api;

  /// Obtiene los datos del usuario especificado por su [id] desde la API.
  Future<UserModel> getUser(int id) async {
    final response = await _api.get(ApiConstants.userById(id));
    if (response is! Map<String, dynamic>) {
      throw const ParsingException();
    }
    return UserModel.fromJson(response);
  }

  /// Actualiza los datos del usuario en la API.
  Future<UserModel> updateUser(int id, UpdateUserDto dto) async {
    final response = await _api.put(
      ApiConstants.userById(id),
      body: dto.toJson(),
    );

    if (response is Map<String, dynamic> &&
        (response.containsKey('userName') ||
            response.containsKey('UserName') ||
            response.containsKey('user') ||
            response.containsKey('User') ||
            response.containsKey('data') ||
            response.containsKey('Data'))) {
      return UserModel.fromJson(response);
    }

    // Si la API responde con confirmación sin el objeto completo, re-consultamos
    return getUser(id);
  }
}
