import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmers.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../core/widgets/transaction_widgets.dart';
import '../categories/categorie_controller.dart';
import 'gain_controller.dart';

class GainsPage extends StatelessWidget {
  const GainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GainController.to;
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
                  child: Text(AppStrings.gains,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                ),
                const ThemeToggle(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => TotalBanner(
                  total: c.total,
                  count: c.gains.length,
                  color: AppColors.gain,
                  gradient: AppColors.gainGradient,
                  label: AppStrings.totalGains,
                  icon: Icons.trending_up_rounded,
                )),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.gains.isEmpty) return const ShimmerList();
              if (c.gains.isEmpty) {
                return EmptyState(
                  icon: Icons.savings_rounded,
                  title: AppStrings.noGains,
                  subtitle: 'Ajoutez votre premier revenu.',
                  action: FilledButton.icon(
                    onPressed: () => Get.toNamed(Routes.gainForm),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Ajouter un revenu'),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: c.gains.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final g = c.gains[i];
                    final cat = catCtrl.byId(g.categorieId);
                    return Dismissible(
                      key: ValueKey('gain-${g.id}'),
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
                      confirmDismiss: (_) => _confirmDelete(context),
                      onDismissed: (_) => c.remove(g.id),
                      child: TransactionTile(
                        title: g.libelle ?? 'Revenu',
                        subtitle: '${cat?.title ?? "—"} · ${Formatters.relative(g.createdAt)}',
                        amount: g.sum,
                        isGain: true,
                        onTap: () => Get.toNamed(Routes.gainForm, arguments: g),
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

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
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
    );
  }
}
