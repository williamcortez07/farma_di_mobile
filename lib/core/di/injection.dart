import 'package:get_it/get_it.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/repositories/auth_repository/user_repository.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/auth_controler.dart';
import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';
import 'package:farma_di_mobile/presentation/controllers/profile_controller.dart';
import 'package:farma_di_mobile/presentation/providers/log_provider.dart';
import 'package:farma_di_mobile/presentation/providers/user_provider.dart';
import 'package:farma_di_mobile/services/log_service.dart';
import 'package:farma_di_mobile/services/token_storage.dart';
import 'package:farma_di_mobile/services/user_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenProvider: getIt<TokenStorage>().read),
  );

  // Repositorios de datos
  getIt.registerLazySingleton<LogRepository>(
    () => LogRepository(getIt<ApiClient>()),
  );

  // Servicios
  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<LogService>(
    () => LogService(getIt<LogRepository>()),
  );

  // Autenticación
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), getIt<TokenStorage>()),
  );

  // Usuario / Perfil
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<UserService>()),
  );

  // Providers de estado compartido
  getIt.registerLazySingleton<UserProvider>(
    () => UserProvider(
      userRepository: getIt<UserRepository>(),
      authRepository: getIt<AuthRepository>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );
  getIt.registerLazySingleton<LogProvider>(
    () => LogProvider(logService: getIt<LogService>()),
  );

  // Controladores
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
  getIt.registerFactory<LogController>(
    () => LogController(getIt<LogProvider>()),
  );
}
