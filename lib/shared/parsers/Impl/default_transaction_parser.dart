import 'package:flutter_getx_boilerplate/shared/parsers/transaction_parser.dart';

class DefaultTransactionParser extends TransactionParser {
  final SOURCE = "Unknown";
  final amountRegex = RegExp(r'(?:rs|inr)?\s?[\u20B9]?\s?([\d,]+\.?\d*)', caseSensitive: false);

  // Private constructor
  DefaultTransactionParser._();

  // Static final instance, lazily initialized or initialized directly.
  // Using a static final field is the most common way to create singletons in Dart.
  static final DefaultTransactionParser instance = DefaultTransactionParser._();

  @override
  String getSource() {
    return SOURCE;
  }

  @override
  RegExp getAmountRegex() {
    return amountRegex;
  }
}