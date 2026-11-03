import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/auth_model/update_user_dto.dart';
import '../../data/models/auth_model/user_model.dart';
import '../../data/repositories/user_repository.dart';

enum RolesStatus { initial, loading, success, error }

class RolesController extends ChangeNotifier {
  RolesController(this._repository);

  final UserRepository _repository;
  RolesStatus status = RolesStatus.initial;
  String? errorMessage;
  String? rolesErrorMessage;
  List<UserModel> users = [];
  List<UserRoleModel> roles = [];
  List<UserModel>? _unpagedUsers;
  int currentPage = 1;
  int limit = 10;
  int totalPages = 1;
  int totalItems = 0;
  bool hasPreviousPage = false;
  bool hasNextPage = false;

  Future<void> fetchUsers({int page = 1}) async {
    if (_unpagedUsers != null) {
      _showLocalPage(page);
      return;
    }

    status = RolesStatus.loading;
    errorMessage = null;
    notifyListeners();

    if (roles.isEmpty) {
      rolesErrorMessage = null;
      try {
        roles = await _repository.getRoles();
      } on AppException catch (error) {
        rolesErrorMessage = error.message;
      } catch (_) {
        rolesErrorMessage = 'No se pudieron cargar los roles disponibles.';
      }
    }

    try {
      final requestLimit = limit;
      final response = await _repository.getUsers(page: page, limit: requestLimit);
      limit = requestLimit;

      if (response.users.length > limit) {
        // Respaldo cuando el servidor ignora page/limit y devuelve la colección completa.
        _unpagedUsers = response.users;
        _showLocalPage(page);
      } else {
        users = response.users;
        currentPage = response.meta.currentPage;
        totalItems = response.meta.totalItems > response.users.length
            ? response.meta.totalItems
            : response.users.length;
        final calculatedPages = (totalItems / limit).ceil();
        totalPages = response.meta.totalPages > calculatedPages
            ? response.meta.totalPages
            : calculatedPages;
        if (totalPages < 1) totalPages = 1;
        hasPreviousPage =
            response.meta.hasPreviousPage || currentPage > 1;
        hasNextPage =
            response.meta.hasNextPage || currentPage < totalPages;
        status = RolesStatus.success;
      }
    } on AppException catch (error) {
      errorMessage = error.message;
      status = RolesStatus.error;
    } catch (_) {
      errorMessage = 'No se pudo cargar el personal.';
      status = RolesStatus.error;
    }

    notifyListeners();
  }

  void _showLocalPage(int page) {
    final allUsers = _unpagedUsers!;
    totalItems = allUsers.length;
    totalPages = (totalItems / limit).ceil();
    if (totalPages < 1) totalPages = 1;
    currentPage = page.clamp(1, totalPages).toInt();
    final start = (currentPage - 1) * limit;
    final end = (start + limit).clamp(0, allUsers.length).toInt();
    users = allUsers.sublist(start, end);
    hasPreviousPage = currentPage > 1;
    hasNextPage = currentPage < totalPages;
    status = RolesStatus.success;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> nextPage() async {
    if (status != RolesStatus.loading && hasNextPage) {
      await fetchUsers(page: currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (status != RolesStatus.loading && hasPreviousPage) {
      await fetchUsers(page: currentPage - 1);
    }
  }

  Future<void> createUser({
    required String userName,
    required String userLastName,
    required String password,
    required String mail,
    required String userPhone,
    required int roleId,
  }) async {
    await _repository.createUser(
      userName: userName,
      userLastName: userLastName,
      password: password,
      mail: mail,
      userPhone: userPhone,
      roleId: roleId,
    );
    _unpagedUsers = null;
    await fetchUsers(page: 1);
  }

  Future<void> updateUser({
    required UserModel user,
    required String userName,
    required String userLastName,
    required String mail,
    required String userPhone,
    required bool isActive,
    int? roleId,
    String? password,
  }) async {
    try {
      await _repository.updateManagedUser(
        user.id,
        UpdateUserDto(
          userName: userName,
          userLastName: userLastName,
          mail: mail,
          userPhone: userPhone,
          isActive: isActive,
          password: password,
        ),
      );
      final currentRoleId = user.roles.isNotEmpty && user.roles.first.rolId > 0
          ? user.roles.first.rolId
          : (user.rolId != null && user.rolId! > 0 ? user.rolId : null);
      if (roleId != null && roleId != currentRoleId) {
        await _repository.assignUserRole(user.id, roleId);
      }
    } finally {
      _unpagedUsers = null;
      await fetchUsers(page: currentPage);
    }
  }
}
