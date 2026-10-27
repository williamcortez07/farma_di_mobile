import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/auth_model/update_user_dto.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/data/repositories/auth_repository/user_repository.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';
import 'package:farma_di_mobile/services/token_storage.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({
    required this.userRepository,
    required this.authRepository,
    required this.tokenStorage,
  });

  final UserRepository userRepository;
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Establece el usuario autenticado en memoria y caché local.
  void setUser(UserModel user) {
    _user = user;
    _errorMessage = null;
    tokenStorage.saveUser(user);
    tokenStorage.saveUserId(user.id);
    notifyListeners();
  }

  /// Carga el perfil del usuario autenticado.
  /// Si ya se encuentra en memoria y no se fuerza recarga, evita peticiones redundantes.
  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (_user != null && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int? userId = _user?.id ?? await tokenStorage.readUserId();

      if (userId == null) {
        final cached = await tokenStorage.readUser();
        if (cached != null) {
          _user = cached;
          userId = cached.id;
        }
      }

      if (userId != null && userId > 0) {
        final freshUser = await userRepository.getUser(userId);
        _user = freshUser;
        await tokenStorage.saveUser(freshUser);
      } else {
        _errorMessage = 'No se encontró una sesión activa.';
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No fue posible cargar el perfil del usuario.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza la información personal permitida (nombres, apellidos, correo, teléfono).
  /// El rol nunca se modifica desde esta operación.
  Future<bool> updateProfile({
    required String userName,
    required String userLastName,
    required String mail,
    required String userPhone,
  }) async {
    final current = _user;
    if (current == null) {
      _errorMessage = 'No hay una sesión activa para actualizar.';
      notifyListeners();
      return false;
    }

    final trimmedName = userName.trim();
    final trimmedLastName = userLastName.trim();
    final trimmedMail = mail.trim();
    final trimmedPhone = userPhone.trim();

    if (trimmedName.isEmpty || trimmedLastName.isEmpty) {
      _errorMessage = 'Nombres y apellidos son requeridos.';
      notifyListeners();
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedMail)) {
      _errorMessage = 'Ingresa un correo electrónico válido.';
      notifyListeners();
      return false;
    }

    if (trimmedPhone.isEmpty) {
      _errorMessage = 'Ingresa un número telefónico válido.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = UpdateUserDto(
        userName: trimmedName,
        userLastName: trimmedLastName,
        mail: trimmedMail,
        userPhone: trimmedPhone,
        isActive: current.isActive,
      );

      final updated = await userRepository.updateUser(current.id, dto);
      _user = updated;
      await tokenStorage.saveUser(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al actualizar los datos personales.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Cambia la contraseña del usuario autenticado sin alterar otros datos ni exponer credenciales.
  Future<bool> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final current = _user;
    if (current == null) {
      _errorMessage = 'No hay una sesión activa para cambiar contraseña.';
      notifyListeners();
      return false;
    }

    if (newPassword.isEmpty) {
      _errorMessage = 'Ingresa la nueva contraseña.';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Las contraseñas no coinciden.';
      notifyListeners();
      return false;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d]).{6,100}$',
    );
    if (!passwordRegex.hasMatch(newPassword)) {
      _errorMessage =
          'La contraseña debe tener al menos 6 caracteres, incluir mayúscula, minúscula, número y un caracter especial.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = UpdateUserDto(
        userName: current.userName,
        userLastName: current.userLastName ?? '',
        mail: current.mail,
        userPhone: current.userPhone ?? '',
        password: newPassword,
        isActive: current.isActive,
      );

      final updated = await userRepository.updateUser(current.id, dto);
      _user = updated;
      await tokenStorage.saveUser(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cambiar la contraseña.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Cierra la sesión local del usuario limpiando tokens, caché y estado.
  Future<void> logout() async {
    try {
      await authRepository.logout();
    } finally {
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      await tokenStorage.clear();
      notifyListeners();
    }
  }
}
