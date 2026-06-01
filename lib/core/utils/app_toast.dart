import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/app_colors.dart';

abstract class AppToast {
  AppToast._();

  static void success(String message, {String? title}) {
    _show(
      title: title ?? 'Succès',
      message: message,
      icon: Icons.check_circle_rounded,
      color: AppColors.gain,
    );
  }

  static void error(String message, {String? title}) {
    _show(
      title: title ?? 'Oups',
      message: message,
      icon: Icons.error_rounded,
      color: AppColors.spent,
    );
  }

  static void info(String message, {String? title}) {
    _show(
      title: title ?? 'Info',
      message: message,
      icon: Icons.info_rounded,
      color: AppColors.info,
    );
  }

  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
      ),
      messageText: Text(message, style: const TextStyle(fontSize: 14)),
      icon: Icon(icon, color: color),
      shouldIconPulse: false,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
      colorText: Get.isDarkMode ? AppColors.darkOnBg : AppColors.lightOnBg,
      boxShadows: const [
        BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
      ],
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }
}
