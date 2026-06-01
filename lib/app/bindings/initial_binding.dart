import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/theme/theme_controller.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/categorie_provider.dart';
import '../../data/providers/gain_provider.dart';
import '../../data/providers/spent_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/dio_client.dart';
import '../../data/services/token_storage.dart';

/// Binding global injecté au démarrage : services + providers.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage / theme
    Get.put<TokenStorage>(TokenStorage(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Dio
    Get.put<DioClient>(DioClient(Get.find<TokenStorage>()), permanent: true);
    final dio = Get.find<DioClient>().dio;
    Get.put<Dio>(dio, permanent: true);

    // Providers
    Get.lazyPut<AuthProvider>(() => AuthProvider(dio), fenix: true);
    Get.lazyPut<UserProvider>(() => UserProvider(dio), fenix: true);
    Get.lazyPut<CategorieProvider>(() => CategorieProvider(dio), fenix: true);
    Get.lazyPut<GainProvider>(() => GainProvider(dio), fenix: true);
    Get.lazyPut<SpentProvider>(() => SpentProvider(dio), fenix: true);

    // Auth service (singleton)
    Get.put<AuthService>(
      AuthService(Get.find<AuthProvider>(), Get.find<UserProvider>(), Get.find<TokenStorage>()),
      permanent: true,
    );
  }
}
