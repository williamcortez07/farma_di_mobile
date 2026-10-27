import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/auth_model/update_user_dto.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  /// Obtiene los datos del usuario especificado por su [id].
  Future<UserModel> getUser(int id) async {
    final response = await _api.get(ApiConstants.userById(id));
    if (response is! Map<String, dynamic>) {
      throw const ParsingException();
    }
    return UserModel.fromJson(response);
  }

  /// Actualiza los datos permitidos del usuario especificado por su [id].
  Future<UserModel> updateUser(int id, UpdateUserDto dto) async {
    final response = await _api.put(
      ApiConstants.userById(id),
      body: dto.toJson(),
    );

    if (response is Map<String, dynamic> && response.containsKey('userName')) {
      return UserModel.fromJson(response);
    }

    // Si la API responde confirmación sin el objeto completo, re-consultamos
    // para asegurar la consistencia y datos confirmados del backend.
    return getUser(id);
  }
}
