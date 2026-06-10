import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/utils/app_toast.dart';
import '../../core/utils/finance_insights.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../data/models/categorie_model.dart';
import '../../data/models/gain_model.dart';
import '../categories/categorie_controller.dart';
import '../home/home_controller.dart';
import 'gain_controller.dart';

class GainFormPage extends StatefulWidget {
  const GainFormPage({super.key});

  @override
  State<GainFormPage> createState() => _GainFormPageState();
}

class _GainFormPageState extends State<GainFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _libelleCtrl = TextEditingController();
  final _sumCtrl = TextEditingController();
  CategorieModel? _selectedCategorie;
  bool _isReccurent = false;
  GainModel? _editing;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is GainModel) {
      _editing = arg;
      _libelleCtrl.text = arg.libelle ?? '';
      _sumCtrl.text = arg.sum.toString();
      _isReccurent = arg.isReccurent;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectedCategorie = CategorieController.to.byId(arg.categorieId);
        if (mounted) setState(() {});
      });
    }
    _sumCtrl.addListener(() => setState(() {}));
    _libelleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _sumCtrl.dispose();
    super.dispose();
  }

  num get _amount => num.tryParse(_sumCtrl.text.replaceAll(',', '.')) ?? 0;

  /// Part de ce revenu sur le total des revenus (en retirant celui édité).
  double get _shareOfTotal {
    final base = GainController.to.total - (_editing?.sum ?? 0);
    final newTotal = base + _amount;
    return FinanceInsights.percent(_amount, newTotal);
  }

  @override
  Widget build(BuildContext context) {
    final catCtrl = CategorieController.to;
    final c = GainController.to;
    final isEdit = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier le revenu' : 'Nouveau revenu')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _FormHero(
                title: _libelleCtrl.text.trim().isEmpty
                    ? (isEdit ? 'Revenu' : 'Nouveau revenu')
                    : _libelleCtrl.text.trim(),
                amount: _amount,
                share: _amount > 0 ? _shareOfTotal : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _libelleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Libellé',
                  prefixIcon: Icon(Icons.label_rounded, size: 20),
                  hintText: 'Salaire, Freelance…',
                ),
                validator: (v) => Validators.required(v, 'Libellé requis'),
              ).animate().fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 14),
              TextFormField(
                controller: _sumCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: Icon(Icons.euro_rounded, size: 20),
                ),
                validator: Validators.positiveNumber,
              ).animate(delay: 80.ms).fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 14),
              Obx(() {
                final cats = catCtrl.gainCategories;
                return AppDropdown<CategorieModel>(
                  label: 'Catégorie',
                  prefixIcon: Icons.category_rounded,
                  value: _selectedCategorie,
                  items: [
                    for (final c in cats)
                      appDropdownItem<CategorieModel>(
                        value: c,
                        label: c.title,
                        dotColor: AppColors.gain,
                        icon: Icons.savings_rounded,
                      ),
                  ],
                  onChanged: (c) => setState(() => _selectedCategorie = c),
                  validator: (v) => v == null ? 'Catégorie requise' : null,
                );
              }).animate(delay: 160.ms).fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Récurrent', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Revenu mensuel récurrent (ex. salaire)',
                    style: TextStyle(fontSize: 12, color: AppColors.lightMuted),
                  ),
                  value: _isReccurent,
                  activeColor: AppColors.gain,
                  onChanged: (v) => setState(() => _isReccurent = v),
                ),
              ).animate(delay: 240.ms).fadeIn().slideX(begin: -0.05, end: 0),
              const SizedBox(height: 28),
              Obx(() => AppPrimaryButton(
                    label: isEdit ? AppStrings.save : AppStrings.add,
                    icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                    gradient: AppColors.gainGradient,
                    isLoading: c.isSaving.value,
                    onPressed: () => _submit(c, isEdit),
                  )).animate(delay: 320.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(GainController c, bool isEdit) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategorie == null) return;

    final ok = await c.save(
      id: isEdit ? _editing!.id : null,
      categorieId: _selectedCategorie!.id,
      libelle: _libelleCtrl.text.trim(),
      sum: num.parse(_sumCtrl.text.replaceAll(',', '.')),
      isReccurent: _isReccurent,
    );

    if (ok) {
      AppToast.success(isEdit ? 'Revenu modifié.' : 'Revenu ajouté.');
      // Retour sur la liste des revenus, actualisée, avec animation de la ligne.
      HomeController.to.changeTab(1);
      Get.until((route) => route.settings.name == Routes.home);
    }
  }
}

/// Aperçu « héros » en haut du formulaire revenu : montant en direct + part du total.
class _FormHero extends StatelessWidget {
  final String title;
  final num amount;
  final double? share;

  const _FormHero({required this.title, required this.amount, this.share});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gainGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.gain.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Colors.white70, size: 18),
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
                    '${FinanceInsights.formatPercent(share!)} du total',
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
