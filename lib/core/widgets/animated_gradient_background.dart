import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Fond animé premium pour les écrans d'authentification : base profonde +
/// lueurs colorées (violet / cyan / émeraude) qui dérivent doucement.
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        return Stack(
          children: [
            // Base profonde, légèrement teintée.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A0A18), Color(0xFF0B1024), Color(0xFF0A1420)],
                  ),
                ),
              ),
            ),
            _glow(Alignment(-0.9 + 0.3 * t, -0.9), AppColors.glowViolet, 380, 0.55),
            _glow(Alignment(0.95, -0.5 + 0.4 * t), AppColors.glowCyan, 300, 0.40),
            _glow(Alignment(-0.6 + 0.2 * t, 0.95), AppColors.glowEmerald, 320, 0.32),
            // Vignette pour la lisibilité du contenu.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.2,
                    colors: [Colors.transparent, Color(0x55000000)],
                  ),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }

  Widget _glow(Alignment alignment, Color color, double size, double opacity) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.4),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
