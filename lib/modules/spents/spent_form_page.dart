import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/utils/app_toast.dart';
import '../../core/utils/finance_insights.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/percent_badge.dart';
import '../../data/models/categorie_model.dart';
import '../../data/models/gain_model.dart';
import '../../data/models/spent_model.dart';
import '../categories/categorie_controller.dart';
import '../gains/gain_controller.dart';
import 'spent_controller.dart';

class SpentFormPage extends StatefulWidget {
  const SpentFormPage({super.key});

  @override
  State<SpentFormPage> createState() => _SpentFormPageState();
}

class _SpentFormPageState extends State<SpentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _libelleCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  CategorieModel? _selectedCategorie;
  GainModel? _linkedGain;
  bool _isPaid = true;
  SpentModel? _editing;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is SpentModel) {
      _editing = arg;
      _libelleCtrl.text = arg.libelle ?? '';
      _valueCtrl.text = arg.value.toString();
      _isPaid = arg.isSpent;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectedCategorie = CategorieController.to.byId(arg.categorieId);
        if (arg.gainId != null) {
          final g = GainController.to.gains.firstWhereOrNull((x) => x.id == arg.gainId);
          _linkedGain = g;
        }
        if (mounted) setState(() {});
      });
    }
    // Recalcule le conseil en direct à chaque frappe sur le montant.
    _valueCtrl.addListener(() => setState(() {}));
    _libelleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  num get _amount => num.tryParse(_valueCtrl.text.replaceAll(',', '.')) ?? 0;

  /// Solde disponible avant cette dépense (on retire la dépense en cours d'édition).
  num get _balanceBefore {
    final base = SpentController.to.total - (_editing?.value ?? 0);
    return GainController.to.total - base;
  }

  @override
  Widget build(BuildContext context) {
    final catCtrl = CategorieController.to;
    final c = SpentController.to;
    final isEdit = _editing != null;
    final advice = _amount > 0
        ? FinanceInsights.adviseExpense(
            amount: _amount,
            balance: _balanceBefore,
            incomeAmount: _linkedGain?.sum,
          )
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier la dépense' : 'Nouvelle dépense')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _FormHero(
                title: _libelleCtrl.text.trim().isEmpty
                    ? (isEdit ? 'Dépense' : 'Nouvelle dépense')
                    : _libelleCtrl.text.trim(),
                amount: _amount,
                isGain: false,
                share: advice?.balanceShare,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _libelleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Libellé',
                  prefixIcon: Icon(Icons.label_rounded, size: 20),
                  hintText: 'Courses, Restaurant…',
                ),
                validator: (v) => Validators.required(v, 'Libellé requis'),
              ).animate().fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 14),
              TextFormField(
                controller: _valueCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: Icon(Icons.euro_rounded, size: 20),
                ),
                validator: Validators.positiveNumber,
              ).animate(delay: 80.ms).fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 14),
              Obx(() {
                final cats = catCtrl.spentCategories;
                return DropdownButtonFormField<CategorieModel>(
                  isExpanded: true,
                  value: _selectedCategorie,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category_rounded, size: 20),
                  ),
                  items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c.title))).toList(),
                  onChanged: (c) => setState(() => _selectedCategorie = c),
                  validator: (v) => v == null ? 'Catégorie requise' : null,
                );
              }).animate(delay: 160.ms).fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 14),
              Obx(() {
                final gains = GainController.to.gains;
                return DropdownButtonFormField<GainModel?>(
                  isExpanded: true,
                  value: _linkedGain,
                  decoration: const InputDecoration(
                    labelText: 'Lier à un revenu (optionnel)',
                    prefixIcon: Icon(Icons.link_rounded, size: 20),
                  ),
                  items: [
                    const DropdownMenuItem<GainModel?>(value: null, child: Text('— aucun —')),
                    for (final g in gains)
                      DropdownMenuItem<GainModel?>(
                        value: g,
                        child: Text(
                          '${g.libelle ?? "Revenu"} — ${Formatters.money(g.sum)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (g) => setState(() => _linkedGain = g),
                );
              }).animate(delay: 240.ms).fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 16),
              // Conseil dynamique sur l'impact de la dépense.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => SizeTransition(
                  sizeFactor: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: advice == null
                    ? const SizedBox(width: double.infinity)
                    : _AdviceCard(key: ValueKey(advice.title), advice: advice),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Payée', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Décocher pour une dépense planifiée',
                    style: TextStyle(fontSize: 12, color: AppColors.lightMuted),
                  ),
                  value: _isPaid,
                  activeColor: AppColors.spent,
                  onChanged: (v) => setState(() => _isPaid = v),
                ),
              ).animate(delay: 320.ms).fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 28),
              Obx(() => AppPrimaryButton(
                    label: isEdit ? AppStrings.save : AppStrings.add,
                    icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                    gradient: AppColors.spentGradient,
                    isLoading: c.isSaving.value,
                    onPressed: () => _submit(c, isEdit),
                  )).animate(delay: 400.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(SpentController c, bool isEdit) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategorie == null) return;

    final ok = await c.save(
      id: isEdit ? _editing!.id : null,
      gainId: _linkedGain?.id,
      categorieId: _selectedCategorie!.id,
      libelle: _libelleCtrl.text.trim(),
      value: num.parse(_valueCtrl.text.replaceAll(',', '.')),
      isSpent: _isPaid,
    );

    if (ok) {
      AppToast.success(isEdit ? 'Dépense modifiée.' : 'Dépense ajoutée.');
      Get.back();
    }
  }
}

/// Carte de conseil affichée pendant la saisie d'une dépense.
class _AdviceCard extends StatelessWidget {
  final ExpenseAdvice advice;
  const _AdviceCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final color = advice.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(advice.icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        advice.title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
                      ),
                    ),
                    PercentBadge(value: advice.balanceShare, color: color, icon: Icons.account_balance_wallet_rounded),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  advice.message,
                  style: const TextStyle(fontSize: 12.5, height: 1.35),
                ),
                const SizedBox(height: 10),
                PercentBar(percent: advice.balanceShare, color: color, height: 7),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Aperçu « héros » en haut du formulaire : montant en direct + part du solde.
class _FormHero extends StatelessWidget {
  final String title;
  final num amount;
  final bool isGain;
  final double? share;

  const _FormHero({
    required this.title,
    required this.amount,
    required this.isGain,
    this.share,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isGain ? AppColors.gainGradient : AppColors.spentGradient;
    final color = isGain ? AppColors.gain : AppColors.spent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isGain ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (share != null && share! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${FinanceInsights.formatPercent(share!)} du solde',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: amount.toDouble()),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              Formatters.money(v),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
  }
}
