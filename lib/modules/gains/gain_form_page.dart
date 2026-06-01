import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/utils/app_toast.dart';
import '../../core/utils/validators.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../data/models/categorie_model.dart';
import '../../data/models/gain_model.dart';
import '../categories/categorie_controller.dart';
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
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _sumCtrl.dispose();
    super.dispose();
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
                return DropdownButtonFormField<CategorieModel>(
                  isExpanded: true,
                  value: _selectedCategorie,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category_rounded, size: 20),
                  ),
                  items: cats
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.title)))
                      .toList(),
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
                  border: Border.all(color: Theme.of(context).dividerColor),
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
      Get.back();
    }
  }
}
