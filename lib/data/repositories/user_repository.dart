import 'package:farma_di_mobile/data/models/auth_model/update_user_dto.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/services/user_service.dart';

class UserRepository {
  UserRepository(this._userService);

  final UserService _userService;

  /// Obtiene los datos del usuario especificado por su [id].
  Future<UserModel> getUser(int id) => _userService.getUser(id);

  Future<PagedUsersResponse> getUsers({int page = 1, int limit = 10}) =>
      _userService.getUsers(page: page, limit: limit);

  Future<List<UserRoleModel>> getRoles() => _userService.getRoles();

  Future<void> createUser({
    required String userName,
    required String userLastName,
    required String password,
    required String mail,
    required String userPhone,
    required int roleId,
  }) => _userService.createUser(
    userName: userName,
    userLastName: userLastName,
    password: password,
    mail: mail,
    userPhone: userPhone,
    roleId: roleId,
  );

  Future<void> updateManagedUser(int id, UpdateUserDto dto) =>
      _userService.updateManagedUser(id, dto);

  /// Actualiza los datos permitidos del usuario especificado por su [id].
  Future<UserModel> updateUser(int id, UpdateUserDto dto) =>
      _userService.updateUser(id, dto);
}
