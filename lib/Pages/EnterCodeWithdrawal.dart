import 'dart:async';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/Parser.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:vibration/vibration.dart';

class EnterCodeWithdrawal extends StatefulWidget {
  final Map body;
  const EnterCodeWithdrawal(this.body);

  @override
  _EnterCodeWithdrawalState createState() => _EnterCodeWithdrawalState();
}

class _EnterCodeWithdrawalState extends State<EnterCodeWithdrawal> {
  var visibleKeyboard = false;
  Map<int, String> code = {};
  int selectedIndex = 0;
  List<Map> fileds = [];
  String countDownTimer = "00:00";
  int resendTime = 0;
  bool error = false;
  @override
  void initState() {
    for (var i = 0; i < 4; i++)
      fileds.add({"Node": FocusNode(), "Controller": TextEditingController()});

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
      fileds[0]["Node"].requestFocus();
    });
    tick();
    super.initState();
  }

  void tick() {
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
            TitleBar((){Navigator.pop(context);}, 198, withoutBell: true),
            Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.15,
                          bottom: 25),
                      child: Text(
                        LanguageManager.getText(199) +
                            "(" +
                            UserManager.currentUser("email") +
                            ")",
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
                          top: 20,
                          bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          getCodeField(0),
                          getCodeField(1),
                          getCodeField(2),
                          getCodeField(3),
                        ],
                      ),
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
                              LanguageManager.getText(20),
                              style: TextStyle(
                                  color: Converter.hexToColor("#40746e")),
                            ),
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
                          LanguageManager.getText(21),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
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
    double size = MediaQuery.of(context).size.width * 0.15;
    if (size > 60) size = 60;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: selectedIndex == index
                  ? Converter.hexToColor("#2094cd")
                  : Colors.transparent),
          color: Converter.hexToColor(error
              ? "#ffb6b6"
              : selectedIndex == index
                  ? "#ddeef7"
                  : "#f2f2f2"),
          borderRadius: BorderRadius.circular(5)),
      child: TextField(
        onTap: () {
          setState(() {
            error = false;
            hideKeyBoard();
            fileds[index]["Node"].requestFocus();
            fileds[index]["Controller"].text = "";
            selectedIndex = index;
          });
        },
        textAlignVertical: TextAlignVertical.center,
        controller: fileds[index]["Controller"],
        focusNode: fileds[index]["Node"],
        onChanged: (v) {
          setState(() {
            error = false;
            code[index] = v;
            if (index < 3) {
              fileds[index + 1]["Node"].requestFocus();
              fileds[index + 1]["Controller"].text = "";
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
      Alert.show(context, LanguageManager.getText(24));
      return;
    }

    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "user/withdrawalRequisite", context ,(r) {
      if (r['state'] == true) {
        Alert.endLoading();
        setState(() {
          resendTime = r['time'];
          tick();
        });
        Alert.show(context, LanguageManager.getText(25) + "\n" + r["to"]);
        // success
      }
    });
  }

  void conferm() {
    setState(() {
      error = false;
    });
    if (code.keys.length < 4) {
      error = true;
      vibrate();
      return;
    }
    Map<String, String> body = {};
    for (var key in widget.body.keys) {
      body[key] = widget.body[key].toString();
    }
    body["code"] = code.values.join();

    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "user/withdrawal", context ,(r) {
      if (r['state'] == true) {
        Alert.endLoading();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home(page: Globals.getSetting('show_store') == 'true'? 4 : 3)));
        // success
      }
    }, body: body);
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
