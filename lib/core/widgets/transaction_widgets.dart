import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/finance_insights.dart';
import '../utils/formatters.dart';
import '../values/app_colors.dart';

/// Bandeau total animé (réutilisé par Gains et Spents).
class TotalBanner extends StatelessWidget {
  final num total;
  final int count;
  final Color color;
  final List<Color> gradient;
  final String label;
  final IconData icon;

  /// Petit texte additionnel (ex. « 42,0 % de vos revenus »).
  final String? caption;

  const TotalBanner({
    super.key,
    required this.total,
    required this.count,
    required this.color,
    required this.gradient,
    required this.label,
    required this.icon,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: total.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    Formatters.money(v),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 4),
                  Text(caption!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$count élément${count > 1 ? "s" : ""}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final num amount;
  final bool isGain;
  final VoidCallback? onTap;

  /// Part de la transaction sur le total (revenus ou dépenses). Affichée en pastille.
  final double? percent;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isGain,
    this.onTap,
    this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final color = isGain ? AppColors.gain : AppColors.spent;
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isGain ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.lightMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.signedMoney(amount, gain: isGain),
                    style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  if (percent != null && percent! > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      FinanceInsights.formatPercent(percent!),
                      style: TextStyle(
                        color: color.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
