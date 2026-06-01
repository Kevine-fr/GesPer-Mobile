import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/theme_toggle.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: AppColors.primary),
                    ),
                    const ThemeToggle(),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 32),
                Text(
                  'Bon retour 👋',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                ).animate(delay: 100.ms).fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                Text(
                  'Connectez-vous pour reprendre la main sur vos finances.',
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 14),
                ).animate(delay: 180.ms).fadeIn(duration: 350.ms),
                const SizedBox(height: 32),
                TextFormField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_rounded, size: 20),
                  ),
                  validator: Validators.email,
                ).animate(delay: 260.ms).fadeIn(duration: 350.ms).slideX(begin: -0.05, end: 0),
                const SizedBox(height: 14),
                Obx(() => TextFormField(
                      controller: controller.passwordCtrl,
                      obscureText: controller.obscurePassword.value,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.login(),
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
                    )).animate(delay: 340.ms).fadeIn(duration: 350.ms).slideX(begin: -0.05, end: 0),
                const SizedBox(height: 24),
                Obx(() => AppPrimaryButton(
                      label: AppStrings.login,
                      icon: Icons.login_rounded,
                      onPressed: controller.login,
                      isLoading: controller.isLoading.value,
                    )).animate(delay: 420.ms).fadeIn(duration: 350.ms),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ou', style: TextStyle(color: AppColors.lightMuted, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                  ],
                ).animate(delay: 500.ms).fadeIn(duration: 350.ms),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: controller.loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text(AppStrings.loginWithGoogle),
                ).animate(delay: 560.ms).fadeIn(duration: 350.ms),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.dontHaveAccount, style: TextStyle(color: AppColors.lightMuted)),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.register),
                      child: const Text(AppStrings.createAccount),
                    ),
                  ],
                ).animate(delay: 620.ms).fadeIn(duration: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
