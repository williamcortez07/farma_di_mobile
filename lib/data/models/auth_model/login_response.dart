import 'user_model.dart';

class LoginResponse {
  const LoginResponse({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] as String,
        user: UserModel.fromJson(json),
      );
}