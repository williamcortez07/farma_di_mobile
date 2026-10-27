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
