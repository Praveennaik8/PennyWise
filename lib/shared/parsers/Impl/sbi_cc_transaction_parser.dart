import 'package:flutter_getx_boilerplate/shared/parsers/transaction_parser.dart';

class SbiCcTransactionParser extends TransactionParser {
  final SOURCE = "SBI Credit Card";
  final amountRegex = RegExp(r'(?:rs\.?|inr)\s?([\d,]+(?:\.\d+)?)', caseSensitive: false);

  // Private constructor
  SbiCcTransactionParser._();

  // Static final instance, lazily initialized or initialized directly.
  // Using a static final field is the most common way to create singletons in Dart.
  static final SbiCcTransactionParser instance = SbiCcTransactionParser._();

  @override
  String getSource() {
    return SOURCE;
  }

  @override
  RegExp getAmountRegex() {
    return amountRegex;
  }
}