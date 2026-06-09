import 'dart:ui';

import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Carte « verre dépoli » : flou d'arrière-plan + fond translucide + liseré
/// lumineux. Donne le rendu premium des cartes Revolut / BitStack.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final VoidCallback? onTap;
  final Gradient? glow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.blur = 18,
    this.onTap,
    this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.05 : 0.7);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.9);

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // BoxDecoration interdit color + gradient simultanément.
            color: glow == null ? fill : null,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border, width: 1),
            gradient: glow,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: content,
    );
  }
}

/// Ombre douce colorée réutilisable pour les cartes en dégradé (lueur sous la carte).
List<BoxShadow> glowShadow(Color color, {double opacity = 0.35}) => [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 28,
        spreadRadius: -4,
        offset: const Offset(0, 14),
      ),
    ];

/// Petit point lumineux décoratif (utilisé en coin de carte pour la profondeur).
class DecorBlob extends StatelessWidget {
  final double size;
  final Color color;
  const DecorBlob({super.key, this.size = 120, this.color = AppColors.glowViolet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
