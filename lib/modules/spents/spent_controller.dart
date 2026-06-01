import 'package:gesper_app/data/services/dio_client.dart';
import 'package:get/get.dart';

import '../../core/utils/app_toast.dart';
import '../../data/models/spent_model.dart';
import '../../data/providers/spent_provider.dart';

class SpentController extends GetxController {
  static SpentController get to => Get.find();
  final SpentProvider _provider = Get.find();

  final RxList<SpentModel> spents = <SpentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  num get total => spents.fold<num>(0, (sum, s) => sum + s.value);

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    try {
      final page = await _provider.mine(page: 0, size: 100);
      spents.assignAll(page.content);
    } catch (e) {
      AppToast.error(toAppException(e).message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save({
    int? id,
    int? gainId,
    required int categorieId,
    required String libelle,
    required num value,
    required bool isSpent,
  }) async {
    isSaving.value = true;
    try {
      if (id == null) {
        final created = await _provider.create(
          gainId: gainId,
          categorieId: categorieId,
          libelle: libelle,
          value: value,
          isSpent: isSpent,
        );
        spents.insert(0, created);
      } else {
        final updated = await _provider.updateMine(
          id: id,
          gainId: gainId,
          categorieId: categorieId,
          libelle: libelle,
          value: value,
          isSpent: isSpent,
        );
        final idx = spents.indexWhere((e) => e.id == id);
        if (idx != -1) spents[idx] = updated;
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
      await _provider.softDelete(id);
      spents.removeWhere((s) => s.id == id);
      AppToast.success('Dépense supprimée.');
    } catch (e) {
      AppToast.error(toAppException(e).message);
    }
  }
}
