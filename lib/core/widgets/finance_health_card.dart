import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/finance_insights.dart';
import '../values/app_colors.dart';
import 'percent_badge.dart';

/// Carte « Santé financière » : jauge animée + score + conseil.
///
/// Valeur ajoutée de l'app : transforme revenus/dépenses en un indicateur
/// synthétique (taux d'épargne) facile à lire d'un coup d'œil.
class FinanceHealthCard extends StatelessWidget {
  final num totalGains;
  final num totalSpents;

  const FinanceHealthCard({
    super.key,
    required this.totalGains,
    required this.totalSpents,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = totalGains > 0 || totalSpents > 0;
    final score = FinanceInsights.healthScore(totalGains, totalSpents);
    final color = FinanceInsights.healthColor(score);
    final label = FinanceInsights.healthLabel(score);
    final savings = FinanceInsights.savingsRate(totalGains, totalSpents);
    final spending = FinanceInsights.spendingRate(totalGains, totalSpents);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              const Text('Santé financière',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (hasData)
                PercentBadge(
                  value: savings,
                  color: color,
                  icon: Icons.savings_rounded,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Gauge(score: score, color: color),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      FinanceInsights.healthAdvice(score, hasData: hasData),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.lightMuted, height: 1.35),
                    ),
                    if (hasData) ...[
                      const SizedBox(height: 12),
                      _MiniStat(
                        label: 'Épargnés',
                        percent: savings.clamp(0, 100).toDouble(),
                        color: AppColors.gain,
                      ),
                      const SizedBox(height: 8),
                      _MiniStat(
                        label: 'Dépensés',
                        percent: spending.clamp(0, 100).toDouble(),
                        color: AppColors.spent,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _MiniStat({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, style: TextStyle(fontSize: 11.5, color: AppColors.lightMuted)),
        ),
        Expanded(child: PercentBar(percent: percent, color: color, height: 7)),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            FinanceInsights.formatPercent(percent, decimals: 0),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

class _Gauge extends StatelessWidget {
  final int score;
  final Color color;
  const _Gauge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _GaugePainter(
            progress: v,
            color: color,
            trackColor: Theme.of(context).dividerColor,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(v * 100).round()}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
                Text('/ 100', style: TextStyle(fontSize: 10, color: AppColors.lightMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _GaugePainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 7;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, track);

    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [color.withValues(alpha: 0.5), color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, arc);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color || old.trackColor != trackColor;
}
