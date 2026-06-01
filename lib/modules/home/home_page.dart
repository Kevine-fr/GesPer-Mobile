import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../dashboard/dashboard_page.dart';
import '../gains/gains_page.dart';
import '../profile/profile_page.dart';
import '../spents/spents_page.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static const _pages = <Widget>[
    DashboardPage(),
    GainsPage(),
    SpentsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(controller.currentIndex.value),
              child: _pages[controller.currentIndex.value],
            ),
          )),
      bottomNavigationBar: _AnimatedBottomBar(),
      floatingActionButton: Obx(() {
        final i = controller.currentIndex.value;
        if (i == 0 || i == 3) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () {
            if (i == 1) {
              Get.toNamed(Routes.gainForm);
            } else if (i == 2) {
              Get.toNamed(Routes.spentForm);
            }
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(i == 1 ? 'Revenu' : 'Dépense'),
          backgroundColor: i == 1 ? AppColors.gain : AppColors.spent,
        ).animate().scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), curve: Curves.easeOutBack);
      }),
    );
  }
}

class _AnimatedBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = HomeController.to;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: AppStrings.dashboard,
                    selected: controller.currentIndex.value == 0,
                  ),
                  _NavItem(
                    index: 1,
                    icon: Icons.trending_up_rounded,
                    label: AppStrings.gains,
                    selected: controller.currentIndex.value == 1,
                    color: AppColors.gain,
                  ),
                  _NavItem(
                    index: 2,
                    icon: Icons.trending_down_rounded,
                    label: AppStrings.spents,
                    selected: controller.currentIndex.value == 2,
                    color: AppColors.spent,
                  ),
                  _NavItem(
                    index: 3,
                    icon: Icons.person_rounded,
                    label: AppStrings.profile,
                    selected: controller.currentIndex.value == 3,
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool selected;
  final Color? color;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.selected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: () => HomeController.to.changeTab(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? activeColor : AppColors.lightMuted, size: 22),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: activeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
