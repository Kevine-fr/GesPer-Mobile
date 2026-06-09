import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/formatters.dart';
import '../values/app_colors.dart';
import 'percent_badge.dart';

/// En-tête « héros » d'une page de détail : gros montant + libellé + chip catégorie.
class DetailHeroCard extends StatelessWidget {
  final num amount;
  final bool isGain;
  final String title;
  final String categorie;
  final String? badge;

  const DetailHeroCard({
    super.key,
    required this.amount,
    required this.isGain,
    required this.title,
    required this.categorie,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isGain ? AppColors.gainGradient : AppColors.spentGradient;
    final color = isGain ? AppColors.gain : AppColors.spent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isGain ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: amount.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              Formatters.signedMoney(v, gain: isGain),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.category_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(categorie, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
  }
}

/// Carte de section générique pour les pages de détail.
class DetailSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;

  const DetailSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.06, end: 0);
  }
}

/// Ligne « libellé : valeur » pour les informations.
class DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const DetailInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.lightMuted),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.lightMuted)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne d'un pourcentage avec barre de progression + valeur.
class DetailPercentRow extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final String? context_;

  const DetailPercentRow({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
    this.context_,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              PercentBadge(value: percent.clamp(0, 999).toDouble(), color: color),
            ],
          ),
          if (context_ != null) ...[
            const SizedBox(height: 2),
            Text(context_!, style: TextStyle(fontSize: 11.5, color: AppColors.lightMuted)),
          ],
          const SizedBox(height: 8),
          PercentBar(percent: percent, color: color, height: 8),
        ],
      ),
    );
  }
}
