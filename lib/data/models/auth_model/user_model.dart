class UserRoleModel {
  const UserRoleModel({
    required this.rolId,
    required this.rolName,
  });

  final int rolId;
  final String rolName;

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      rolId: (json['rolId'] as num?)?.toInt() ?? 0,
      rolName: (json['rolName'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'rolId': rolId,
    'rolName': rolName,
  };
}

class UserModel {
  const UserModel({
    required this.id,
    required this.userName,
    this.userLastName,
    required this.mail,
    this.userPhone,
    this.rolId,
    this.isActive = true,
    this.roles = const [],
  });

  final int id;
  final String userName;
  final String? userLastName;
  final String mail;
  final String? userPhone;
  final int? rolId;
  final bool isActive;
  final List<UserRoleModel> roles;

  // Compatibilidad con código previo
  String get name => fullName;
  String get email => mail;

  String get fullName {
    final last = userLastName?.trim() ?? '';
    if (last.isEmpty) return userName.trim();
    return '${userName.trim()} $last';
  }

  String get primaryRole {
    if (roles.isNotEmpty && roles.first.rolName.isNotEmpty) {
      return roles.first.rolName;
    }
    return 'Usuario';
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  UserModel copyWith({
    int? id,
    String? userName,
    String? userLastName,
    String? mail,
    String? userPhone,
    int? rolId,
    bool? isActive,
    List<UserRoleModel>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userLastName: userLastName ?? this.userLastName,
      mail: mail ?? this.mail,
      userPhone: userPhone ?? this.userPhone,
      rolId: rolId ?? this.rolId,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] ?? json['Roles'];
    final rolesList = <UserRoleModel>[];
    if (rawRoles is List) {
      for (final r in rawRoles) {
        if (r is Map<String, dynamic>) {
          rolesList.add(UserRoleModel.fromJson(r));
        } else if (r is Map) {
          rolesList.add(UserRoleModel.fromJson(Map<String, dynamic>.from(r)));
        }
      }
    }

    final rawId = json['id'] ?? json['Id'];
    final idInt = rawId is num ? rawId.toInt() : (int.tryParse(rawId?.toString() ?? '0') ?? 0);

    return UserModel(
      id: idInt,
      userName: (json['userName'] ?? json['UserName'] ?? json['name'] ?? '').toString(),
      userLastName: json['userLastName'] as String? ?? json['UserLastName'] as String?,
      mail: (json['mail'] ?? json['Mail'] ?? json['email'] ?? json['Email'] ?? '').toString(),
      userPhone: json['userPhone'] as String? ?? json['UserPhone'] as String?,
      rolId: (json['rolId'] as num?)?.toInt() ?? (json['RolId'] as num?)?.toInt(),
      isActive: (json['isActive'] ?? json['IsActive'] ?? true) as bool,
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'userLastName': userLastName,
    'mail': mail,
    'userPhone': userPhone,
    'rolId': rolId,
    'isActive': isActive,
    'roles': roles.map((r) => r.toJson()).toList(),
  };
}
