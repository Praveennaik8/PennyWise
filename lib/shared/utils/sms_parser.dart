import '../../models/sms_data.dart';

class SmsParser{
  static SmsData? parseSmsToSmsData(String body, DateTime date) {
    final debitKeywords = ['debited', 'withdrawn', 'spent'];
    final creditKeywords = ['credited', 'received', 'earned'];
    final lowerBody = body.toLowerCase();

    // exclude credit card confirmation messages
    if (isCreditCardConfirmation(lowerBody)
        || isCDSLConfirmation(lowerBody)) {
      return null;
    }

    String? type;
    if (debitKeywords.any(lowerBody.contains)) {
      type = 'debit';
    } else if (creditKeywords.any(lowerBody.contains)) {
      type = 'credit';
    } else {
      return null;
    }

    SmsData? parsed;
    parsed ??= _parseSbiCreditCard(body, type, date);
    parsed ??= _parseAxisBank(body, type, date);
    parsed ??= _parseSbiUpi(body, type, date);
    // parsed ??= _parseFallback(body, type, date);

    body = body.replaceAll(',', ' ');
    body = body.replaceAll('\n', ' ');

    if (parsed != null) {
      print("Parsed SMS -> Body: $body, Source: ${parsed.source}, Amount: ${parsed.amount}, Type: ${parsed.type}, Date: $date");
    }
    return parsed;
  }

   static bool isCreditCardConfirmation(String body) {
    final confirmationKeywords = ['we have received payment', 'e-statement'];
    return confirmationKeywords.any(body.toLowerCase().contains);
  }

  static bool isCDSLConfirmation(String body) {
    final confirmationKeywords = ['cdsl'];
    return confirmationKeywords.any(body.toLowerCase().contains);
  }

  static SmsData? _parseSbiCreditCard(String body, String type, DateTime date) {
    if (!body.contains("SBI Credit Card")) return null;

    final amount = _extractAmount(body, r'(?:rs\.?|inr)\s?([\d,]+(?:\.\d+)?)');
    if (amount == null) return null;

    return SmsData(source: "SBI Credit Card", amount: amount, type: type, date: date);
  }

  static SmsData? _parseAxisBank(String body, String type, DateTime date) {
    if (!body.contains("Axis Bank")) return null;

    final cardRegex = RegExp(r'Card no\.?\s*(\w+)', caseSensitive: false);
    final cardMatch = cardRegex.firstMatch(body);
    final cardNum = cardMatch?.group(1)?.trim();
    final source = cardNum != null ? "Axis Bank $cardNum" : "Axis Bank";

    final amount = _extractAmount(body.replaceAll(',', ''), r'(?<!Avl Lmt\s)INR\s*([\d.]+)');
    if (amount == null) return null;

    return SmsData(source: source, amount: amount, type: type, date: date);
  }

  static SmsData? _parseSbiUpi(String body, String type, DateTime date) {
    if (!(body.contains("A/C") && body.contains("debited") && body.contains("trf to"))) return null;

    final toRegex = RegExp(r'trf to\s+([A-Za-z0-9 &]+)', caseSensitive: false);
    final toMatch = toRegex.firstMatch(body);
    final destination = toMatch?.group(1)?.trim();
    final source = destination != null ? "SBI UPI - $destination" : "SBI UPI";

    final amount = _extractAmount(body.replaceAll(',', ''), r'debited\s+by\s+([\d,]+(?:\.\d+)?)');
    if (amount == null) return null;

    return SmsData(source: source, amount: amount, type: type, date: date);
  }

  static SmsData? _parseFallback(String body, String type, DateTime date) {
    final sourceRegex = RegExp(r'(?<=from|by|at|to|in)\s+([A-Za-z0-9 &]+)', caseSensitive: false);
    final sourceMatch = sourceRegex.firstMatch(body);
    final source = sourceMatch?.group(1)?.trim() ?? "Unknown";

    final amount = _extractAmount(body.toLowerCase().replaceAll(',', ''), r'(?:rs|inr)?\s?[\u20B9]?\s?([\d,]+\.?\d*)');
    if (amount == null) return null;

    return SmsData(source: source, amount: amount, type: type, date: date);
  }

  static double? _extractAmount(String body, String pattern) {
    final regex = RegExp(pattern, caseSensitive: false);
    final match = regex.firstMatch(body);
    final amountStr = match?.group(1)?.replaceAll(',', '');
    return double.tryParse(amountStr ?? '');
  }
}