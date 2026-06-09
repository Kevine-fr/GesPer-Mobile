import 'package:intl/intl.dart';

import '../../app/config/app_config.dart';

/// Granularité temporelle utilisée pour filtrer les diagrammes du tableau de bord.
enum ChartPeriod {
  seconds,
  minutes,
  hours,
  days,
  months,
  years,
}

extension ChartPeriodX on ChartPeriod {
  /// Libellé court affiché dans le sélecteur (s, min, h, j, mois, année).
  String get label {
    switch (this) {
      case ChartPeriod.seconds:
        return 's';
      case ChartPeriod.minutes:
        return 'min';
      case ChartPeriod.hours:
        return 'h';
      case ChartPeriod.days:
        return 'j';
      case ChartPeriod.months:
        return 'mois';
      case ChartPeriod.years:
        return 'année';
    }
  }

  /// Nombre de segments affichés sur l'axe horizontal.
  int get bucketCount {
    switch (this) {
      case ChartPeriod.seconds:
        return 12;
      case ChartPeriod.minutes:
        return 12;
      case ChartPeriod.hours:
        return 12;
      case ChartPeriod.days:
        return 7;
      case ChartPeriod.months:
        return 6;
      case ChartPeriod.years:
        return 5;
    }
  }

  /// Tronque une date au début de son segment.
  DateTime truncate(DateTime d) {
    switch (this) {
      case ChartPeriod.seconds:
        return DateTime(d.year, d.month, d.day, d.hour, d.minute, d.second);
      case ChartPeriod.minutes:
        return DateTime(d.year, d.month, d.day, d.hour, d.minute);
      case ChartPeriod.hours:
        return DateTime(d.year, d.month, d.day, d.hour);
      case ChartPeriod.days:
        return DateTime(d.year, d.month, d.day);
      case ChartPeriod.months:
        return DateTime(d.year, d.month);
      case ChartPeriod.years:
        return DateTime(d.year);
    }
  }

  /// Décale une date de [n] segments (n peut être négatif).
  DateTime step(DateTime d, int n) {
    switch (this) {
      case ChartPeriod.seconds:
        return d.add(Duration(seconds: n));
      case ChartPeriod.minutes:
        return d.add(Duration(minutes: n));
      case ChartPeriod.hours:
        return d.add(Duration(hours: n));
      case ChartPeriod.days:
        return d.add(Duration(days: n));
      case ChartPeriod.months:
        return DateTime(d.year, d.month + n, d.day, d.hour, d.minute, d.second);
      case ChartPeriod.years:
        return DateTime(d.year + n, d.month, d.day, d.hour, d.minute, d.second);
    }
  }

  /// Libellé d'un segment pour l'axe horizontal.
  String formatLabel(DateTime d) {
    switch (this) {
      case ChartPeriod.seconds:
        return DateFormat('mm:ss', AppConfig.defaultLocale).format(d);
      case ChartPeriod.minutes:
        return DateFormat('HH:mm', AppConfig.defaultLocale).format(d);
      case ChartPeriod.hours:
        return DateFormat("HH'h'", AppConfig.defaultLocale).format(d);
      case ChartPeriod.days:
        return DateFormat('dd/MM', AppConfig.defaultLocale).format(d);
      case ChartPeriod.months:
        return DateFormat('MMM', AppConfig.defaultLocale).format(d);
      case ChartPeriod.years:
        return DateFormat('yyyy', AppConfig.defaultLocale).format(d);
    }
  }

  /// Clé d'agrégation unique d'un segment.
  String keyOf(DateTime d) => truncate(d).toIso8601String();

  /// Liste ordonnée des débuts de segments, se terminant au segment courant.
  List<DateTime> buckets(DateTime now) {
    final end = truncate(now);
    return [for (var i = bucketCount - 1; i >= 0; i--) step(end, -i)];
  }
}
