import 'package:gesper_app/data/services/dio_client.dart';
import 'package:get/get.dart';
import '../../core/utils/app_toast.dart';
import '../../data/models/categorie_model.dart';
import '../../data/providers/categorie_provider.dart';

/// Contrôleur global des catégories (admin + lecture par tous).
class CategorieController extends GetxController {
  static CategorieController get to => Get.find();

  final CategorieProvider _provider = Get.find();

  final RxList<CategorieModel> categories = <CategorieModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  List<CategorieModel> get spentCategories =>
      categories.where((c) => c.isSpentCategory).toList(growable: false);
  List<CategorieModel> get gainCategories =>
      categories.where((c) => c.isGainCategory).toList(growable: false);

  CategorieModel? byId(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final page = await _provider.list(page: 0, size: 100);
      categories.assignAll(page.content);
    } catch (e) {
      AppToast.error(toAppException(e).message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save(CategorieModel c, {int? id}) async {
    isSaving.value = true;
    try {
      if (id == null) {
        final created = await _provider.create(c);
        categories.add(created);
      } else {
        final updated = await _provider.update(id, c);
        final idx = categories.indexWhere((e) => e.id == id);
        if (idx != -1) categories[idx] = updated;
      }
      return true;
    } catch (e) {
      AppToast.error(toAppException(e).message);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> remove(int id) async {
    try {
      await _provider.delete(id);
      categories.removeWhere((c) => c.id == id);
      AppToast.success('Catégorie supprimée.');
    } catch (e) {
      AppToast.error(toAppException(e).message);
    }
  }
}
