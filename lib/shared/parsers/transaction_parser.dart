import '../../models/sms_data.dart';
import '../../models/transaction_type.dart';

/// An abstract class defining the contract for parsing transaction SMS messages.
///
/// Concrete implementations of this class will provide specific logic
/// to parse SMS messages from different banks or financial services.
abstract class TransactionParser {

  // Confirmation filters
  static final _creditCardConfirmKeywords = [
    'we have received payment', 'e-statement', 'statement', 'due',
    'received towards your axis credit card'
  ];
  static final _cdslKeywords = ['cdsl'];

  String getSource();

  RegExp getAmountRegex();

  /// Parses an SMS message body to extract transaction details.
  ///
  /// Implementations should analyze the [smsBody] to identify transaction
  /// information such as the amount, type (debit/credit), source, and date.
  ///
  /// - [smsBody]: The full text content of the SMS message.
  /// - [type]: Credit or Debit
  /// - [date]: The date and time the SMS message was received or sent.
  ///
  /// Returns an [SmsData] object if the SMS is successfully parsed as a
  /// transaction, otherwise returns `null`.
  SmsData? parseSms(String body, DateTime date) {
    body = body.toLowerCase();
    final TransactionType? type = TransactionType.getTransactionType(body);
    if (type == null) return null;

    final source = getSource();

    final amount = _extractAmount(
        body.replaceAll(',', ''), getAmountRegex());

    return amount != null
        ? SmsData(source: source, amount: amount, type: type, date: date)
        : null;
  }

  double? _extractAmount(String body, RegExp pattern) {
    final match = pattern.firstMatch(body.replaceAll(',', ''));
    return double.tryParse(match?.group(1)?.replaceAll(',', '') ?? '');
  }

  static bool matchesAny(String body, List<String> keywords) =>
      keywords.any(body.contains);

  static bool isNonTransactionBankingMessage(String body) {
    // Skip unwanted SMS
    return (matchesAny(body, _creditCardConfirmKeywords)
        || matchesAny(body, _cdslKeywords));
  }
}