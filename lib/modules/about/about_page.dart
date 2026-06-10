import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/ambient_background.dart';
import '../../core/widgets/glass_card.dart';

/// Page explicative de l'application : présentation, fonctionnalités clés et
/// fonctionnement, le tout animé et cohérent avec le design « néo-banque ».
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _features = <_Feature>[
    _Feature(
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.primary,
      title: 'Suivez tout en un coup d’œil',
      text: 'Revenus, dépenses et solde réunis sur un tableau de bord clair et vivant.',
    ),
    _Feature(
      icon: Icons.insights_rounded,
      color: AppColors.secondary,
      title: 'Des graphiques filtrables',
      text: 'Visualisez vos tendances par heure, jour, mois ou année. À vous de choisir.',
    ),
    _Feature(
      icon: Icons.favorite_rounded,
      color: AppColors.gain,
      title: 'Votre santé financière',
      text: 'Un score d’épargne synthétique vous dit, en un instant, où vous en êtes.',
    ),
    _Feature(
      icon: Icons.lightbulb_rounded,
      color: AppColors.warning,
      title: 'Des conseils intelligents',
      text: 'À chaque dépense, mesurez son impact réel sur votre solde et vos revenus.',
    ),
    _Feature(
      icon: Icons.percent_rounded,
      color: AppColors.info,
      title: 'Tout en pourcentages',
      text: 'Chaque montant est replacé dans son contexte pour des décisions éclairées.',
    ),
  ];

  static const _steps = <_Step>[
    _Step(number: '1', title: 'Ajoutez vos revenus', text: 'Salaire, freelance, primes…'),
    _Step(number: '2', title: 'Enregistrez vos dépenses', text: 'Reliez-les à un revenu si besoin.'),
    _Step(number: '3', title: 'Pilotez votre budget', text: 'Laissez GesPer analyser pour vous.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('À propos'),
      ),
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              const _Hero(),
              const SizedBox(height: 28),
              _SectionLabel('Ce que GesPer fait pour vous')
                  .animate().fadeIn(delay: 250.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 14),
              for (var i = 0; i < _features.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FeatureCard(feature: _features[i])
                      .animate()
                      .fadeIn(delay: (300 + i * 90).ms, duration: 420.ms)
                      .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
                ),
              const SizedBox(height: 16),
              _SectionLabel('Comment ça marche')
                  .animate().fadeIn(delay: 800.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 14),
              for (var i = 0; i < _steps.length; i++)
                _StepRow(step: _steps[i], isLast: i == _steps.length - 1)
                    .animate()
                    .fadeIn(delay: (850 + i * 120).ms)
                    .slideX(begin: 0.1, end: 0),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text("C'est parti"),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AppColors.primary,
                ),
              ).animate().fadeIn(delay: 1200.ms).scaleXY(begin: 0.92, end: 1, curve: Curves.easeOutBack),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  '${AppStrings.appName} · v1.0.1\nFait avec ❤️ pour vos finances',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.lightMuted, height: 1.5),
                ),
              ).animate().fadeIn(delay: 1350.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: glowShadow(AppColors.primary, opacity: 0.5),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.savings_rounded, color: Colors.white, size: 48),
        )
            .animate()
            .scaleXY(begin: 0.5, end: 1, curve: Curves.elasticOut, duration: 900.ms)
            .fadeIn(),
        const SizedBox(height: 18),
        const Text(
          AppStrings.appName,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 6),
        Text(
          AppStrings.appTagline,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.lightMuted, height: 1.4),
        ).animate().fadeIn(delay: 320.ms),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: softShadow(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [feature.color.withValues(alpha: 0.25), feature.color.withValues(alpha: 0.10)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(feature.icon, color: feature.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(feature.title,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(feature.text,
                    style: TextStyle(fontSize: 12.5, color: AppColors.lightMuted, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final bool isLast;
  const _StepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(step.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(step.text,
                      style: TextStyle(fontSize: 12.5, color: AppColors.lightMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  const _Feature({required this.icon, required this.color, required this.title, required this.text});
}

class _Step {
  final String number;
  final String title;
  final String text;
  const _Step({required this.number, required this.title, required this.text});
}
