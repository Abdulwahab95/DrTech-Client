import 'dart:io';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Home.dart';
import 'JoinRequest.dart';


class DrTechCode extends StatefulWidget {
  final Map body;
  DrTechCode({this.body});
  @override
  _DrTechCodeState createState() => _DrTechCodeState();
}

class _DrTechCodeState extends State<DrTechCode> {

  bool errorInputOtp = false;
  String codeStr = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TitleBar(null, 16, without: true),
          Container(height: 15),
          Text(
            'اطلب الكود عبر الواتس اب:',
            textDirection: LanguageManager.getTextDirection(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Converter.hexToColor("#00463e"),
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          Container(height: 15),
          Container(
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(99), boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  spreadRadius: 2,
                  blurRadius: 2)
            ],),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: (){print('here_${Globals.getConfig("verification_code")}');launch(Uri.encodeFull(Globals.getConfig("verification_code")['contect']));}, // launch(Uri.encodeFull(['url']));
                child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(99)),
                    child: Icon(
                      IconsMap.from[Globals.getConfig("verification_code")['icon']],
                      size: 24,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
          Container(height: 15),
          Text(
                'ثم أدخل الكود في هذا الحقل:',//الرجاء ادخال الرمز المرسل على رقم الجوال
            textDirection: LanguageManager.getTextDirection(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Converter.hexToColor("#00463e"),
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: Colors.transparent),
                color: errorInputOtp
                    ? Converter.hexToColor( "#ffb6b6")
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5)),
            child: TextFormField(keyboardType: TextInputType.number,
                // controller: controlSms,
                autofocus: true,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                cursorColor: Colors.blue,
                onChanged: (value) {
                  codeStr = value;
                  if (value.length == 6) Globals.hideKeyBoard(context);
                }),
          ),
          Container(height: 15),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: confirm,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Converter.hexToColor("#344f64")),
                  height: 50,
                  width: 300,
                  child: Text(
                    LanguageManager.getText(21),// تأكيد
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirm() async {

    setState(() {errorInputOtp = false;});

    if (codeStr.length < 6) {
      errorInputOtp = true;
      Globals.vibrate();
      return;
    }

    Alert.startLoading(context);

    widget.body['key'] = Converter.replaceArabicNumber(codeStr);

    NetworkManager.httpPost(Globals.baseUrl + "users/login",  context, (r) { // user/login

      if (r['state'] == true) {
        Alert.endLoading();

        DatabaseManager.liveDatabase[Globals.authoKey] = r['data']['token'];
        DatabaseManager.save(Globals.authoKey, r['data']['token']);
        UserManager.proccess(r['data']['user']);

        if (UserManager.currentUser('is_blocked') == '1') {
          Alert.endLoading();
          Alert.show(context, 313, onYes: () {
            Platform.isIOS ? exit(0) : SystemNavigator.pop();
          }, onYesShowSecondBtn: false, isDismissible: false);
        } else
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Home()), (route) => false);
      }
    }, body: widget.body);

  }
}
