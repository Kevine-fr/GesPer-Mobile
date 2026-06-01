import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/utils/app_toast.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/app_primary_button.dart';
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
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catCtrl = CategorieController.to;
    final c = SpentController.to;
    final isEdit = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier la dépense' : 'Nouvelle dépense')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
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
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).dividerColor),
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
