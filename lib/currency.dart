import 'package:intl/intl.dart';

class Currency {
  final String code;
  final String symbol;

  const Currency(this.code, this.symbol);

  static const List<Currency> availableCurrencies = [
    Currency('IDR', 'Rp'),
    Currency('USD', '\$'),
    Currency('GBP', '£'),
    Currency('JPY', '¥'),
    Currency('MYR', 'RM'),
    Currency('SGD', 'S\$'),
    Currency('CNY', '¥'),
  ];

  static Currency getByCode(String code) {
    return availableCurrencies.firstWhere((currency) => currency.code == code);
  }

  String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: code == 'JPY' ? 0 : 2,
      locale: _getLocale(),
    );
    return formatter.format(amount);
  }

  String _getLocale() {
    switch (code) {
      case 'IDR':
        return 'id_ID';
      case 'USD':
        return 'en_US';
      case 'GBP':
        return 'en_GB';
      case 'JPY':
        return 'ja_JP';
      case 'MYR':
        return 'ms_MY';
      case 'SGD':
        return 'en_SG';
      case 'CNY':
        return 'zh_CN';
      default:
        return 'en_US';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
