import 'package:get/get.dart';

import 'categorie_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CategorieController>()) {
      Get.put<CategorieController>(CategorieController());
    }
  }
}
