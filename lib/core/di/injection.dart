import 'package:get_it/get_it.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/repositories/catalog_repository.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/auth_controler.dart';
import 'package:farma_di_mobile/presentation/providers/catalog_provider.dart';
import 'package:farma_di_mobile/services/catalog_service.dart';
import 'package:farma_di_mobile/services/token_storage.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenProvider: getIt<TokenStorage>().read),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), getIt<TokenStorage>()),
  );
  getIt.registerFactory<AuthController>(() => AuthController(getIt<AuthRepository>()));

  // Catálogos
  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepository(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CatalogService>(
    () => CatalogService(getIt<CatalogRepository>()),
  );
  getIt.registerFactory<CatalogProvider>(
    () => CatalogProvider(getIt<CatalogService>()),
  );
}
