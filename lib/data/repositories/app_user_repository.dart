import 'package:farma_di_mobile/core/constants/api_constants.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<AppRoleModel>> getRoles() async {
    final response = await _api.get(ApiConstants.roles);
    if (response is! Map<String, dynamic> || response['data'] is! List) {
      throw const ParsingException();
    }
    return (response['data'] as List).map((item) {
      if (item is! Map<String, dynamic>) throw const ParsingException();
      return AppRoleModel.fromJson(item);
    }).toList();
  }

  Future<void> createUser({
    required String name,
    required String lastName,
    required String password,
    required String email,
    required String phone,
    required int roleId,
  }) async {
    await _api.post(
      ApiConstants.users,
      body: {
        'userName': name,
        'userLastName': lastName,
        'password': password,
        'mail': email,
        'userPhone': phone,
        'rolesIds': [
          {'idRoles': roleId},
        ],
      },
    );
  }

  Future<PagedUsersResponse> getUsers({int page = 1, int limit = 10}) async {
    final response = await _api.get(
      ApiConstants.users,
      query: {'page': page.toString(), 'limit': limit.toString()},
    );

    if (response is! Map<String, dynamic> ||
        response['data'] is! List ||
        response['meta'] is! Map<String, dynamic>) {
      throw const ParsingException();
    }

    final users = (response['data'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const ParsingException();
      }
      return AppUserModel.fromJson(item);
    }).toList();

    return PagedUsersResponse(
      users: users,
      meta: UserPaginationMeta.fromJson(
        response['meta'] as Map<String, dynamic>,
      ),
    );
  }

  Future<void> updateUser(
    AppUserModel user, {
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required bool isActive,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'userName': name,
      'userLastName': lastName,
      'mail': email,
      'userPhone': phone,
      'isActive': isActive,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }
    await _api.put(ApiConstants.userById(user.id), body: body);
  }
}

class PagedUsersResponse {
  const PagedUsersResponse({required this.users, required this.meta});

  final List<AppUserModel> users;
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

  factory UserPaginationMeta.fromJson(Map<String, dynamic> json) {
    return UserPaginationMeta(
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 10,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}
