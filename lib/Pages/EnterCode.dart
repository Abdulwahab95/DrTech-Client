import 'dart:async';
import 'dart:io';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/Parser.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:vibration/vibration.dart';

class EnterCode extends StatefulWidget {
  final Map body;
  final String selectedCountryCode;
  final Function sendSms;

  EnterCode(this.body, this.selectedCountryCode, this.sendSms);

  static Function callVerificationCompleted = (PhoneAuthCredential authCredential){};
  static Function callVerificationFailed = (){};
  static Function callCodeSent = (){};
  static Function callCodeAutoRetrievalTimeout = (){};

  @override
  _EnterCodeState createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  var visibleKeyboard = false;
  Map<int, String> code = {};
  TextEditingController controlSms = TextEditingController();
  String codeStr = '';
  int selectedIndex = 0;
  List<Map> fields = [];
  String countDownTimer = "00:00";
  int resendTime = 0;
  bool errorInputOtp = false;
  String phoneNumber, verificationId, otp;


  @override
  void initState() {
    for (var i = 0; i < 6; i++)
      fields.add({"Node": FocusNode(), "Controller": TextEditingController()});

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          visibleKeyboard = visible;
        });
      },
    );

    // config
    resendTime = Globals.getConfig("resend_time") != ""
        ? Parser(context).getRealValue(Globals.getConfig("resend_time"))
        : 60;

    countDownTimer = getTimeFromInt(resendTime);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fields[0]["Node"].requestFocus();
    });


    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print('heree: addPostFrameCallback');

      if(Globals.isLocal){
        Alert.endLoading();
        tick();
      } else {
        // sendSms();
        EnterCode.callVerificationCompleted = (PhoneAuthCredential authCredential) async {
          print('heree: verificationCompleted');
          if(authCredential != null && authCredential.smsCode != null && authCredential.smsCode.isNotEmpty) {
            codeStr = authCredential.smsCode;
            controlSms.text = codeStr;
          }
          Alert.endLoading();
          await conferm();
        };

        EnterCode.callCodeAutoRetrievalTimeout = (String verId){
          verificationId = verId;
        };

        EnterCode.callCodeSent = (String verId, [int forceCodeResent]){
          verificationId = verId;
          resendTime = Globals.getConfig("resend_time") != ""
              ? Parser(context).getRealValue(Globals.getConfig("resend_time"))
              : 60;
          tick();
        };

      }
    });
  }


  void tick() {
    print('heree: tick()');
    Timer(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        resendTime--;
      });
      if (resendTime < 0)
        resendTime = 0;
      else
        tick();

      countDownTimer = getTimeFromInt(resendTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            TitleBar((){Navigator.pop(context);}, 16, without: true),
            Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.25,
                          right: MediaQuery.of(context).size.width * 0.25,
                          top: MediaQuery.of(context).size.width * 0.15,
                          bottom: 25),
                      child: Text(
                        LanguageManager.getText(19),//الرجاء ادخال الرمز المرسل على رقم الجوال
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Converter.hexToColor("#00463e"),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.07,
                          right: MediaQuery.of(context).size.width * 0.07,
                          top: 5,
                          bottom: 20),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: [
                    //       getCodeField(0),
                    //       getCodeField(1),
                    //       getCodeField(2),
                    //       getCodeField(3),
                    //       getCodeField(4),
                    //       getCodeField(5),
                    //     ],
                    //   ),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2,
                                  color: Colors.transparent),
                              color: errorInputOtp
                                  ? Converter.hexToColor( "#ffb6b6")
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5)),
                          child: TextFormField(keyboardType: TextInputType.number,
                              controller: controlSms,
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
                            if (value.length == 6) hideKeyBoard();
                          }),
                        )
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: sendCode,
                            child: Text(
                                LanguageManager.getText(20),//اعادة ارسال
                                style: TextStyle(color: Converter.hexToColor("#40746e"))),
                          ),
                          Text(
                            countDownTimer,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Converter.hexToColor("#40746e")),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
            visibleKeyboard
                ? Container()
                : Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: conferm,
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
                )),
            Container(
              height: 20,
            )
          ],
        ));
  }

  Widget getCodeField(index) {
    double size = MediaQuery.of(context).size.width * 0.12;
    // if (size > 60) size = 60;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: selectedIndex == index
                  ? Converter.hexToColor("#2094cd")
                  : Colors.transparent),
          color: Converter.hexToColor(errorInputOtp
              ? "#ffb6b6"
              : selectedIndex == index
              ? "#ddeef7"
              : "#f2f2f2"),
          borderRadius: BorderRadius.circular(5)),
      child: TextField(
        onTap: () {
          setState(() {
            errorInputOtp = false;
            hideKeyBoard();
            fields[index]["Node"].requestFocus();
            fields[index]["Controller"].text = "";
            selectedIndex = index;
          });
        },
        textAlignVertical: TextAlignVertical.center,
        controller: fields[index]["Controller"],
        focusNode: fields[index]["Node"],
        onChanged: (v) {
          setState(() {
            errorInputOtp = false;
            code[index] = v;
            if (index < 5) {
              fields[index + 1]["Node"].requestFocus();
              fields[index + 1]["Controller"].text = "";
            } else {
              hideKeyBoard();
            }
            selectedIndex = index + 1;
          });
        },
        maxLength: 1,
        showCursor: false,
        enableInteractiveSelection: false,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        cursorHeight: 0,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }

  String getTimeFromInt(int time) {
    var secounds = time % 60;
    var menuts = (time - secounds) ~/ 60;
    return (menuts < 10 ? "0" : "") +
        menuts.toString() +
        ":" +
        (secounds < 10 ? "0" : "") +
        secounds.toString();
  }

  void sendCode() {
    if (resendTime > 0) {
      Alert.show(context, LanguageManager.getText(24)); //يرجي الانتظار قليلا قبل اعادة ارسال الرمز مجددا
      return;
    }

    if(Globals.isLocal){
      Alert.endLoading();
      tick();
    } else
      widget.sendSms();
  }

  Future<void> conferm() async {
    setState(() {errorInputOtp = false;});

    if (codeStr.length < 6) {
      errorInputOtp = true;
      vibrate();
      return;
    }

    Alert.startLoading(context);

    if(Globals.isLocal){
      NetworkManager.httpPost(Globals.baseUrl + "users/login", context ,(r) { // user/login
        Alert.endLoading();
        if (r['state'] == true) {
          DatabaseManager.liveDatabase[Globals.authoKey] = r['data']['token'];
          DatabaseManager.save(Globals.authoKey, r['data']['token']);
          UserManager.proccess(r['data']['user']);

          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Home()), (route) => false);
        }
      }, body: widget.body);
    } else
      signIn(codeStr, context);
  }

  Future<void> signIn(String otp, BuildContext contextPage) async {
    print('heree: signIn');
    var errorStr = '';
    await FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp)).
    onError((error, stackTrace) {errorStr = error.toString(); return;}).
    then((value) {
      Alert.endLoading();
      print('heree: $value');
      if(errorStr.isNotEmpty){
        if(errorStr.contains('credential is invalid'))
          Alert.show(contextPage, LanguageManager.getText(23));
        else
          Alert.show(contextPage, errorStr);
      } else if(value.runtimeType == UserCredential){
        print('heree: ${value.user.uid}');

        Alert.startLoading(context);
        NetworkManager.httpPost(Globals.baseUrl + "users/login", context ,(r) { // user/login
          Alert.endLoading();
          if (r['state'] == true) {

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
    });
  }

  void hideKeyBoard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
  }

  void vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
  }

}

enum CodeSendType { PHONE, EMAIL }
