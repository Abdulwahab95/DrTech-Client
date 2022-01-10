
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/cupertino.dart';

class UserManager {
  static bool checkLogin() {
    return DatabaseManager.load(Globals.authoKey).isNotEmpty;
  }

  static void proccess(dynamic data) {
    DatabaseManager.save("user_keys", data.keys.toList());
    for (var key in data.keys) {
      DatabaseManager.save(key, data[key]);
    }
  }

  static String currentUser(key) {
    if (!UserManager.checkLogin()) return "";
    var v = DatabaseManager.load(key).toString();
    return v ?? "";
  }

  static void updateSp(key, value) {
    DatabaseManager.save(key, value);
  }

  static void logout(callback) {
    NetworkManager.httpGet(Globals.baseUrl + "users/logout", null, (userInfo) {
      DatabaseManager.unset("current_panel");
      DatabaseManager.unset(Globals.authoKey);
      var dbData = DatabaseManager.load('user_keys');
      List userKeys = dbData != "" ? dbData : [];
      for (var key in userKeys) {
        DatabaseManager.unset(key);
      }
      callback();
    });
  }

  static void refrashUserInfo({callBack}) {
    if (!UserManager.checkLogin()) {if (callBack != null) callBack(); return;}
    NetworkManager.httpGet(Globals.baseUrl + "users/profile", null, (userInfo) {// user/info
      try {
        if (userInfo['state'] == true) {
          UserManager.proccess(userInfo['data']);
          Globals.updateNotificationCount();
          Globals.updateChatCount();
          Globals.updateConversationCount();
          if (callBack != null) callBack();
        } else
          UserManager.logout((){if (callBack != null) callBack();});
      } catch (e) {
        // error loading info log the user out ..
      }
    });
  }

  static void update(key, value, BuildContext context ,callback, {Map mapBody}) {
    print('here_update');
    Map<String, String> body = {"key": key, key: value};

    NetworkManager.httpPost(Globals.baseUrl + "users/account/update", context,(r) { // user/update
      callback(r['state']);
      if (r['state'] == true) {
        print('here_update: if');
        if(r['data']['user'] != null) {
          print('here_update: if2');
          UserManager.proccess(r['data']['user']);
        } else {
          print('here_update: else2');
          UserManager.proccess(r['data']);
        }
      }
    }, body: mapBody != null ? mapBody :body);
  }

  static void updateBody(body, BuildContext context ,callback) {
    print('here_updateBody');
    NetworkManager.httpPost(Globals.baseUrl + "users/account/update", context,(r) { // user/update
      callback(r);
      if (r['state'] == true) {
        print('here_updateBody: if');
        if(r['data']['user'] != null) {
          print('here_updateBody: if2');
          UserManager.proccess(r['data']['user']);
        } else {
          print('here_updateBody: else2');
          UserManager.proccess(r['data']);
        }
      }
    }, body: body);
  }
}
