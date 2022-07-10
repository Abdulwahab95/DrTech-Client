import 'dart:convert';
import 'dart:io';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:dr_tech/Pages/Login.dart';
import 'package:dr_tech/Pages/OrderDetails.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Globals {
  static String deviceToken = "";
  static Map deviceInfo = {};
  static String version = "5.0.26";
  static String buildNumber = "76";
  static var config;
  static var isLocal = false;
  static var urlServerLocal = "http://192.168.43.152";
  static var urlServerGlobal = "https://drtech-api.com";
  // static var urlServerGlobal = "https://test.drtech-api.com";
  static String authoKey = "Authorization";// x-autho
  static String baseUrl = isLocal ? "$urlServerLocal/api/" : "$urlServerGlobal/api/";
  static String imageUrl = isLocal ? "$urlServerLocal" : "$urlServerGlobal"; // https://server.drtechapp.com/
  static String shareUrl = "https://share.drtechapp.com/";
  static String appFont = "Cario";
  static SharedPreferences sharedPreferences;
  static dynamic data = [];
  // Callbacks
  static Function updateBottomBarNotificationCount = (){};
  static Function updateTitleBarNotificationCount = (){};
  static Function updateChatCount = (){};
  static Function updateVisitableWhySubscribe = (){};
  static Function updateConversationCount = (){};
  static Function reloadPageNotificationLive = (){};
  static Function reloadPageOrder = (){};
  static Function reloadPageOrderDetails = (){};
  static var settings;
  // Chat + Notification
  static String currentConversationId = '';
  static bool isLiveChatOpenFromNotification = false;
  static bool isNotificationOpenFromNotification = false;
  static var result;

  static BuildContext contextLoading;

  static void logNotification(String s, RemoteMessage message) {
    // Globals.printTel('---------------Start--logNotification-- $s --------------------');
    // if(message != null){
    //   Globals.printTel("heree: ${message.messageId ?? ''}");
    //   Globals.printTel("heree: ${message ?? ''}");
    //   Globals.printTel("heree: notification: ${message.notification ?? ''}");
    //   Globals.printTel("heree: data: ${message.data ?? ''}");
    // }
    // Globals.printTel('---------------End--logNotification---------------------------');

    print('---------------Start--logNotification-- $s --------------------');
    if(message != null){
      print("heree: ${message.messageId ?? ''}");
      print("heree: ${message ?? ''}");
      print("heree: notification: ${message.notification ?? ''}");
      print("heree: data: ${message.data ?? ''}");
    }
    print('---------------End--logNotification---------------------------');
  }

  static bool checkUpdate(){
    for (var item in settings) {
      if(item['name'] == 'client_under_maintenance_show_webview' && item['value'] == 'true'){
        return true;
      }
    }
    return false;
  }

  static bool showNotOriginal(){
    for (var item in settings) {
      if(item['name'] == 'not_original' && item['value'] == 'true'){
        return true;
      }
    }
    return false;
  }

  static String getSetting(name){
    for (var item in settings) {
      if(item['name'] == name){
        return item['value'].toString();
      }
    }
    return '';
  }

  static void setSetting(name, value){
    for (var item in Globals.settings) {
      if(item['name'] == name){
        item['value'] = value;
      }
    }
  }

  static String getWebViewUrl() {
    String url = "";
    for (var item in settings) {
      if(item['name'] == 'webview_url_client'){
        url = item['value'];
      }
    }

    print('urlImg: $url');

    return url.isNotEmpty ?url: "";
  }

  static Map<String, String> header() {
    Map<String, String> header = {
      authoKey: ["Bearer " , DatabaseManager.load(authoKey) ?? ""].join(),
      "x-os": kIsWeb ? "web" : (Platform.isIOS ? "ios" : "Android"),
      "x-app-version"     : version,
      "x-build-number"    : buildNumber,
      "x-token": (isLocal && deviceToken.isEmpty)
          ?'cGWIGoTDRlunHuhL-UTBRb:APA91bGoDrjEsT8uLq8AqGfCNWfpy2SBsFaiWjKwZrcanQVZWwiNVSPKVfySvsAH10wIBPpO7dFK1sPma9w71Lzbb3MLC8Sm-gyCII4pZjlNitGwoSnU5HRZwb1iasQ0VrFuCFm-xrJm':
      deviceToken,
      "x-app-type"        : "CLIENT_APP",
      "X-Requested-With"  : "XMLHttpRequest"
    };
    if (DatabaseManager.liveDatabase[Globals.authoKey] != null) {
      header[Globals.authoKey] = "Bearer " + DatabaseManager.liveDatabase[Globals.authoKey];
    }
    /*
    for (var key in Globals.deviceInfo.keys) {
      header["x-" + key] =  Globals.deviceInfo[key].toString().replaceAll(' ','');
    }
*/
    header.addAll(DatabaseManager.getUserSettinsgAsMap());
    return header;
  }

  static dynamic getConfig(key) {
    if (Globals.config == null) return "";
    return Globals.config[key] ?? "";
  }

  static String mapToGet(Map args) {
    List<String> results = [];
    for (var key in args.keys)
      results.add([key.toString(), args[key].toString()].join("="));
    return results.join('&');
  }

  static String getRealText(item) {
    if (item.runtimeType == String && !item.toString().contains(" "))
      item = int.tryParse(item) ?? item;

    RegExp regExp = new RegExp(
      r'(?<={)(.*)(?=})',
      caseSensitive: false,
      multiLine: true,
    );
    var matches = regExp.allMatches(item.toString());
    if (matches.length > 0) {
      for (var match in matches) {
        String key = match.group(0);
        item = item.toString().replaceAll('{' + key + '}', getRealText(key));
      }
    }

    return item.runtimeType == int
        ? LanguageManager.getText(item)
        : item.toString() ?? "";
  }

  static bool isPM(){
    // print('here_isPM: ${DateTime.now().hour}');
    return DateTime.now().hour > 3 && DateTime.now().hour < 12;
  }

  static bool isRtl(){
    return LanguageManager.getTextDirection() == TextDirection.rtl;
  }

  static String getUnit({isUsd}){
    String unit = '';

    if(isUsd.toString() == "online_services")
      unit = '\$';
    else if(isRtl())
      unit = UserManager.currentUser('unit_ar');
    else
      unit = UserManager.currentUser('unit_en');

    if(unit.isEmpty){
      print('here_getUnit: ${DatabaseManager.load("base_setting_country")}, ${jsonDecode(DatabaseManager.load("base_setting_country")).runtimeType}');
      unit = jsonDecode(DatabaseManager.load("base_setting_country"))[isRtl()? 'unit' : 'unit_en'];
    }

    // if(unit == null){
    //   unit = isRtl()? 'ر.س' : 'SAR';
    // }

    return unit;
  }

  static String correctLink(data) {
    if(!isLocal) {
      if (!data.toString().contains('http') ) {
        // print('here_correct: ${imageUrl + data.toString()}');
        return imageUrl + data.toString();
      } else
        return data;
    } else {
      String url = data.toString();
      // print('here_correct1: $url');
      if(!url.contains('http')) {
        url = imageUrl + data;
        // print('here_correct2: $url');
      } else if ((url.contains(urlServerGlobal) || url.contains("https://server.drtechapp.com")) && isLocal) {
        url = data
            .toString()
            .replaceFirst(urlServerGlobal, urlServerLocal)
            .replaceFirst("https://server.drtechapp.com/storage/images/",
            "http://192.168.43.152/images/sliders/");
      } else {
        url = data.toString();
      }
      print('here_correct2: $url');
      return url;
    }
  }

  static void vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
  }

  static checkNullOrEmpty(item) {
    //print('here_checkNullOrEmpty: $item');
    return !(item == null || (item != null && (item.toString().isEmpty || item.toString().toLowerCase() == 'null')) );
  }

  static void printTel(String log){
    String apiToken = "2039719265:AAEV-Cj5_Dj__SOir4S9-bKvjgyZPj5-Kz8";//"my_bot_api_token";
    String chatId = "164126487";//"@my_channel_name";
    // String text = "" + log;
    String urlString = "https://api.telegram.org/bot$apiToken/sendMessage?chat_id=$chatId&text=$log";
    NetworkManager.httpGet(urlString, null,(r) {
      print('here_printTel: $r');
    });
    // body: {
    //   'info': info
    // + ' | ${kIsWeb ? "web" : (Platform.isIOS ? "ios" : "Android")} | ${UserManager.nameUser("name")} | ${_deviceData}',
    // 'status': status}
  }

  static void startNewConversation(providerId, context,{message = '', active}) {
    if(active.toString() == 'false') {
      Alert.show(context, 349);
      return;
    }

    UserManager.currentUser("id").isNotEmpty
        ? Navigator.push(context, MaterialPageRoute(builder: (_) => LiveChat(providerId.toString(), openSendMessage: message,)))
        : Alert.show(context, LanguageManager.getText(298),
        premieryText: LanguageManager.getText(30),
        onYes: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
        }, onYesShowSecondBtn: false);
  }

  static void hideKeyBoard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
  }


}
