import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    debugPrint('[SPLASH] start');
    await Future.delayed(const Duration(milliseconds: 1100));
    try {
      debugPrint('[SPLASH] calling AuthService.bootstrap()');
      final authenticated = await AuthService.to.bootstrap();
      debugPrint('[SPLASH] bootstrap returned: $authenticated');
      Get.offAllNamed(authenticated ? Routes.home : Routes.login);
    } catch (e, st) {
      debugPrint('[SPLASH] ERROR: $e');
      debugPrint('[SPLASH] STACK: $st');
      Get.offAllNamed(Routes.login);
    }
  }
}