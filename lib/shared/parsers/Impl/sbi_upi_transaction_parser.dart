import 'package:penny_wise/shared/parsers/transaction_parser.dart';

class SbiUpiTransactionParser extends TransactionParser {
  final SOURCE = "SBI UPI";
  final amountRegex = RegExp(r'trf to\s+([A-Za-z0-9 &]+)', caseSensitive: false);

  // Private constructor
  SbiUpiTransactionParser._();

  // Static final instance, lazily initialized or initialized directly.
  // Using a static final field is the most common way to create singletons in Dart.
  static final SbiUpiTransactionParser instance = SbiUpiTransactionParser._();

  @override
  String getSource() {
    return SOURCE;
  }

  @override
  RegExp getAmountRegex() {
    return amountRegex;
  }
}