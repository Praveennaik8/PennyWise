import 'package:penny_wise/shared/parsers/Impl/sbi_upi_transaction_parser.dart';

import 'Impl/default_transaction_parser.dart';
import 'transaction_parser.dart';
import 'impl/axis_cc_transaction_parser.dart';
import 'impl/sbi_cc_transaction_parser.dart';

class TransactionParserFactory {
  // Optional: If you want the factory itself to be a singleton
  TransactionParserFactory._(); // Private constructor
  static final TransactionParserFactory instance = TransactionParserFactory._(); // Static instance

  // The factory method
  TransactionParser? getParser(String smsBody) {
    final String lowercasedBody = smsBody.toLowerCase();

    if (TransactionParser.isNonTransactionBankingMessage(lowercasedBody)) {
      return null;
    }

    // SBI Card Check (Example Keywords)
    if (lowercasedBody.contains("sbi credit card")) {
      return SbiCcTransactionParser.instance;
    }

    // Axis Bank Check (Example Keywords)
    if (lowercasedBody.contains("axis")) {
      return AxisCcTransactionParser.instance;
    }

    // SBI UPI Check (Example Keywords)
    if (lowercasedBody.contains("upi") && lowercasedBody.contains("sbi")) {
      return SbiUpiTransactionParser.instance;
    }

    // Add more checks for other banks/services here
    // if (lowercasedBody.contains("icici bank")) {
    //   return IciciBankTransactionParser.instance;
    // }

    // If no specific parser is found
    return DefaultTransactionParser.instance;
  }
}