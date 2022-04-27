import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Pages/FeatureSubscribe.dart';
import 'package:dr_tech/Pages/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Alert.dart';

class PhoneCall{

static void call(String phone, BuildContext context, {allowNotSubscribe: false, bool isOnlineService = false, bool showDirectOrderButton = false, Function() onTapDirect}) {

  if(UserManager.currentUser("id").isEmpty) {
      Alert.show(context, LanguageManager.getText(298),
          premieryText: LanguageManager.getText(30), onYes: () { // تسجيل الدخول
        Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
      }, onYesShowSecondBtn: false);
      return;
    }

    if (UserManager.isSubscribe() || allowNotSubscribe) {
      launch("tel:" + phone); // user['country']['country_code'] + user['number_phone']
    } else {
      Alert.show(
          context,
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (Alert.publicClose != null)
                          Alert.publicClose();
                        else
                          Navigator.pop(context);
                      },
                      child: Icon(
                        FlutterIcons.close_ant,
                        size: 24,
                      ),
                    )
                  ],
                ),
                Container(
                  height: 10,
                ),
                Text(
                  LanguageManager.getText(isOnlineService ? 52 : 408),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: 15,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 15),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => FeatureSubscribe()));
                          },
                          child: Container(
                            width: 90,
                            height: 45,
                            alignment: Alignment.center,
                            child: Text(
                              LanguageManager.getText(75),
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      spreadRadius: 2,
                                      blurRadius: 2)
                                ],
                                borderRadius: BorderRadius.circular(8),
                                color: Converter.hexToColor("#344f64")),
                          ),
                        ),
                      ),
                      !showDirectOrderButton ? Container() :
                      Container(
                        width: 15,
                      ),
                      !showDirectOrderButton ? Container() :
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            if(onTapDirect != null)
                              onTapDirect();
                            else
                              Navigator.push(context, MaterialPageRoute(builder: (_) => FeatureSubscribe()));
                          },
                          child: Container(
                            width: 90,
                            height: 45,
                            alignment: Alignment.center,
                            child: Text(
                              LanguageManager.getText(409),
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      spreadRadius: 2,
                                      blurRadius: 2)
                                ],
                                borderRadius: BorderRadius.circular(8),
                                color: Converter.hexToColor("#344f64")),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          type: AlertType.WIDGET);
    }
  }

}