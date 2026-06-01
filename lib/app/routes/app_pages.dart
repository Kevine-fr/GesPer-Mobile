import 'package:get/get.dart';

import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_page.dart';
import '../../modules/auth/register/register_binding.dart';
import '../../modules/auth/register/register_page.dart';
import '../../modules/auth/verify_code/verify_code_binding.dart';
import '../../modules/auth/verify_code/verify_code_page.dart';
import '../../modules/categories/categories_binding.dart';
import '../../modules/categories/categories_page.dart';
import '../../modules/gains/gain_form_page.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_page.dart';
import '../../modules/spents/spent_form_page.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.verifyCode,
      page: () => const VerifyCodePage(),
      binding: VerifyCodeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.gainForm,
      page: () => const GainFormPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.spentForm,
      page: () => const SpentFormPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.categories,
      page: () => const CategoriesPage(),
      binding: CategoriesBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
