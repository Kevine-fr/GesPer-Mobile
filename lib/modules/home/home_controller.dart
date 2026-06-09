import 'package:get/get.dart';

import '../../core/utils/chart_period.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final RxInt currentIndex = 0.obs;

  /// Granularité sélectionnée pour les diagrammes du tableau de bord.
  final Rx<ChartPeriod> chartPeriod = ChartPeriod.months.obs;

  void changeTab(int index) => currentIndex.value = index;

  void setChartPeriod(ChartPeriod period) => chartPeriod.value = period;
}
