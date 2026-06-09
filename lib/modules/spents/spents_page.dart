import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/finance_insights.dart';
import '../../core/utils/formatters.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmers.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../core/widgets/transaction_widgets.dart';
import '../categories/categorie_controller.dart';
import '../gains/gain_controller.dart';
import 'spent_controller.dart';

class SpentsPage extends StatelessWidget {
  const SpentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = SpentController.to;
    final catCtrl = CategorieController.to;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(AppStrings.spents,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                ),
                const ThemeToggle(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              final rate = FinanceInsights.spendingRate(GainController.to.total, c.total);
              return TotalBanner(
                total: c.total,
                count: c.spents.length,
                color: AppColors.spent,
                gradient: AppColors.spentGradient,
                label: AppStrings.totalSpents,
                icon: Icons.trending_down_rounded,
                caption: GainController.to.total > 0
                    ? '${FinanceInsights.formatPercent(rate)} de vos revenus'
                    : null,
              );
            }),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.spents.isEmpty) return const ShimmerList();
              if (c.spents.isEmpty) {
                return EmptyState(
                  icon: Icons.shopping_cart_rounded,
                  title: AppStrings.noSpents,
                  subtitle: 'Ajoutez votre première dépense.',
                  action: FilledButton.icon(
                    onPressed: () => Get.toNamed(Routes.spentForm),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Ajouter une dépense'),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: c.spents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final s = c.spents[i];
                    final cat = catCtrl.byId(s.categorieId);
                    return Dismissible(
                      key: ValueKey('spent-${s.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.spent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      confirmDismiss: (_) => showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Supprimer ?'),
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
                      ),
                      onDismissed: (_) => c.remove(s.id),
                      child: TransactionTile(
                        title: s.libelle ?? 'Dépense',
                        subtitle: '${cat?.title ?? "—"} · ${Formatters.relative(s.createdAt)}',
                        amount: s.value,
                        isGain: false,
                        percent: FinanceInsights.percent(s.value, c.total),
                        onTap: () => Get.toNamed(Routes.spentDetail, arguments: s),
                      ).animate().fadeIn(duration: 280.ms, delay: (i * 50).ms).slideX(begin: 0.05, end: 0),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
