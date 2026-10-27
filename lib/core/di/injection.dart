import 'package:get_it/get_it.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/repositories/auth_repository/user_repository.dart';
import 'package:farma_di_mobile/data/repositories/log_repository.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/auth_controler.dart';
import 'package:farma_di_mobile/presentation/controllers/log_controller.dart';
import 'package:farma_di_mobile/services/token_storage.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenProvider: getIt<TokenStorage>().read),
  );

  // Autenticación
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), getIt<TokenStorage>()),
  );
  getIt.registerFactory<AuthController>(() => AuthController(getIt<AuthRepository>()));

  // Usuario / Perfil
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<ApiClient>()),
  );

  // Logs
  getIt.registerLazySingleton<LogRepository>(
    () => LogRepository(getIt<ApiClient>()),
  );
  getIt.registerFactory<LogController>(() => LogController(getIt<LogRepository>()));
}
