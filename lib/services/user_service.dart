import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/auth_model/update_user_dto.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';

class UserService {
  UserService(this._api);

  final ApiClient _api;

  Future<List<UserRoleModel>> getRoles() async {
    final response = await _api.get(ApiConstants.roles);
    if (response is! Map<String, dynamic> || response['data'] is! List) {
      throw const ParsingException();
    }

    return (response['data'] as List).map((item) {
      if (item is! Map) throw const ParsingException();
      final role = UserRoleModel.fromJson(Map<String, dynamic>.from(item));
      if (role.rolId <= 0 || role.rolName.trim().isEmpty) {
        throw const ParsingException();
      }
      return role;
    }).where((role) => role.isActive).toList();
  }

  Future<PagedUsersResponse> getUsers({int page = 1, int limit = 10}) async {
    final response = await _api.get(
      ApiConstants.user,
      query: {'page': '$page', 'limit': '$limit'},
    );
    if (response is! Map<String, dynamic> ||
        response['data'] is! List ||
        response['meta'] is! Map) {
      throw const ParsingException();
    }

    final users = (response['data'] as List).map((item) {
      if (item is! Map) throw const ParsingException();
      return UserModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
    final meta = Map<String, dynamic>.from(response['meta'] as Map);
    return PagedUsersResponse(
      users: users,
      meta: UserPaginationMeta.fromJson(meta, fallbackCount: users.length),
    );
  }

  Future<void> createUser({
    required String userName,
    required String userLastName,
    required String password,
    required String mail,
    required String userPhone,
    required int roleId,
  }) async {
    await _api.post(
      ApiConstants.user,
      body: {
        'userName': userName,
        'userLastName': userLastName,
        'password': password,
        'mail': mail,
        'userPhone': userPhone,
        'rolesIds': [
          {'idRoles': roleId},
        ],
      },
    );
  }

  Future<void> updateManagedUser(int id, UpdateUserDto dto) async {
    await _api.put(ApiConstants.userById(id), body: dto.toJson());
  }

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

class PagedUsersResponse {
  const PagedUsersResponse({required this.users, required this.meta});

  final List<UserModel> users;
  final UserPaginationMeta meta;
}

class UserPaginationMeta {
  const UserPaginationMeta({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int itemsPerPage;
  final bool hasPreviousPage;
  final bool hasNextPage;

  factory UserPaginationMeta.fromJson(
    Map<String, dynamic> json, {
    required int fallbackCount,
  }) {
    int parseInt(String key, int fallback) {
      final value = json[key];
      if (value is num) return value.toInt();
      return int.tryParse('$value') ?? fallback;
    }

    return UserPaginationMeta(
      totalItems: parseInt('totalItems', parseInt('totalAmount', fallbackCount)),
      totalPages: parseInt('totalPages', 0),
      currentPage: parseInt('currentPage', 1),
      itemsPerPage: parseInt('itemsPerPage', 10),
      hasPreviousPage: json['hasPreviousPage'] is bool
          ? json['hasPreviousPage'] as bool
          : false,
      hasNextPage: json['hasNextPage'] is bool
          ? json['hasNextPage'] as bool
          : false,
    );
  }
}
