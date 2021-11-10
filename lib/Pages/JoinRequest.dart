import 'dart:io';

import 'package:dr_tech/Components/NotificationIcon.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinRequest extends StatefulWidget {
  const JoinRequest();

  @override
  _JoinRequestState createState() => _JoinRequestState();
}

class _JoinRequestState extends State<JoinRequest> {
  Map<String, String> body = {}, selectedTexts = {}, errors = {};
  Map selectOptions = {};
  bool isLoading = true;
  Map config, data;
  Map slectedListOptions = {};
  List<Map> selectedFiles = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          Container(
              decoration: BoxDecoration(color: Converter.hexToColor("#2094cd")),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.only(left: 25, right: 25, bottom: 15, top: 30),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            LanguageManager.getDirection()
                                ? FlutterIcons.chevron_right_fea
                                : FlutterIcons.chevron_left_fea,
                            color: Colors.white,
                            size: 26,
                          )),
                      Text(
                        LanguageManager.getText(175),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      NotificationIcon(),
                    ],
                  ))),
          Expanded(
              child: getJoinLink())//isLoading ? Center(child: CustomLoading()) : getFormContent())
        ]));
  }

  getJoinLink() {
    return Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white,
                image: DecorationImage(image: AssetImage("assets/images/aggregator_provider.jpg"))),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
            child: Text(
              LanguageManager.getText(289), // 'يسعدنا إنضمامك إلينا\n كل ماعليك تحميل تطبيق مزودي الخدمة \nثم أنشئ حسابك وإبدأ ببيع خدماتك',
              textDirection: LanguageManager.getTextDirection(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Converter.hexToColor("#303030")),
            ),
          ),
          Container(height: 10),
          InkWell(
            onTap: openStore,
            child: Container(
              margin: EdgeInsets.all(10),
              height: 50,
              alignment: Alignment.center,
              child: Text(
                LanguageManager.getText(290), // 'تحميل التطبيق',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        ]);
  }

  void openStore() {
    // print('provider_store_app_link ${Globals.getConfig('provider_store_app_link')}');
    launch(Globals.getConfig('provider_store_app_link')[Platform.isIOS ?'url_ios':'url_android']);
  }
}
