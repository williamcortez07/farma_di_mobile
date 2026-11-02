import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/data/repositories/app_user_repository.dart';

enum UserStatus { initial, loading, success, error }

class UserController extends ChangeNotifier {
  UserController(this._repository);

  final UserRepository _repository;
  UserStatus status = UserStatus.initial;
  String? errorMessage;
  List<AppUserModel> users = [];
  final Map<int, AppRoleModel> _availableRoles = {};
  List<AppRoleModel> get availableRoles => _availableRoles.values.toList();
  int currentPage = 1;
  int limit = 10;
  int totalPages = 1;
  int totalItems = 0;
  bool hasPreviousPage = false;
  bool hasNextPage = false;

  Future<void> fetchUsers({int page = 1}) async {
    status = UserStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getUsers(page: page, limit: limit);
      users = response.users;
      for (final user in users) {
        for (final role in user.roles) {
          _availableRoles[role.id] = role;
        }
      }
      currentPage = response.meta.currentPage;
      limit = response.meta.itemsPerPage;
      totalPages = response.meta.totalPages < 1 ? 1 : response.meta.totalPages;
      totalItems = response.meta.totalItems;
      hasPreviousPage = response.meta.hasPreviousPage;
      hasNextPage = response.meta.hasNextPage;
      status = UserStatus.success;
    } on AppException catch (error) {
      errorMessage = error.message;
      status = UserStatus.error;
    } catch (_) {
      errorMessage = 'No se pudo cargar el personal.';
      status = UserStatus.error;
    }

    notifyListeners();
  }

  Future<void> nextPage() async {
    if (hasNextPage && status != UserStatus.loading) {
      await fetchUsers(page: currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (hasPreviousPage && status != UserStatus.loading) {
      await fetchUsers(page: currentPage - 1);
    }
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
    await _repository.updateUser(
      user,
      name: name,
      lastName: lastName,
      email: email,
      phone: phone,
      isActive: isActive,
      password: password,
    );
    await fetchUsers(page: currentPage);
  }

  Future<void> createUser({
    required String name,
    required String lastName,
    required String password,
    required String email,
    required String phone,
    required int roleId,
  }) async {
    await _repository.createUser(
      name: name,
      lastName: lastName,
      password: password,
      email: email,
      phone: phone,
      roleId: roleId,
    );
    await fetchUsers(page: 1);
  }
}
