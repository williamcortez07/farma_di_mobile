class UserRoleModel {
  const UserRoleModel({
    required this.rolId,
    required this.rolName,
  });

  final int rolId;
  final String rolName;

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      rolId: (json['rolId'] ?? json['RolId'] as num?)?.toInt() ?? 0,
      rolName: (json['rolName'] ?? json['RolName'] as String?) ?? '',
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

  static String? _extractString(Map<dynamic, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        final val = map[key];
        final str = val.toString().trim();
        if (str.isNotEmpty && str != 'null') {
          return str;
        }
      }
    }
    return null;
  }

  static int _extractInt(Map<dynamic, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        final val = map[key];
        if (val is num) return val.toInt();
        final parsed = int.tryParse(val.toString().trim());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  factory UserModel.fromJson(Map<String, dynamic> rawJson) {
    // Si la respuesta viene envuelta en 'user', 'data', 'result', etc.
    final dynamic unwrapped = rawJson['user'] ??
        rawJson['User'] ??
        rawJson['usuario'] ??
        rawJson['Usuario'] ??
        rawJson['data'] ??
        rawJson['Data'] ??
        rawJson['result'] ??
        rawJson['Result'] ??
        rawJson;

    final Map<dynamic, dynamic> json =
        unwrapped is Map ? unwrapped : rawJson;

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

    final id = _extractInt(json, ['id', 'Id', 'userId', 'UserId', 'idUser', 'IdUser']);

    String? userName = _extractString(
      json,
      ['userName', 'UserName', 'username', 'Username', 'name', 'Name', 'nombre', 'nombres', 'Nombre'],
    );

    String? userLastName = _extractString(
      json,
      [
        'userLastName',
        'UserLastName',
        'lastName',
        'LastName',
        'lastname',
        'Lastname',
        'apellido',
        'apellidos',
        'Apellido',
        'Apellidos',
      ],
    );

    final mail = _extractString(
      json,
      ['mail', 'Mail', 'email', 'Email', 'correo', 'Correo'],
    ) ?? '';

    final userPhone = _extractString(
      json,
      [
        'userPhone',
        'UserPhone',
        'phone',
        'Phone',
        'phoneNumber',
        'PhoneNumber',
        'phonenumber',
        'telephone',
        'Telephone',
        'telefono',
        'Telefono',
        'celular',
        'Celular',
      ],
    );

    final rolId = (json['rolId'] ?? json['RolId'] as num?)?.toInt();
    final isActive = (json['isActive'] ?? json['IsActive'] ?? true) as bool;

    // Si userLastName no viene provisto pero userName tiene espacios, separar limpiamente
    if ((userLastName == null || userLastName.isEmpty) && userName != null && userName.contains(' ')) {
      final parts = userName.split(RegExp(r'\s+'));
      if (parts.length > 1) {
        userName = parts.first;
        userLastName = parts.sublist(1).join(' ');
      }
    }

    return UserModel(
      id: id,
      userName: userName ?? '',
      userLastName: userLastName,
      mail: mail,
      userPhone: userPhone,
      rolId: rolId,
      isActive: isActive,
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
