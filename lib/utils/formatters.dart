import 'package:intl/intl.dart';

/// Formats a numeric value as a currency string with the specified currency symbol and options.
///
/// [amount] The amount to format
/// [symbol] Currency symbol (default: '$')
/// [decimalDigits] Number of decimal places (default: 2)
/// [locale] The locale to use for number formatting (default: 'en_US')
String formatCurrency({
  required double amount,
  String symbol = '\$',
  int decimalDigits = 2,
  String locale = 'en_US',
}) {
  final NumberFormat formatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: decimalDigits,
    locale: locale,
  );

  return formatter.format(amount);
}

/// Simpler version that uses default USD formatting.
String formatAsDollars(double amount) {
  return formatCurrency(amount: amount);
}
