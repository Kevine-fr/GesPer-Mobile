import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Fond d'ambiance « néo-banque » : lueurs colorées floues qui dérivent
/// lentement derrière le contenu, donnant de la profondeur à toute l'app.
class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Lueurs plus marquées en sombre, très subtiles en clair.
    final intensity = isDark ? 0.55 : 0.22;

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            return Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    _Glow(
                      alignment: Alignment(-0.9 + 0.25 * t, -1.0),
                      color: AppColors.glowViolet,
                      size: 360,
                      opacity: intensity,
                    ),
                    _Glow(
                      alignment: Alignment(1.0, -0.7 + 0.3 * t),
                      color: AppColors.glowCyan,
                      size: 300,
                      opacity: intensity * 0.8,
                    ),
                    _Glow(
                      alignment: Alignment(-0.8, 0.9 - 0.2 * t),
                      color: AppColors.glowEmerald,
                      size: 320,
                      opacity: intensity * 0.55,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;
  final double opacity;

  const _Glow({
    required this.alignment,
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    // Dégradé radial = même rendu « halo » qu'un flou, sans le coût du BackdropFilter.
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
