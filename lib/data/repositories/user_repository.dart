import 'package:farma_di_mobile/data/models/auth_model/update_user_dto.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/services/user_service.dart';

class UserRepository {
  UserRepository(this._userService);

  final UserService _userService;

  /// Obtiene los datos del usuario especificado por su [id].
  Future<UserModel> getUser(int id) => _userService.getUser(id);

  /// Actualiza los datos permitidos del usuario especificado por su [id].
  Future<UserModel> updateUser(int id, UpdateUserDto dto) =>
      _userService.updateUser(id, dto);
}
