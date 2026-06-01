import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final RxInt currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;
}
