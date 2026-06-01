import 'package:get/get.dart';

import '../categories/categorie_controller.dart';
import '../gains/gain_controller.dart';
import '../spents/spent_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: false);
    Get.put<CategorieController>(CategorieController(), permanent: false);
    Get.put<GainController>(GainController(), permanent: false);
    Get.put<SpentController>(SpentController(), permanent: false);
  }
}
