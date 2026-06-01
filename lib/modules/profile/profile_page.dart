import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/app_toast.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../data/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.to;
    final theme = ThemeController.to;

    return SafeArea(
      bottom: false,
      child: Obx(() {
        final user = auth.currentUser.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(AppStrings.profile,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                ),
                const ThemeToggle(),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.heroGradient),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (user?.name ?? 'G').characters.first.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                  )
                      .animate()
                      .scaleXY(begin: 0.6, end: 1, curve: Curves.elasticOut, duration: 700.ms)
                      .fadeIn(),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (user?.role != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        user!.isAdmin ? 'Administrateur' : 'Client',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            _SectionTitle('Apparence'),
            _SettingsCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Thème'),
                  subtitle: Obx(() => Text(switch (theme.mode.value) {
                        ThemeMode.light => 'Clair',
                        ThemeMode.dark => 'Sombre',
                        _ => 'Système',
                      })),
                  trailing: PopupMenuButton<ThemeMode>(
                    icon: const Icon(Icons.tune_rounded),
                    onSelected: theme.setMode,
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: ThemeMode.system, child: Text('Système')),
                      PopupMenuItem(value: ThemeMode.light, child: Text('Clair')),
                      PopupMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('Compte'),
            _SettingsCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_rounded),
                  title: const Text(AppStrings.categories),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Get.toNamed(Routes.categories),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.spent),
                  title: const Text(AppStrings.logout, style: TextStyle(color: AppColors.spent)),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Se déconnecter ?'),
                        content: const Text('Vous devrez vous reconnecter ensuite.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text(AppStrings.cancel)),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.spent),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(AppStrings.logout),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await auth.logout();
                      Get.offAllNamed(Routes.login);
                      AppToast.info('À bientôt !');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '${AppStrings.appName} · v1.0.0',
                style: TextStyle(fontSize: 12, color: AppColors.lightMuted),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.lightMuted,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}
