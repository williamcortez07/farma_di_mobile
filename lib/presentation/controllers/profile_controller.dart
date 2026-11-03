import 'package:flutter/foundation.dart';
import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';
import 'package:farma_di_mobile/presentation/providers/user_provider.dart';

enum ProfileStatus { initial, loading, updating, success, error }

class ProfileController extends ChangeNotifier {
  ProfileController({
    required this.userRepository,
    required this.userProvider,
  });

  final UserRepository userRepository;
  final UserProvider userProvider;

  ProfileStatus status = ProfileStatus.initial;
  String? errorMessage;

  UserModel? get user => userProvider.user;
  bool get isLoading => status == ProfileStatus.loading;
  bool get isUpdating => status == ProfileStatus.updating;

  /// Carga el perfil del usuario utilizando el provider y el repositorio.
  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (user != null && !forceRefresh) return;

    status = ProfileStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await userProvider.loadProfile(forceRefresh: forceRefresh);
      if (userProvider.errorMessage != null && userProvider.user == null) {
        status = ProfileStatus.error;
        errorMessage = userProvider.errorMessage;
      } else {
        status = ProfileStatus.success;
      }
    } on AppException catch (e) {
      status = ProfileStatus.error;
      errorMessage = e.message;
    } catch (_) {
      status = ProfileStatus.error;
      errorMessage = 'No fue posible cargar el perfil del usuario.';
    }

    notifyListeners();
  }

  /// Actualiza los datos personales (nombre, apellido, correo y teléfono).
  Future<bool> updateProfile({
    required String userName,
    required String userLastName,
    required String mail,
    required String userPhone,
  }) async {
    final current = user;
    if (current == null) {
      errorMessage = 'No hay una sesión activa para actualizar.';
      notifyListeners();
      return false;
    }

    final trimmedName = userName.trim();
    final trimmedLastName = userLastName.trim();
    final trimmedMail = mail.trim();
    final trimmedPhone = userPhone.trim();

    if (trimmedName.isEmpty || trimmedLastName.isEmpty) {
      errorMessage = 'Nombres y apellidos son requeridos.';
      notifyListeners();
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedMail)) {
      errorMessage = 'Ingresa un correo electrónico válido.';
      notifyListeners();
      return false;
    }

    if (trimmedPhone.isEmpty) {
      errorMessage = 'Ingresa un número telefónico válido.';
      notifyListeners();
      return false;
    }

    status = ProfileStatus.updating;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await userProvider.updateProfile(
        userName: trimmedName,
        userLastName: trimmedLastName,
        mail: trimmedMail,
        userPhone: trimmedPhone,
      );

      if (success) {
        status = ProfileStatus.success;
        notifyListeners();
        return true;
      } else {
        status = ProfileStatus.error;
        errorMessage = userProvider.errorMessage ?? 'Error al actualizar los datos personales.';
        notifyListeners();
        return false;
      }
    } on AppException catch (e) {
      status = ProfileStatus.error;
      errorMessage = e.message;
    } catch (_) {
      status = ProfileStatus.error;
      errorMessage = 'Error inesperado al actualizar los datos.';
    }

    notifyListeners();
    return false;
  }

  /// Cambia la contraseña del usuario.
  Future<bool> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (user == null) {
      errorMessage = 'No hay una sesión activa para cambiar contraseña.';
      notifyListeners();
      return false;
    }

    if (newPassword.isEmpty) {
      errorMessage = 'Ingresa la nueva contraseña.';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      errorMessage = 'Las contraseñas no coinciden.';
      notifyListeners();
      return false;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z\d]).{6,100}$',
    );
    if (!passwordRegex.hasMatch(newPassword)) {
      errorMessage =
          'La contraseña debe tener al menos 6 caracteres, incluir mayúscula, minúscula, número y un caracter especial.';
      notifyListeners();
      return false;
    }

    status = ProfileStatus.updating;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await userProvider.changePassword(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (success) {
        status = ProfileStatus.success;
        notifyListeners();
        return true;
      } else {
        status = ProfileStatus.error;
        errorMessage = userProvider.errorMessage ?? 'Error al actualizar la contraseña.';
        notifyListeners();
        return false;
      }
    } on AppException catch (e) {
      status = ProfileStatus.error;
      errorMessage = e.message;
    } catch (_) {
      status = ProfileStatus.error;
      errorMessage = 'Error inesperado al cambiar contraseña.';
    }

    notifyListeners();
    return false;
  }

  /// Cierra la sesión del usuario.
  Future<void> logout() async {
    await userProvider.logout();
  }
}
