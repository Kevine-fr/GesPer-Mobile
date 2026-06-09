import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/chart_period.dart';
import '../../core/utils/formatters.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmers.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../data/services/auth_service.dart';
import '../categories/categorie_controller.dart';
import '../gains/gain_controller.dart';
import '../home/home_controller.dart';
import '../spents/spent_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gainCtrl = GainController.to;
    final spentCtrl = SpentController.to;
    final catCtrl = CategorieController.to;
    final homeCtrl = HomeController.to;
    final auth = AuthService.to;

    return SafeArea(
      bottom: false,
      child: Obx(() {
        final loading = gainCtrl.isLoading.value || spentCtrl.isLoading.value;
        if (loading && gainCtrl.gains.isEmpty && spentCtrl.spents.isEmpty) {
          return const ShimmerDashboard();
        }

        final period = homeCtrl.chartPeriod.value;

        final totalGains = gainCtrl.total;
        final totalSpents = spentCtrl.total;
        final balance = totalGains - totalSpents;

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              gainCtrl.refresh(),
              spentCtrl.refresh(),
              catCtrl.loadAll(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              _Header(userName: auth.currentUser.value?.name ?? ''),
              const SizedBox(height: 18),
              StatCard(
                label: AppStrings.balance,
                value: balance,
                icon: Icons.account_balance_wallet_rounded,
                gradient: balance >= 0
                    ? AppColors.primaryGradient
                    : AppColors.spentGradient,
                subtitle: balance >= 0 ? 'Bonne maîtrise 👍' : 'Attention 🔥',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SmallStatCard(
                      label: AppStrings.totalGains,
                      value: totalGains,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.gain,
                      delayMs: 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SmallStatCard(
                      label: AppStrings.totalSpents,
                      value: totalSpents,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.spent,
                      delayMs: 200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _PeriodChips(selected: period),
              const SizedBox(height: 14),
              _SectionCard(
                title: AppStrings.monthlyOverview,
                child: MonthlyTrendChart(
                  gains: _buildSeries(
                      gainCtrl.gains.map((g) => _Point(g.createdAt, g.sum)), period),
                  spents: _buildSeries(
                      spentCtrl.spents.map((s) => _Point(s.createdAt, s.value)), period),
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.05, end: 0),
              const SizedBox(height: 16),
              _SectionCard(
                title: AppStrings.byCategorie,
                child: CategoriePieChart(
                  centerLabel: 'Dépenses',
                  centerValue: totalSpents,
                  slices: _buildSlices(
                    spentCtrl.spents.map((s) {
                      final cat = catCtrl.byId(s.categorieId);
                      return MapEntry(cat?.title ?? 'Autre', s.value);
                    }),
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.05, end: 0),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Solde par ${period.label}',
                child: BalanceBarChart(
                  points: _buildBalanceSeries(gainCtrl, spentCtrl, period),
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.05, end: 0),
              const SizedBox(height: 16),
              _RecentTransactions(),
            ],
          ),
        );
      }),
    );
  }

  /// Agrège des points dans les segments de la [period] choisie, terminant maintenant.
  static List<MonthlyPoint> _buildSeries(
      Iterable<_Point> rawPoints, ChartPeriod period) {
    final buckets = period.buckets(DateTime.now());
    final byKey = <String, num>{};
    for (final p in rawPoints) {
      if (p.date == null) continue;
      final key = period.keyOf(p.date!);
      byKey[key] = (byKey[key] ?? 0) + p.value;
    }
    return buckets
        .map((b) => MonthlyPoint(
            period.formatLabel(b), byKey[period.keyOf(b)] ?? 0))
        .toList();
  }

  static List<MonthlyPoint> _buildBalanceSeries(
      GainController g, SpentController s, ChartPeriod period) {
    final gains =
        _buildSeries(g.gains.map((g) => _Point(g.createdAt, g.sum)), period);
    final spents =
        _buildSeries(s.spents.map((s) => _Point(s.createdAt, s.value)), period);
    return List.generate(gains.length, (i) {
      final delta = gains[i].value - spents[i].value;
      return MonthlyPoint(gains[i].label, delta);
    });
  }

  static List<PieSlice> _buildSlices(Iterable<MapEntry<String, num>> raw) {
    final byTitle = <String, num>{};
    for (final e in raw) {
      byTitle[e.key] = (byTitle[e.key] ?? 0) + e.value;
    }
    final sorted = byTitle.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final palette = AppColors.chartPalette(Brightness.light);
    final top = sorted.take(7).toList();
    final rest = sorted.skip(7).fold<num>(0, (a, e) => a + e.value);
    final slices = <PieSlice>[];
    for (var i = 0; i < top.length; i++) {
      slices.add(PieSlice(
          label: top[i].key, value: top[i].value, color: palette[i % palette.length]));
    }
    if (rest > 0) {
      slices.add(PieSlice(label: 'Autres', value: rest, color: AppColors.lightMuted));
    }
    return slices;
  }
}

class _Point {
  final DateTime? date;
  final num value;
  _Point(this.date, this.value);
}

/// Sélecteur de granularité (s · min · h · j · mois · année) des diagrammes.
class _PeriodChips extends StatelessWidget {
  final ChartPeriod selected;
  const _PeriodChips({required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: ChartPeriod.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = ChartPeriod.values[i];
          final isSel = p == selected;
          return GestureDetector(
            onTap: () => HomeController.to.setChartPeriod(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: isSel
                    ? const LinearGradient(colors: AppColors.primaryGradient)
                    : null,
                color: isSel ? null : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSel
                      ? Colors.transparent
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                p.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.white : AppColors.lightMuted,
                ),
              ),
            ),
          );
        },
      ),
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    final greeting = _greetingFor(DateTime.now().hour);
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            userName.isNotEmpty ? userName.characters.first.toUpperCase() : 'G',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(greeting,
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                userName.isEmpty ? 'Bienvenue 👋' : userName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const ThemeToggle(),
      ],
    ).animate().fadeIn(duration: 320.ms);
  }

  String _greetingFor(int hour) {
    if (hour < 12) return 'Bonjour ☀️';
    if (hour < 18) return 'Bel après-midi 👋';
    return 'Bonsoir 🌙';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 4),
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gainCtrl = GainController.to;
    final spentCtrl = SpentController.to;
    final catCtrl = CategorieController.to;

    return Obx(() {
      final txs = <_TxRow>[
        for (final g in gainCtrl.gains)
          _TxRow(
            isGain: true,
            title: g.libelle ?? 'Revenu',
            category: catCtrl.byId(g.categorieId)?.title ?? '',
            amount: g.sum,
            date: g.createdAt,
          ),
        for (final s in spentCtrl.spents)
          _TxRow(
            isGain: false,
            title: s.libelle ?? 'Dépense',
            category: catCtrl.byId(s.categorieId)?.title ?? '',
            amount: s.value,
            date: s.createdAt,
          ),
      ];
      txs.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
      final top = txs.take(5).toList();

      return Container(
        padding: const EdgeInsets.all(16),
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
                const Expanded(
                  child: Text(AppStrings.recentTransactions,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                TextButton(
                  onPressed: () => HomeController.to.changeTab(1),
                  child: const Text(AppStrings.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (top.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_rounded,
                title: AppStrings.noData,
                subtitle: 'Ajoutez vos premiers revenus et dépenses.',
                action: FilledButton.icon(
                  onPressed: () => Get.toNamed(Routes.gainForm),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Commencer'),
                ),
              )
            else
              for (var i = 0; i < top.length; i++)
                _TxItem(row: top[i]).animate(delay: (i * 80).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
          ],
        ),
      ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.05, end: 0);
    });
  }
}

class _TxRow {
  final bool isGain;
  final String title;
  final String category;
  final num amount;
  final DateTime? date;
  _TxRow({
    required this.isGain,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });
}

class _TxItem extends StatelessWidget {
  final _TxRow row;
  const _TxItem({required this.row});

  @override
  Widget build(BuildContext context) {
    final color = row.isGain ? AppColors.gain : AppColors.spent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              row.isGain ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(row.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${row.category}${row.date != null ? " · ${Formatters.relative(row.date)}" : ""}',
                  style: TextStyle(fontSize: 12, color: AppColors.lightMuted),
                ),
              ],
            ),
          ),
          Text(
            Formatters.signedMoney(row.amount, gain: row.isGain),
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
