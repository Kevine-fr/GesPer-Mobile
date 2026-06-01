import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../values/app_colors.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFE5E7EB),
      highlightColor: isDark ? AppColors.darkSurface : const Color(0xFFF3F4F6),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const ShimmerList({super.key, this.count = 6, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => ShimmerBox(height: itemHeight, radius: 16),
    );
  }
}

class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          ShimmerBox(height: 160, radius: 22),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: ShimmerBox(height: 80, radius: 18)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 80, radius: 18)),
          ]),
          SizedBox(height: 16),
          ShimmerBox(height: 240, radius: 22),
          SizedBox(height: 16),
          ShimmerBox(height: 240, radius: 22),
        ],
      ),
    );
  }
}
