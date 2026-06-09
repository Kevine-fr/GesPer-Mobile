import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/finance_insights.dart';
import '../../core/utils/formatters.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/detail_widgets.dart';
import '../../data/models/gain_model.dart';
import '../categories/categorie_controller.dart';
import '../spents/spent_controller.dart';
import 'gain_controller.dart';

class GainDetailPage extends StatelessWidget {
  const GainDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GainController.to;
    final spentCtrl = SpentController.to;
    final catCtrl = CategorieController.to;
    final initial = Get.arguments as GainModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.gainDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: AppStrings.edit,
            onPressed: () => Get.toNamed(Routes.gainForm,
                arguments: c.gains.firstWhereOrNull((g) => g.id == initial.id) ?? initial),
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
          final g = c.gains.firstWhereOrNull((e) => e.id == initial.id);
          if (g == null) {
            // Élément supprimé → on quitte la page.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.currentRoute == Routes.gainDetail) Get.back();
            });
            return const SizedBox.shrink();
          }

          final cat = catCtrl.byId(g.categorieId);
          final totalGains = c.total;
          final totalSpents = spentCtrl.total;
          final balance = totalGains - totalSpents;

          // Dépenses rattachées à ce revenu.
          final linkedSpents = spentCtrl.spents.where((s) => s.gainId == g.id).toList();
          final linkedTotal = linkedSpents.fold<num>(0, (a, s) => a + s.value);

          final shareOfGains = FinanceInsights.percent(g.sum, totalGains);
          final shareOfBalance = balance > 0 ? FinanceInsights.percent(g.sum, balance) : 0.0;
          final consumed = FinanceInsights.percent(linkedTotal, g.sum);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              DetailHeroCard(
                amount: g.sum,
                isGain: true,
                title: g.libelle ?? 'Revenu',
                categorie: cat?.title ?? 'Sans catégorie',
                badge: g.isReccurent ? 'Récurrent' : null,
              ),
              const SizedBox(height: 16),
              DetailSectionCard(
                title: 'Poids de ce revenu',
                icon: Icons.percent_rounded,
                children: [
                  DetailPercentRow(
                    label: 'Part du total des revenus',
                    percent: shareOfGains,
                    color: AppColors.gain,
                    context_: '${Formatters.money(g.sum)} sur ${Formatters.money(totalGains)}',
                  ),
                  DetailPercentRow(
                    label: 'Part du solde actuel',
                    percent: shareOfBalance,
                    color: AppColors.primary,
                    context_: balance > 0
                        ? 'Solde : ${Formatters.money(balance)}'
                        : 'Solde négatif',
                  ),
                  DetailPercentRow(
                    label: 'Déjà consommé par les dépenses liées',
                    percent: consumed,
                    color: consumed >= 100 ? AppColors.spent : AppColors.warning,
                    context_: linkedSpents.isEmpty
                        ? 'Aucune dépense liée'
                        : '${linkedSpents.length} dépense(s) · ${Formatters.money(linkedTotal)}',
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
                    icon: Icons.repeat_rounded,
                    label: 'Récurrent',
                    value: g.isReccurent ? 'Oui' : 'Non',
                    valueColor: g.isReccurent ? AppColors.gain : null,
                  ),
                  DetailInfoRow(
                    icon: Icons.event_rounded,
                    label: 'Créé le',
                    value: g.createdAt != null ? Formatters.dateTime(g.createdAt) : '—',
                  ),
                  if (g.updatedAt != null)
                    DetailInfoRow(
                      icon: Icons.update_rounded,
                      label: 'Modifié le',
                      value: Formatters.dateTime(g.updatedAt),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GainController c, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce revenu ?'),
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
