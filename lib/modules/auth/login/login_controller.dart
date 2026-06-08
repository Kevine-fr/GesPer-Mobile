import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/dio_client.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  void togglePassword() => obscurePassword.toggle();

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await AuthService.to.login(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      AppToast.success('Bienvenue !');
      Get.offAllNamed(Routes.home);
    } catch (e) {
      AppToast.error(toAppException(e).message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    final url = AppConfig.googleOAuthUrl(Uri.encodeComponent(AppConfig.oauthRedirectUri));
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.error("Impossible d'ouvrir le navigateur");
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
