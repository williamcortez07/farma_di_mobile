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
  List<AppUserModel>? _unpagedUsers;
  final Map<int, AppRoleModel> _availableRoles = {};
  List<AppRoleModel> get availableRoles => _availableRoles.values.toList();
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
    status = UserStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      if (_availableRoles.isEmpty) {
        final roles = await _repository.getRoles();
        for (final role in roles) {
          _availableRoles[role.id] = role;
        }
      }
      final response = await _repository.getUsers(page: page, limit: limit);
      final requestLimit = limit;
      for (final user in response.users) {
        for (final role in user.roles) {
          _availableRoles[role.id] = role;
        }
      }
      limit = response.meta.itemsPerPage > 0
          ? response.meta.itemsPerPage
          : requestLimit;
      if (response.users.length > limit) {
        
        _unpagedUsers = response.users;
        totalItems = response.meta.totalItems > response.users.length
            ? response.meta.totalItems
            : response.users.length;
        totalPages = (totalItems / limit).ceil();
        _showLocalPage(page);
      } else {
        users = response.users;
        currentPage = response.meta.currentPage;
        totalPages = response.meta.totalPages < 1 ? 1 : response.meta.totalPages;
        totalItems = response.meta.totalItems;
        hasPreviousPage =
            response.meta.hasPreviousPage || currentPage > 1;
        hasNextPage =
            response.meta.hasNextPage || currentPage < totalPages;
      }
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

  void _showLocalPage(int page) {
    final allUsers = _unpagedUsers!;
    totalPages = (allUsers.length / limit).ceil();
    if (totalPages < 1) totalPages = 1;
    currentPage = page.clamp(1, totalPages).toInt();
    totalItems = allUsers.length;
    final start = (currentPage - 1) * limit;
    final end = (start + limit).clamp(0, allUsers.length).toInt();
    users = allUsers.sublist(start, end);
    hasPreviousPage = currentPage > 1;
    hasNextPage = currentPage < totalPages;
    status = UserStatus.success;
    errorMessage = null;
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
    _unpagedUsers = null;
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
    _unpagedUsers = null;
    await fetchUsers(page: 1);
  }
}
