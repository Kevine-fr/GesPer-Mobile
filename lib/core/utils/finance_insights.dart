import 'package:flutter/material.dart';

import '../values/app_colors.dart';
import 'formatters.dart';

/// Niveau d'impact d'une dépense (utilisé pour la couleur + le conseil).
enum ImpactLevel { good, moderate, high, critical }

extension ImpactLevelX on ImpactLevel {
  Color get color {
    switch (this) {
      case ImpactLevel.good:
        return AppColors.gain;
      case ImpactLevel.moderate:
        return AppColors.warning;
      case ImpactLevel.high:
        return AppColors.spent;
      case ImpactLevel.critical:
        return AppColors.spent;
    }
  }

  IconData get icon {
    switch (this) {
      case ImpactLevel.good:
        return Icons.check_circle_rounded;
      case ImpactLevel.moderate:
        return Icons.info_rounded;
      case ImpactLevel.high:
        return Icons.warning_amber_rounded;
      case ImpactLevel.critical:
        return Icons.report_rounded;
    }
  }
}

/// Conseil affiché lorsqu'on saisit une dépense.
class ExpenseAdvice {
  final ImpactLevel level;
  final String title;
  final String message;

  /// % de la dépense sur le solde/épargne actuel.
  final double balanceShare;

  /// % de la dépense sur le revenu sélectionné (null si aucun).
  final double? incomeShare;

  const ExpenseAdvice({
    required this.level,
    required this.title,
    required this.message,
    required this.balanceShare,
    this.incomeShare,
  });

  Color get color => level.color;
  IconData get icon => level.icon;
}

/// Calculs financiers réutilisés partout dans l'app (pourcentages, conseils, score).
abstract class FinanceInsights {
  FinanceInsights._();

  /// Pourcentage de [part] sur [whole]. Retourne 0 si [whole] vaut 0.
  static double percent(num part, num whole) {
    if (whole == 0) return 0;
    return (part / whole) * 100;
  }

  /// Formate un pourcentage : `12,3 %`. [decimals] décimales (défaut 1).
  static String formatPercent(double value, {int decimals = 1}) {
    final v = value.toStringAsFixed(decimals).replaceAll('.', ',');
    return '$v %';
  }

  /// Taux d'épargne = (revenus − dépenses) / revenus.
  static double savingsRate(num gains, num spents) =>
      percent(gains - spents, gains);

  /// Taux de dépense = dépenses / revenus.
  static double spendingRate(num gains, num spents) => percent(spents, gains);

  /// Score de santé financière (0–100) à partir du taux d'épargne.
  static int healthScore(num gains, num spents) {
    if (gains <= 0) return 0;
    final rate = savingsRate(gains, spents);
    return rate.clamp(0, 100).round();
  }

  /// Libellé du score de santé.
  static String healthLabel(int score) {
    if (score >= 50) return 'Excellente';
    if (score >= 30) return 'Très bonne';
    if (score >= 15) return 'Correcte';
    if (score > 0) return 'Fragile';
    return 'À surveiller';
  }

  /// Couleur du score de santé.
  static Color healthColor(int score) {
    if (score >= 50) return AppColors.gain;
    if (score >= 30) return const Color(0xFF22C55E);
    if (score >= 15) return AppColors.warning;
    return AppColors.spent;
  }

  /// Message de conseil lié au score.
  static String healthAdvice(int score, {required bool hasData}) {
    if (!hasData) return 'Ajoutez vos revenus et dépenses pour évaluer votre santé financière.';
    if (score >= 50) return 'Vous épargnez une large part de vos revenus. Continuez ainsi 🚀';
    if (score >= 30) return 'Bon équilibre entre revenus et dépenses. Gardez le cap 👍';
    if (score >= 15) return 'Marge d\'épargne réduite. Surveillez vos dépenses 👀';
    if (score > 0) return 'Vous dépensez presque tout ce que vous gagnez ⚠️';
    return 'Vos dépenses dépassent vos revenus. Il faut réagir 🔥';
  }

  /// Construit le conseil affiché à la saisie d'une dépense.
  ///
  /// [amount] : montant saisi.
  /// [balance] : solde/épargne actuel (revenus − dépenses).
  /// [incomeAmount] : revenu sélectionné (optionnel).
  static ExpenseAdvice adviseExpense({
    required num amount,
    required num balance,
    num? incomeAmount,
  }) {
    final balanceShare = balance > 0 ? percent(amount, balance) : double.infinity;
    final incomeShare =
        (incomeAmount != null && incomeAmount > 0) ? percent(amount, incomeAmount) : null;

    // Détermination du niveau d'impact.
    ImpactLevel level;
    if (balance <= 0 || balanceShare.isInfinite || balanceShare > 100) {
      level = ImpactLevel.critical;
    } else if (balanceShare >= 50) {
      level = ImpactLevel.high;
    } else if (balanceShare >= 20) {
      level = ImpactLevel.moderate;
    } else {
      level = ImpactLevel.good;
    }

    final balanceStr = balance <= 0
        ? 'votre solde est déjà à découvert'
        : '${formatPercent(balanceShare)} de votre solde (${Formatters.money(balance)})';

    String title;
    String message;
    switch (level) {
      case ImpactLevel.good:
        title = 'Dépense raisonnable';
        message = 'Elle représente $balanceStr.';
        break;
      case ImpactLevel.moderate:
        title = 'À garder en tête';
        message = 'Elle représente $balanceStr — pensez à l\'équilibrer.';
        break;
      case ImpactLevel.high:
        title = 'Dépense importante';
        message = 'Elle pèse $balanceStr. Êtes-vous sûr ?';
        break;
      case ImpactLevel.critical:
        title = 'Attention !';
        message = balance <= 0
            ? 'Vous dépensez alors que $balanceStr.'
            : 'Elle dépasse votre solde disponible (${Formatters.money(balance)}).';
        break;
    }

    if (incomeShare != null) {
      message += ' Soit ${formatPercent(incomeShare)} du revenu sélectionné.';
    }

    return ExpenseAdvice(
      level: level,
      title: title,
      message: message,
      balanceShare: balanceShare.isFinite ? balanceShare : 100,
      incomeShare: incomeShare,
    );
  }
}
