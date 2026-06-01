import 'package:gesper_app/data/services/dio_client.dart';
import 'package:get/get.dart';

import '../../core/utils/app_toast.dart';
import '../../data/models/gain_model.dart';
import '../../data/providers/gain_provider.dart';

class GainController extends GetxController {
  static GainController get to => Get.find();
  final GainProvider _provider = Get.find();

  final RxList<GainModel> gains = <GainModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  num get total => gains.fold<num>(0, (sum, g) => sum + g.sum);

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  Future<void> refresh() async {
    isLoading.value = true;
    try {
      final page = await _provider.mine(page: 0, size: 100);
      gains.assignAll(page.content);
    } catch (e) {
      AppToast.error(toAppException(e).message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save({
    int? id,
    required int categorieId,
    required String libelle,
    required num sum,
    required bool isReccurent,
  }) async {
    isSaving.value = true;
    try {
      if (id == null) {
        final created = await _provider.create(
          categorieId: categorieId,
          libelle: libelle,
          sum: sum,
          isReccurent: isReccurent,
        );
        gains.insert(0, created);
      } else {
        final updated = await _provider.updateMine(
          id: id,
          categorieId: categorieId,
          libelle: libelle,
          sum: sum,
          isReccurent: isReccurent,
        );
        final idx = gains.indexWhere((e) => e.id == id);
        if (idx != -1) gains[idx] = updated;
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
      gains.removeWhere((g) => g.id == id);
      AppToast.success('Revenu supprimé.');
    } catch (e) {
      AppToast.error(toAppException(e).message);
    }
  }
}
