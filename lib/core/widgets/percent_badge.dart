import 'package:flutter/material.dart';

import '../utils/finance_insights.dart';
import '../values/app_colors.dart';

/// Petite pastille affichant un pourcentage, avec couleur d'accent et icône
/// optionnelle. Réutilisée un peu partout (listes, détails, dashboard).
class PercentBadge extends StatelessWidget {
  final double value;
  final Color? color;
  final IconData? icon;
  final String? prefix;
  final bool filled;

  const PercentBadge({
    super.key,
    required this.value,
    this.color,
    this.icon,
    this.prefix,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final label = '${prefix ?? ''}${FinanceInsights.formatPercent(value)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? c.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        border: filled ? null : Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de progression fine montrant une proportion (0–100).
class PercentBar extends StatelessWidget {
  final double percent;
  final Color color;
  final double height;

  const PercentBar({
    super.key,
    required this.percent,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = (percent / 100).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: [
          Container(
            height: height,
            color: color.withValues(alpha: 0.14),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
