import 'user_model.dart';

class LoginResponse {
  const LoginResponse({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ?? json['Token'] ?? '').toString();
    final userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : (json['usuario'] is Map
            ? Map<String, dynamic>.from(json['usuario'] as Map)
            : (json['data'] is Map
                ? Map<String, dynamic>.from(json['data'] as Map)
                : json));

    return LoginResponse(
      token: token,
      user: UserModel.fromJson(userMap),
    );
  }
}
