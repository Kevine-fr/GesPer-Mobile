import 'package:flutter/material.dart';
import 'package:gesper_app/data/services/dio_client.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/providers/auth_provider.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool isLoading = false.obs;

  final AuthProvider _authProvider = Get.find();

  void togglePassword() => obscurePassword.toggle();
  void toggleConfirm() => obscureConfirm.toggle();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await _authProvider.sendClientCode(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      AppToast.info('Un code de vérification a été envoyé à votre email.');
      Get.toNamed(Routes.verifyCode, arguments: {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text,
      });
    } catch (e) {
      AppToast.error(toAppException(e).message);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
