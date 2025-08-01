
import 'dart:math';

import 'package:flutter_getx_boilerplate/api/api.dart';
import 'package:flutter_getx_boilerplate/models/response/users_response.dart';
import 'package:flutter_getx_boilerplate/modules/home/home.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/monthly_summary.dart';
import '../../models/daily_summary.dart';
import '../../models/sms_data.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import "../../constants.dart";
import '../../shared/parsers/transaction_parser.dart';
import '../../shared/parsers/transaction_parser_factory.dart';

class HomeController extends GetxController {
  final ApiRepository apiRepository;
  HomeController({required this.apiRepository});

  var currentTab = MainTabs.home.obs;
  var users = Rxn<UsersResponse>();
  var user = Rxn<Datum>();

  late MainTab mainTab;
  late DailySummaryTab dailySummaryTab;
  late ResourceTab resourceTab;
  late MonthlySummaryTab monthlySummaryTab;
  late MeTab meTab;

  final smsData = Rxn<List<SmsData>>();
  final dailySummaries = Rxn<List<DailySummary>>();
  final monthlySummaries = Rxn<List<MonthlySummary>>();

  @override
  void onInit() async {
    super.onInit();

    mainTab = const MainTab();
    loadSmsData();

    dailySummaryTab = const DailySummaryTab();
    resourceTab = ResourceTab();
    monthlySummaryTab = const MonthlySummaryTab();
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
      case MainTabs.daily:
        return 1;
      case MainTabs.resource:
        return 2;
      case MainTabs.monthly:
        return 3;
      case MainTabs.me:
        return 4;
      }
  }

  MainTabs _getCurrentTab(int index) {
    switch (index) {
      case 0:
        return MainTabs.home;
      case 1:
        return MainTabs.daily;
      case 2:
        return MainTabs.resource;
      case 3:
        return MainTabs.monthly;
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
    final twoDaysAgo = now.subtract(const Duration(days: Constants.REQUIRED_DAYS));

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
    dailySummaries.value = parsedList.groupByDate();
    monthlySummaries.value = parsedList.groupByMonth();

    print("Parsed ${parsedList.length} SMS messages");
    print("Summary: ${dailySummaries.value}");
    print("parsed data");
    print(smsData.value);
  }

  SmsData? parseSmsToSmsData(String body, DateTime date) {
    TransactionParser? parser = TransactionParserFactory.instance.getParser(body);
    if (parser != null) {
      SmsData? data = parser.parseSms(body, date);
      if (data != null) {
        _logParsedSms(body, data, date);
        return data;
      }
    }
    return null;
  }

  static void _logParsedSms(String raw, SmsData data, DateTime date) {
    final cleaned = raw.replaceAll(',', ' ').replaceAll('\n', ' ');
    print(
        "Parsed SMS -> Body: $cleaned, Source: ${data.source}, Amount: ${data.amount}, Type: ${data.type}, Date: $date");
  }
}
