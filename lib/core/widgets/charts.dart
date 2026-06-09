import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/formatters.dart';
import '../values/app_colors.dart';

/// Graphique linéaire : évolution mensuelle des gains et dépenses.
class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyPoint> gains;
  final List<MonthlyPoint> spents;

  const MonthlyTrendChart({super.key, required this.gains, required this.spents});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (gains.isEmpty && spents.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Pas encore de données', style: TextStyle(color: AppColors.lightMuted))),
      );
    }

    final maxValue = [
      ...gains.map((p) => p.value),
      ...spents.map((p) => p.value),
    ].fold<double>(0, (a, b) => b > a ? b.toDouble() : a);

    final spotsG = [for (var i = 0; i < gains.length; i++) FlSpot(i.toDouble(), gains[i].value.toDouble())];
    final spotsS = [for (var i = 0; i < spents.length; i++) FlSpot(i.toDouble(), spents[i].value.toDouble())];

    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxValue == 0 ? 100 : maxValue * 1.2,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue == 0 ? 50 : maxValue / 4,
              getDrawingHorizontalLine: (v) => FlLine(
                color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.4),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: maxValue == 0 ? 50 : maxValue / 3,
                  getTitlesWidget: (value, _) => Text(
                    Formatters.moneyCompact(value),
                    style: TextStyle(fontSize: 10, color: AppColors.lightMuted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (value != i.toDouble()) return const SizedBox.shrink();
                    final count = gains.length > spents.length ? gains.length : spents.length;
                    final step = (count / 6).ceil().clamp(1, count);
                    // Affiche un libellé sur [step] pour éviter le chevauchement.
                    if (i % step != 0 && i != count - 1) return const SizedBox.shrink();
                    final label = i < gains.length
                        ? gains[i].label
                        : (i < spents.length ? spents[i].label : '');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(label,
                          style: TextStyle(fontSize: 10, color: AppColors.lightMuted, fontWeight: FontWeight.w500)),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => isDark ? AppColors.darkSurfaceAlt : AppColors.lightOnBg,
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          Formatters.money(s.y),
                          TextStyle(
                            color: s.bar.gradient?.colors.first ?? Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ))
                    .toList(),
              ),
            ),
            lineBarsData: [
              if (spotsG.isNotEmpty)
                LineChartBarData(
                  spots: spotsG,
                  isCurved: true,
                  curveSmoothness: 0.32,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  gradient: const LinearGradient(colors: AppColors.gainGradient),
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.gain.withValues(alpha: 0.25),
                        AppColors.gain.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              if (spotsS.isNotEmpty)
                LineChartBarData(
                  spots: spotsS,
                  isCurved: true,
                  curveSmoothness: 0.32,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  gradient: const LinearGradient(colors: AppColors.spentGradient),
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.spent.withValues(alpha: 0.22),
                        AppColors.spent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class MonthlyPoint {
  final String label;
  final num value;
  MonthlyPoint(this.label, this.value);
}

/// Pie chart d'une répartition par catégorie.
class CategoriePieChart extends StatefulWidget {
  final List<PieSlice> slices;
  final String? centerLabel;
  final num? centerValue;

  const CategoriePieChart({
    super.key,
    required this.slices,
    this.centerLabel,
    this.centerValue,
  });

  @override
  State<CategoriePieChart> createState() => _CategoriePieChartState();
}

class _CategoriePieChartState extends State<CategoriePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.slices.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Pas de données', style: TextStyle(color: AppColors.lightMuted))),
      );
    }
    final total = widget.slices.fold<num>(0, (a, b) => a + b.value);
    return SizedBox(
      height: 240,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 56,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, resp) {
                        setState(() {
                          _touchedIndex = (!event.isInterestedForInteractions ||
                                  resp == null ||
                                  resp.touchedSection == null)
                              ? -1
                              : resp.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: List.generate(widget.slices.length, (i) {
                      final slice = widget.slices[i];
                      final isTouched = i == _touchedIndex;
                      final radius = isTouched ? 58.0 : 48.0;
                      final percent = total == 0 ? 0 : (slice.value / total * 100);
                      return PieChartSectionData(
                        value: slice.value.toDouble(),
                        color: slice.color,
                        radius: radius,
                        title: '${percent.toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        showTitle: percent >= 6,
                      );
                    }),
                  ),
                  duration: const Duration(milliseconds: 700),
                ),
                if (widget.centerLabel != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.centerLabel!,
                          style: TextStyle(fontSize: 11, color: AppColors.lightMuted)),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.moneyCompact(widget.centerValue ?? total),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: widget.slices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = widget.slices[i];
                return Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.label,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class PieSlice {
  final String label;
  final num value;
  final Color color;
  PieSlice({required this.label, required this.value, required this.color});
}

/// Bar chart simple — solde par mois (gains − dépenses).
class BalanceBarChart extends StatelessWidget {
  final List<MonthlyPoint> points;

  const BalanceBarChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(child: Text('Pas de données', style: TextStyle(color: AppColors.lightMuted))),
      );
    }
    final values = points.map((p) => p.value.toDouble()).toList();
    final maxAbs = values.fold<double>(0, (a, b) => b.abs() > a ? b.abs() : a);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAbs == 0 ? 100 : maxAbs * 1.25,
          minY: maxAbs == 0 ? -100 : -maxAbs * 1.25,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox();
                  final step = (points.length / 6).ceil().clamp(1, points.length);
                  if (i % step != 0 && i != points.length - 1) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(points[i].label,
                        style: TextStyle(fontSize: 10, color: AppColors.lightMuted)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.lightOnBg,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                Formatters.money(rod.toY),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].value.toDouble(),
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(6)),
                    gradient: LinearGradient(
                      colors: points[i].value >= 0
                          ? AppColors.gainGradient
                          : AppColors.spentGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
