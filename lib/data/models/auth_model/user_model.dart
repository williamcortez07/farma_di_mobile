import 'package:farma_di_mobile/core/errors/app_exception.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

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
    required this.isActive,
  });

  final int id;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final int roleId;
  final bool isActive;

  String get fullName => '$name $lastName'.trim();
  String get roleLabel => 'Rol $roleId';

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final roleId = json['rolId'];
    if (id is! num || roleId is! num) {
      throw const ParsingException();
    }
    return AppUserModel(
      id: id.toInt(),
      name: json['userName'] as String? ?? '',
      lastName: json['userLastName'] as String? ?? '',
      email: json['mail'] as String? ?? '',
      phone: json['userPhone'] as String? ?? '',
      roleId: roleId.toInt(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}