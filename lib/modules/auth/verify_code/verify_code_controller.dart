import 'package:flutter/material.dart';
import 'package:gesper_app/data/services/dio_client.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/auth_service.dart';

class VerifyCodeController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final codeCtrl = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;

  late final String name;
  late final String email;
  late final String password;

  final AuthProvider _authProvider = Get.find();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    name = args['name'] as String? ?? '';
    email = args['email'] as String? ?? '';
    password = args['password'] as String? ?? '';
  }

  Future<void> verify() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await _authProvider.registerClient(
        name: name,
        email: email,
        password: password,
        code: codeCtrl.text.trim(),
      );
      // Auto-login après inscription
      await AuthService.to.login(email: email, password: password);
      AppToast.success('Inscription validée !');
      Get.offAllNamed(Routes.home);
    } catch (e) {
      AppToast.error(toAppException(e).message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resend() async {
    isResending.value = true;
    try {
      await _authProvider.sendClientCode(email: email, password: password);
      AppToast.success('Nouveau code envoyé.');
    } catch (e) {
      AppToast.error(toAppException(e).message);
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    super.onClose();
  }
}
