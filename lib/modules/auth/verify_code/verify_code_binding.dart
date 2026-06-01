import 'package:get/get.dart';

import 'verify_code_controller.dart';

class VerifyCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifyCodeController>(() => VerifyCodeController());
  }
}
