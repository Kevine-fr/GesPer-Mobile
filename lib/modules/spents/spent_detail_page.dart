import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/finance_insights.dart';
import '../../core/utils/formatters.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/detail_widgets.dart';
import '../../data/models/spent_model.dart';
import '../categories/categorie_controller.dart';
import '../gains/gain_controller.dart';
import 'spent_controller.dart';

class SpentDetailPage extends StatelessWidget {
  const SpentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = SpentController.to;
    final gainCtrl = GainController.to;
    final catCtrl = CategorieController.to;
    final initial = Get.arguments as SpentModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.spentDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: AppStrings.edit,
            onPressed: () => Get.toNamed(Routes.spentForm,
                arguments: c.spents.firstWhereOrNull((s) => s.id == initial.id) ?? initial),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.spent),
            tooltip: AppStrings.delete,
            onPressed: () => _confirmDelete(context, c, initial.id),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final s = c.spents.firstWhereOrNull((e) => e.id == initial.id);
          if (s == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.currentRoute == Routes.spentDetail) Get.back();
            });
            return const SizedBox.shrink();
          }

          final cat = catCtrl.byId(s.categorieId);
          final totalGains = gainCtrl.total;
          final totalSpents = c.total;
          final balance = totalGains - totalSpents;
          final linkedGain =
              s.gainId == null ? null : gainCtrl.gains.firstWhereOrNull((g) => g.id == s.gainId);

          final shareOfSpents = FinanceInsights.percent(s.value, totalSpents);
          final shareOfBalance = balance > 0 ? FinanceInsights.percent(s.value, balance) : 0.0;
          final shareOfGains = FinanceInsights.percent(s.value, totalGains);
          final shareOfIncome =
              linkedGain != null ? FinanceInsights.percent(s.value, linkedGain.sum) : null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              DetailHeroCard(
                amount: s.value,
                isGain: false,
                title: s.libelle ?? 'Dépense',
                categorie: cat?.title ?? 'Sans catégorie',
                badge: s.isSpent ? 'Payée' : 'Planifiée',
              ),
              const SizedBox(height: 16),
              DetailSectionCard(
                title: 'Impact de cette dépense',
                icon: Icons.percent_rounded,
                children: [
                  DetailPercentRow(
                    label: 'Part du total des dépenses',
                    percent: shareOfSpents,
                    color: AppColors.spent,
                    context_: '${Formatters.money(s.value)} sur ${Formatters.money(totalSpents)}',
                  ),
                  DetailPercentRow(
                    label: 'Part de votre solde',
                    percent: shareOfBalance,
                    color: shareOfBalance >= 50 ? AppColors.spent : AppColors.warning,
                    context_: balance > 0
                        ? 'Solde : ${Formatters.money(balance)}'
                        : 'Solde négatif',
                  ),
                  DetailPercentRow(
                    label: 'Part de vos revenus totaux',
                    percent: shareOfGains,
                    color: AppColors.primary,
                    context_: 'Revenus : ${Formatters.money(totalGains)}',
                  ),
                  if (shareOfIncome != null)
                    DetailPercentRow(
                      label: 'Part du revenu lié',
                      percent: shareOfIncome,
                      color: shareOfIncome >= 100 ? AppColors.spent : AppColors.info,
                      context_:
                          '${linkedGain!.libelle ?? "Revenu"} · ${Formatters.money(linkedGain.sum)}',
                    ),
                ],
              ),
              const SizedBox(height: 14),
              DetailSectionCard(
                title: AppStrings.information,
                icon: Icons.info_outline_rounded,
                children: [
                  DetailInfoRow(
                    icon: Icons.category_rounded,
                    label: 'Catégorie',
                    value: cat?.title ?? '—',
                  ),
                  DetailInfoRow(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Statut',
                    value: s.isSpent ? 'Payée' : 'Planifiée',
                    valueColor: s.isSpent ? AppColors.gain : AppColors.warning,
                  ),
                  DetailInfoRow(
                    icon: Icons.link_rounded,
                    label: 'Revenu lié',
                    value: linkedGain?.libelle ?? (s.gainId != null ? 'Revenu #${s.gainId}' : 'Aucun'),
                  ),
                  DetailInfoRow(
                    icon: Icons.event_rounded,
                    label: 'Créé le',
                    value: s.createdAt != null ? Formatters.dateTime(s.createdAt) : '—',
                  ),
                  if (s.updatedAt != null)
                    DetailInfoRow(
                      icon: Icons.update_rounded,
                      label: 'Modifié le',
                      value: Formatters.dateTime(s.updatedAt),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SpentController c, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette dépense ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.spent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await c.remove(id);
      Get.back();
    }
  }
}
