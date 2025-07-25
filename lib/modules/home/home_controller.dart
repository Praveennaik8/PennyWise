
import 'dart:math';

import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/models/response/users_response.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/sms_data.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  final ApiRepository apiRepository;
  HomeController({required this.apiRepository});

  var currentTab = MainTabs.home.obs;
  var users = Rxn<UsersResponse>();
  var user = Rxn<Datum>();

  late MainTab mainTab;
  late DiscoverTab discoverTab;
  late ResourceTab resourceTab;
  late InboxTab inboxTab;
  late MeTab meTab;

  @override
  void onInit() async {
    super.onInit();

    mainTab = MainTab();
    loadSmsData();

    discoverTab = DiscoverTab();
    resourceTab = ResourceTab();
    inboxTab = InboxTab();
    meTab = MeTab();
  }

  Future<void> loadUsers() async {
    var _users = await apiRepository.getUsers();
    if (_users!.data!.length > 0) {
      users.value = _users;
      users.refresh();
      _saveUserInfo(_users);
    }
  }

  Rxn<List<SmsData>> smsData = Rxn<List<SmsData>>();

  void signout() {
    var prefs = Get.find<SharedPreferences>();
    prefs.clear();

    // Get.back();
    NavigatorHelper.popLastScreens(popCount: 2);
  }

  void _saveUserInfo(UsersResponse users) {
    var random = new Random();
    var index = random.nextInt(users.data!.length);
    user.value = users.data![index];
    var prefs = Get.find<SharedPreferences>();
    prefs.setString(StorageConstants.userInfo, users.data![index].toRawJson());

    // var userInfo = prefs.getString(StorageConstants.userInfo);
    // var userInfoObj = Datum.fromRawJson(xx!);
    // print(userInfoObj);
  }

  void switchTab(index) {
    var tab = _getCurrentTab(index);
    currentTab.value = tab;
  }

  int getCurrentIndex(MainTabs tab) {
    switch (tab) {
      case MainTabs.home:
        return 0;
      case MainTabs.discover:
        return 1;
      case MainTabs.resource:
        return 2;
      case MainTabs.inbox:
        return 3;
      case MainTabs.me:
        return 4;
      default:
        return 0;
    }
  }

  MainTabs _getCurrentTab(int index) {
    switch (index) {
      case 0:
        return MainTabs.home;
      case 1:
        return MainTabs.discover;
      case 2:
        return MainTabs.resource;
      case 3:
        return MainTabs.inbox;
      case 4:
        return MainTabs.me;
      default:
        return MainTabs.home;
    }
  }

  Future<void> loadSmsData() async {
    final permission = await Permission.sms.request();
    if (!permission.isGranted) {
      // Permission denied, clear or show error
      smsData.value = [];
      return;
    }

    final SmsQuery query = SmsQuery();
    final now = DateTime.now();
    final twoDaysAgo = now.subtract(Duration(days: 2));

    List<SmsMessage> messages = await query.querySms(kinds: [SmsQueryKind.inbox]);

    // Filter and parse SMS messages using your parsing logic
    final List<SmsData> parsedList = [];

    for (var msg in messages) {
      final msgDate = msg.date ?? DateTime.now();
      if (msgDate.isBefore(twoDaysAgo)) continue;

      final parsed = parseSmsToSmsData(msg.body ?? '', msgDate);
      if (parsed != null) {
        parsedList.add(parsed);
      }
    }

    smsData.value = parsedList;
    print("parsed data");
    print(smsData.value);
  }

  SmsData? parseSmsToSmsData(String body, DateTime date) {
    final debitKeywords = ['debited', 'withdrawn', 'spent'];
    final creditKeywords = ['credited', 'received', 'earned'];
    final lowerBody = body.toLowerCase();

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
    parsed ??= _parseFallback(body, type, date);

    if (parsed != null) {
      print("Parsed SMS -> Body: $body, Source: ${parsed.source}, Amount: ${parsed.amount}, Type: ${parsed.type}, Date: $date");
    }

    return parsed;
  }

  SmsData? _parseSbiCreditCard(String body, String type, DateTime date) {
    if (!body.contains("SBI Credit Card")) return null;

    final amount = _extractAmount(body, r'(?:rs\.?|inr)\s?([\d,]+(?:\.\d+)?)');
    if (amount == null) return null;

    return SmsData(source: "SBI Credit Card", amount: amount, type: type, date: date);
  }

  SmsData? _parseAxisBank(String body, String type, DateTime date) {
    if (!body.contains("Axis Bank")) return null;

    final cardRegex = RegExp(r'Card no\.?\s*(\w+)', caseSensitive: false);
    final cardMatch = cardRegex.firstMatch(body);
    final cardNum = cardMatch?.group(1)?.trim();
    final source = cardNum != null ? "Axis Bank $cardNum" : "Axis Bank";

    final amount = _extractAmount(body.replaceAll(',', ''), r'(?<!Avl Lmt\s)INR\s*([\d.]+)');
    if (amount == null) return null;

    return SmsData(source: source, amount: amount, type: type, date: date);
  }

  SmsData? _parseSbiUpi(String body, String type, DateTime date) {
    if (!(body.contains("A/C") && body.contains("debited") && body.contains("trf to"))) return null;

    final toRegex = RegExp(r'trf to\s+([A-Za-z0-9 &]+)', caseSensitive: false);
    final toMatch = toRegex.firstMatch(body);
    final destination = toMatch?.group(1)?.trim();
    final source = destination != null ? "SBI UPI - $destination" : "SBI UPI";

    final amount = _extractAmount(body.replaceAll(',', ''), r'debited\s+by\s+([\d,]+(?:\.\d+)?)');
    if (amount == null) return null;

    return SmsData(source: source, amount: amount, type: type, date: date);
  }

  SmsData? _parseFallback(String body, String type, DateTime date) {
    final sourceRegex = RegExp(r'(?<=from|by|at|to|in)\s+([A-Za-z0-9 &]+)', caseSensitive: false);
    final sourceMatch = sourceRegex.firstMatch(body);
    final source = sourceMatch?.group(1)?.trim() ?? "Unknown";

    final amount = _extractAmount(body.toLowerCase().replaceAll(',', ''), r'(?:rs|inr)?\s?[\u20B9]?\s?([\d,]+\.?\d*)');
    if (amount == null) return null;

    return SmsData(source: source, amount: amount, type: type, date: date);
  }

  double? _extractAmount(String body, String pattern) {
    final regex = RegExp(pattern, caseSensitive: false);
    final match = regex.firstMatch(body);
    final amountStr = match?.group(1)?.replaceAll(',', '');
    return double.tryParse(amountStr ?? '');
  }

  Future<List<SmsData>> fetchParsedSms() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    return [
      SmsData(
        source: "HDFC Bank",
        amount: 1249.50,
        type: "debit",
        date: DateTime.now().subtract(Duration(hours: 2)),
      ),
      SmsData(
        source: "Amazon Refund",
        amount: 200.00,
        type: "credit",
        date: DateTime.now().subtract(Duration(days: 1, hours: 3)),
      ),
      SmsData(
        source: "SBI Card",
        amount: 799.99,
        type: "debit",
        date: DateTime.now().subtract(Duration(days: 2)),
      ),
      SmsData(
        source: "Salary",
        amount: 50000.00,
        type: "credit",
        date: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];
  }

}
