import 'package:get_it/get_it.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/repositories/auth_repository/user_repository.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/auth_controler.dart';
import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';
import 'package:farma_di_mobile/presentation/controllers/profile_controller.dart';
import 'package:farma_di_mobile/presentation/providers/user_provider.dart';
import 'package:farma_di_mobile/services/token_storage.dart';
import 'package:farma_di_mobile/services/user_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenProvider: getIt<TokenStorage>().read),
  );

  // Servicios
  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<ApiClient>()),
  );

  // Autenticación
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), getIt<TokenStorage>()),
  );

  // Usuario / Perfil
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<UserService>()),
  );

  // Provider de estado del usuario compartido
  getIt.registerLazySingleton<UserProvider>(
    () => UserProvider(
      userRepository: getIt<UserRepository>(),
      authRepository: getIt<AuthRepository>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  getIt.registerFactory<AuthController>(
    () => AuthController(
      getIt<AuthRepository>(),
      userProvider: getIt<UserProvider>(),
    ),
  );

  getIt.registerFactory<ProfileController>(
    () => ProfileController(
      userRepository: getIt<UserRepository>(),
      userProvider: getIt<UserProvider>(),
    ),
  );

  // Logs
  getIt.registerLazySingleton<LogRepository>(
    () => LogRepository(getIt<ApiClient>()),
  );
  getIt.registerFactory<LogController>(
    () => LogController(getIt<LogRepository>()),
  );
}
