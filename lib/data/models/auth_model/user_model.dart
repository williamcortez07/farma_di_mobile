import 'package:farma_di_mobile/core/errors/app_exception.dart';

class UserModel {
  const UserModel({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['userName'] as String,
      email: (json['email'] as String?) ?? '',
    );
  }
}

class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.roleId,
    required this.roles,
    required this.isActive,
  });

  final int id;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final int roleId;
  final List<AppRoleModel> roles;
  final bool isActive;

  String get fullName => '$name $lastName'.trim();
  String get roleLabel => roles.isEmpty
      ? (roleId == 0 ? 'Sin rol' : 'Rol $roleId')
      : roles.map((role) => role.name).join(', ');

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final roleId = json['rolId'];
    if (id is! num || roleId is! num) {
      throw const ParsingException();
    }
    final roleData = json['roles'];
    final roles = roleData is List
        ? roleData
              .whereType<Map<String, dynamic>>()
              .map(AppRoleModel.fromJson)
              .toList()
        : <AppRoleModel>[];

    return AppUserModel(
      id: id.toInt(),
      name: json['userName'] as String? ?? '',
      lastName: json['userLastName'] as String? ?? '',
      email: json['mail'] as String? ?? '',
      phone: json['userPhone'] as String? ?? '',
      roleId: roleId.toInt(),
      roles: roles,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

class AppRoleModel {
  const AppRoleModel({required this.id, required this.name});

  final int id;
  final String name;

  factory AppRoleModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['rolId'];
    if (id is! num || json['rolName'] is! String) {
      throw const ParsingException();
    }
    return AppRoleModel(id: id.toInt(), name: json['rolName'] as String);
  }
}
