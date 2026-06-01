import 'package:intl/intl.dart';

import '../../app/config/app_config.dart';

abstract class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: AppConfig.defaultLocale,
    symbol: AppConfig.defaultCurrencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    locale: AppConfig.defaultLocale,
    symbol: AppConfig.defaultCurrencySymbol,
    decimalDigits: 1,
  );

  static final DateFormat _date = DateFormat('dd MMM yyyy', AppConfig.defaultLocale);
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy à HH:mm', AppConfig.defaultLocale);
  static final DateFormat _month = DateFormat('MMM', AppConfig.defaultLocale);

  static String money(num value) => _currency.format(value);
  static String moneyCompact(num value) => _compact.format(value);
  static String signedMoney(num value, {bool gain = true}) {
    final sign = gain ? '+ ' : '- ';
    return '$sign${_currency.format(value.abs())}';
  }

  static String date(DateTime? d) => d == null ? '' : _date.format(d);
  static String dateTime(DateTime? d) => d == null ? '' : _dateTime.format(d);
  static String monthShort(DateTime d) => _month.format(d);

  /// Texte du type "il y a 3 j", "il y a 2 h".
  static String relative(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return _date.format(d);
  }
}
