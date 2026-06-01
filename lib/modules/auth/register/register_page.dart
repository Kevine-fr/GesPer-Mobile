import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/theme_toggle.dart';
import 'register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createAccount),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: ThemeToggle())],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Créez votre espace',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                Text(
                  'En quelques secondes, prenez le contrôle de vos finances.',
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 14),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 28),
                TextFormField(
                  controller: controller.nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                    prefixIcon: Icon(Icons.person_rounded, size: 20),
                  ),
                  validator: (v) => Validators.required(v, 'Nom requis'),
                ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.05, end: 0),
                const SizedBox(height: 14),
                TextFormField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_rounded, size: 20),
                  ),
                  validator: Validators.email,
                ).animate(delay: 280.ms).fadeIn().slideX(begin: -0.05, end: 0),
                const SizedBox(height: 14),
                Obx(() => TextFormField(
                      controller: controller.passwordCtrl,
                      obscureText: controller.obscurePassword.value,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                          ),
                          onPressed: controller.togglePassword,
                        ),
                      ),
                      validator: Validators.password,
                    )).animate(delay: 360.ms).fadeIn().slideX(begin: -0.05, end: 0),
                const SizedBox(height: 14),
                Obx(() => TextFormField(
                      controller: controller.confirmCtrl,
                      obscureText: controller.obscureConfirm.value,
                      decoration: InputDecoration(
                        labelText: AppStrings.confirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureConfirm.value
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                          ),
                          onPressed: controller.toggleConfirm,
                        ),
                      ),
                      validator: Validators.matches(() => controller.passwordCtrl.text),
                    )).animate(delay: 440.ms).fadeIn().slideX(begin: -0.05, end: 0),
                const SizedBox(height: 24),
                Obx(() => AppPrimaryButton(
                      label: 'Envoyer le code',
                      icon: Icons.email_outlined,
                      onPressed: controller.submit,
                      isLoading: controller.isLoading.value,
                    )).animate(delay: 520.ms).fadeIn(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyHaveAccount,
                        style: TextStyle(color: AppColors.lightMuted)),
                    TextButton(
                      onPressed: Get.back,
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ).animate(delay: 600.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
