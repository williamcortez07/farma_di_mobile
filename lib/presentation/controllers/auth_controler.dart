import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';

enum AuthStatus { initial, loading, success, error }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

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