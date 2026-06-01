import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/utils/app_toast.dart';
import '../../core/utils/validators.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/shimmers.dart';
import '../../data/models/categorie_model.dart';
import '../../data/services/auth_service.dart';
import 'categorie_controller.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = CategorieController.to;
    final isAdmin = AuthService.to.currentUser.value?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.categories),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context, null),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Catégorie'),
            )
          : null,
      body: Obx(() {
        if (c.isLoading.value && c.categories.isEmpty) return const ShimmerList();
        if (c.categories.isEmpty) {
          return const EmptyState(
            icon: Icons.category_rounded,
            title: 'Aucune catégorie',
          );
        }
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Dépenses'),
                  Tab(text: 'Revenus'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _CategorieList(items: c.spentCategories, isAdmin: isAdmin),
                    _CategorieList(items: c.gainCategories, isAdmin: isAdmin),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openForm(BuildContext context, CategorieModel? existing) async {
    final ok = await Get.bottomSheet<bool>(
      _CategorieFormSheet(existing: existing),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
    if (ok == true) {
      AppToast.success(existing == null ? 'Catégorie créée.' : 'Catégorie modifiée.');
    }
  }
}

class _CategorieList extends StatelessWidget {
  final List<CategorieModel> items;
  final bool isAdmin;
  const _CategorieList({required this.items, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(icon: Icons.label_off_rounded, title: 'Aucune catégorie');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final c = items[i];
        final palette = AppColors.chartPalette(Brightness.light);
        final color = palette[i % palette.length];
        return Material(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isAdmin
                ? () => Get.bottomSheet(_CategorieFormSheet(existing: c),
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ))
                : null,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      c.isSpentCategory
                          ? Icons.shopping_cart_rounded
                          : Icons.savings_rounded,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(c.title,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (c.isOrganized)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Système',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(c.subtitle,
                            style: TextStyle(fontSize: 12, color: AppColors.lightMuted)),
                      ],
                    ),
                  ),
                  if (isAdmin && !c.isOrganized)
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: AppColors.spent.withValues(alpha: 0.8)),
                      onPressed: () => _confirmDelete(context, c),
                    ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 260.ms, delay: (i * 40).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategorieModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer "${c.title}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.spent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (ok == true) await CategorieController.to.remove(c.id);
  }
}

class _CategorieFormSheet extends StatefulWidget {
  final CategorieModel? existing;
  const _CategorieFormSheet({this.existing});

  @override
  State<_CategorieFormSheet> createState() => _CategorieFormSheetState();
}

class _CategorieFormSheetState extends State<_CategorieFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  bool _isSpent = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _subtitleCtrl.text = e.subtitle;
      _isSpent = e.isSpent;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CategorieController.to;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Modifier la catégorie' : 'Nouvelle catégorie',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (v) => Validators.required(v, 'Titre requis'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subtitleCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              validator: (v) => Validators.required(v, 'Description requise'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Dépense'),
                    selected: _isSpent,
                    onSelected: (v) => setState(() => _isSpent = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Revenu'),
                    selected: !_isSpent,
                    onSelected: (v) => setState(() => _isSpent = !v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => AppPrimaryButton(
                  label: isEdit ? AppStrings.save : AppStrings.add,
                  icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
                  isLoading: c.isSaving.value,
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final ok = await c.save(
                      CategorieModel(
                        id: widget.existing?.id ?? 0,
                        title: _titleCtrl.text.trim(),
                        subtitle: _subtitleCtrl.text.trim(),
                        isOrganized: false,
                        isSpent: _isSpent,
                      ),
                      id: widget.existing?.id,
                    );
                    if (ok) Get.back(result: true);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
