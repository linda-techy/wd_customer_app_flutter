import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wd_cust_mobile_app/utils/currency_formatter.dart';

void main() {
  setUpAll(() async {
    // Ensure en_IN locale data is initialised for NumberFormat grouping.
    await initializeDateFormatting('en_IN');
    Intl.defaultLocale = 'en_IN';
  });

  group('CurrencyFormatter.format', () {
    test('formats with Indian grouping and 2 decimals', () {
      expect(CurrencyFormatter.format(1250000), '₹12,50,000.00');
    });

    test('formats small amounts', () {
      expect(CurrencyFormatter.format(0), '₹0.00');
      expect(CurrencyFormatter.format(999.5), '₹999.50');
    });
  });

  group('CurrencyFormatter.formatCompact', () {
    test('formats with Indian grouping and no decimals', () {
      expect(CurrencyFormatter.formatCompact(1250000), '₹12,50,000');
    });

    test('rounds away decimals', () {
      expect(CurrencyFormatter.formatCompact(100000), '₹1,00,000');
    });
  });

  group('CurrencyFormatter.formatShort', () {
    test('uses Cr for >= 1 crore', () {
      expect(CurrencyFormatter.formatShort(12500000), '₹1.25 Cr');
      expect(CurrencyFormatter.formatShort(10000000), '₹1.00 Cr');
    });

    test('uses L for >= 1 lakh and < 1 crore', () {
      expect(CurrencyFormatter.formatShort(5000000), '₹50.00 L');
      expect(CurrencyFormatter.formatShort(100000), '₹1.00 L');
    });

    test('uses K for >= 1 thousand and < 1 lakh', () {
      expect(CurrencyFormatter.formatShort(25000), '₹25.0K');
      expect(CurrencyFormatter.formatShort(1000), '₹1.0K');
    });

    test('plain rupees below 1 thousand with no decimals', () {
      expect(CurrencyFormatter.formatShort(500), '₹500');
      expect(CurrencyFormatter.formatShort(0), '₹0');
    });
  });
}
