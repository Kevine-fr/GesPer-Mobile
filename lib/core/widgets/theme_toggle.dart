import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../theme/theme_controller.dart';
import '../values/app_colors.dart';

/// Bouton circulaire animé qui bascule entre thème clair/sombre.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;

    return Obx(() {
      final isDark = controller.isDark;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.toggle,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkSurfaceAlt
                  : AppColors.primary.withValues(alpha: 0.08),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween<double>(begin: 0.6, end: 1).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey(isDark),
                size: 20,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 250.ms);
    });
  }
}
