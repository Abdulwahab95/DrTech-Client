import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Pages/Welcome.dart';
import 'package:flutter/material.dart';

import '../Models/DatabaseManager.dart';
import '../Models/LanguageManager.dart';

class BaseSettingPage extends StatefulWidget {
  const BaseSettingPage();

  @override
  _BaseSettingPageState createState() => _BaseSettingPageState();
}

class _BaseSettingPageState extends State<BaseSettingPage> {
  double logoSize = 0.3;

  String selectedLanguage = '', selectedCountry = '';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Converter.hexToColor("#2094cd"),
      body: Column(
        children: [
        Expanded(
          child: Container(
            child: SingleChildScrollView(
              child: Column(children: [
                Container(height: MediaQuery.of(context).size.height * .11),
                Container(
                  // color: Colors.red,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: size * logoSize * 0.1,
                      vertical: size * logoSize * 0.1,
                    ),
                    height: MediaQuery.of(context).size.height * logoSize * .6,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset("assets/images/logo_base_setting.png"),
                    ),
                  ),
                ),
                Container(height: 15),
                Text('SELECT YOUR COUNTRY', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),),
                Text('اختر بلدك', style: TextStyle(color: Colors.white, fontSize: 18),),
                Container(height: 15),
                Wrap(
                    // textDirection: LanguageManager.getTextDirection(),
                    children: [
                      for (var item in Globals.getConfig("countries"))
                        createCountryCode(item),
                    ]),

                selectedCountry.isEmpty? Container() :
                  AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                      color: Colors.black,
                    ),

                  if(selectedCountry.isNotEmpty)
                  AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        child: Text(
                          'SELECT YOUR LANGUAGE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800),
                        )),

                  if(selectedCountry.isNotEmpty)
                  AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        child: Text(
                          'اختر لغتك',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
                  if(selectedCountry.isNotEmpty)
                    AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        height: 15),
                  if(selectedCountry.isNotEmpty)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      child: Row(
                          // textDirection: LanguageManager.getTextDirection(),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            createLanguage('English'),
                            createLanguage('العربية'),
                          ]),
                    ),
                ]),
            ),
          ),
        ),
        // Expanded(child: Container()),
          if(selectedCountry.isNotEmpty && selectedLanguage.isNotEmpty)
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Welcome()), (route) => false);
                  // selectedLanguage = '';
                  // selectedCountry = '';
                  // setState(() {

                  // });
                },
                radius: 5,
              child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Converter.hexToColor('#FFB900')),
                  child: Text(
                    LanguageManager.getText(467), // استمر
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                ))),
            ),
        ],),
    );
  }

  Widget createLanguage(String item) {
    bool selected = selectedLanguage == item;
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
          onTap: () {
            setState(() {
              selectedLanguage = item;
              if(item == 'English'){
                LanguageManager.setLanguage("en,US");
              } else {
                LanguageManager.setLanguage("ar,SA");
              }
              setState(() {});
              // pageIndex = 0;
              // load();
            });
          },
          child: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  // color: selected
                  //     ? Converter.hexToColor("#2094CD")
                  //     : Converter.hexToColor("#F2F2F2"),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: selected? Colors.yellow : Colors.transparent, width: 2)
              ),
              child: Text(
                item,
                textDirection: LanguageManager.getTextDirection(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:FontWeight.bold,
                  color: Colors.white,
                ),
              ))),
    );
  }

  createCountryCode(item) {
    var code = item['code'];
    print('here_country_item: $item');
    bool selected = selectedCountry == code;
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            setState(() {
              selectedCountry = code;
              DatabaseManager.save("base_setting_country", jsonEncode(item));
              // pageIndex = 0;
              // load();
            });
          },
          child: Container(
            height: 50,
            width: 80,
              // padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                // color: selected
                //     ? Converter.hexToColor("#2094CD")
                //     : Converter.hexToColor("#F2F2F2"),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: selected? Colors.yellow : Colors.transparent, width: 2),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: CachedNetworkImageProvider(Globals.baseUrl + "storage/flags/" + code))
              ),
              )),
    );
  }

  // void close() {
  //   DatabaseManager.save("welcome", true);
  //
  //   var forceUpdate = Globals.getSetting('is_force_update_client');
  //   var blocked     = UserManager.currentUser('is_blocked');
  //
  //   if (blocked == '1')
  //     Alert.show(context, 313, onYes: () {
  //       Platform.isIOS ? exit(0) : SystemNavigator.pop();
  //     }, onYesShowSecondBtn: false, isDismissible: false);
  //   else if (forceUpdate == '1' && isExistUpdateClient())
  //     Alert.show(context, 314, onYes: (){
  //       launch(Globals.getConfig('client_store_app_link')[Platform.isIOS ?'url_ios':'url_android']);
  //     },onYesShowSecondBtn: false, isDismissible: false);
  //   else if (isExistUpdateClient())
  //     Alert.show(context, 315, onYes: (){
  //       launch(Globals.getConfig('client_store_app_link')[Platform.isIOS ?'url_ios':'url_android']);
  //     }, premieryText: 316, secondaryText: 317,onClickSecond: (){
  //       Navigator.pop(context);
  //       goToNext();
  //     }, isDismissible: false);
  //   else
  //     goToNext();
  //
  // }

}