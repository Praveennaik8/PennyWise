import '../transaction_parser.dart';

class AxisCcTransactionParser extends TransactionParser {
  final SOURCE = "Axis Credit Card";
  final amountRegex = RegExp(r'(?<!Avl Lmt\s)INR\s*([\d.]+)', caseSensitive: false);

  // Private constructor
  AxisCcTransactionParser._();

  // Static final instance, lazily initialized or initialized directly.
  // Using a static final field is the most common way to create singletons in Dart.
  static final AxisCcTransactionParser instance = AxisCcTransactionParser._();

  @override
  String getSource() {
    return SOURCE;
  }

  @override
  RegExp getAmountRegex() {
    return amountRegex;
  }
}
