import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/data/repositories/auth_repository/user_repository.dart';
import 'package:farma_di_mobile/presentation/providers/user_provider.dart';

enum AuthStatus { initial, loading, success, error }

class AuthController extends ChangeNotifier {
  AuthController(this._repository, {this.userProvider});

  final AuthRepository _repository;
  final UserProvider? userProvider;

  AuthStatus status = AuthStatus.initial;
  String? errorMessage;
  UserModel? user;

  Future<bool> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(email, password);
      user = response.user;
      userProvider?.setUser(response.user);
      status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Ocurrió un error inesperado.';
    }

    status = AuthStatus.error;
    notifyListeners();
    return false;
  }
}
