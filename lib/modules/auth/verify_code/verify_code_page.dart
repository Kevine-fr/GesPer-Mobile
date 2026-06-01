import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/widgets/app_primary_button.dart';
import 'verify_code_controller.dart';

class VerifyCodePage extends GetView<VerifyCodeController> {
  const VerifyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mark_email_read_rounded,
                        size: 44, color: AppColors.primary),
                  ),
                )
                    .animate()
                    .scaleXY(begin: 0.5, end: 1, duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(),
                const SizedBox(height: 24),
                Text(
                  'Vérifiez votre email',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'Saisissez le code à 6 chiffres envoyé à\n${controller.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 14, height: 1.4),
                ).animate(delay: 280.ms).fadeIn(),
                const SizedBox(height: 40),
                TextFormField(
                  controller: controller.codeCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 14,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                  ),
                  validator: Validators.code6,
                ).animate(delay: 360.ms).fadeIn().scaleXY(begin: 0.95, end: 1),
                const SizedBox(height: 32),
                Obx(() => AppPrimaryButton(
                      label: 'Valider mon compte',
                      icon: Icons.check_rounded,
                      onPressed: controller.verify,
                      isLoading: controller.isLoading.value,
                    )).animate(delay: 440.ms).fadeIn(),
                const SizedBox(height: 16),
                Center(
                  child: Obx(() => TextButton.icon(
                        onPressed: controller.isResending.value ? null : controller.resend,
                        icon: controller.isResending.value
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Renvoyer le code'),
                      )),
                ).animate(delay: 520.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
