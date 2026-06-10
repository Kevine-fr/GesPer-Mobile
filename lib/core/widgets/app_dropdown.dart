import 'package:flutter/material.dart';

import '../values/app_colors.dart';

/// Champ « select » stylé : menu déroulant arrondi, thémé, avec chevron soigné.
/// Wrapper autour de [DropdownButtonFormField] pour un rendu premium cohérent.
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final IconData prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 20),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      // Chrome du menu : coins arrondis, fond thémé, ombre douce.
      borderRadius: BorderRadius.circular(18),
      dropdownColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
      elevation: 6,
      menuMaxHeight: 360,
      icon: Container(
        margin: const EdgeInsets.only(right: 2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary),
      ),
      iconSize: 18,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkOnBg : AppColors.lightOnBg,
      ),
    );
  }
}

/// Item de menu stylé avec une pastille colorée + libellé (look « liste »).
DropdownMenuItem<T> appDropdownItem<T>({
  required T value,
  required String label,
  required Color dotColor,
  IconData? icon,
}) {
  return DropdownMenuItem<T>(
    value: value,
    child: Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: dotColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon ?? Icons.circle, size: 14, color: dotColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );
}
