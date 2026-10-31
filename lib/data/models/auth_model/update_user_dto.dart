class UpdateUserDto {
  const UpdateUserDto({
    required this.userName,
    required this.userLastName,
    required this.mail,
    required this.userPhone,
    this.password,
    this.isActive = true,
  });

  final String userName;
  final String userLastName;
  final String mail;
  final String userPhone;
  final String? password;
  final bool isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userName': userName,
      'userLastName': userLastName,
      'mail': mail,
      'userPhone': userPhone,
      'isActive': isActive,
    };
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    return map;
  }
}
