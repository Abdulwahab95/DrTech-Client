import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/EnterCodeWithdrawal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Withdrawal extends StatefulWidget {
  final double balance;
  final unit;
  const Withdrawal(this.balance, this.unit);

  @override
  _WithdrawalState createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  Map errors = {};
  Map body = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            textDirection: LanguageManager.getTextDirection(),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleBar(() {Navigator.pop(context);}, 191),
              Expanded(
                  child: ScrollConfiguration(
                behavior: CustomBehavior(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 40),
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.125,
                            right: MediaQuery.of(context).size.width * 0.125),
                        alignment: Alignment.center,
                        child: Text(
                          LanguageManager.getText(186) +
                              " " +
                              widget.balance.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Converter.hexToColor("#344F64")),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40, bottom: 10),
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.2,
                            right: MediaQuery.of(context).size.width * 0.2),
                        alignment: Alignment.center,
                        child: Text(
                          LanguageManager.getText(193),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Converter.hexToColor("#344F64")),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                        padding: EdgeInsets.only(left: 7, right: 7),
                        decoration: BoxDecoration(
                            color: Converter.hexToColor(errors['email'] != null
                                ? "#E9B3B3"
                                : "#F2F2F2"),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          onChanged: (t) {
                            body["email"] = t;
                            setState(() {
                              errors["email"] = null;
                            });
                          },
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          keyboardType: TextInputType.emailAddress,
                          textDirection: LanguageManager.getTextDirection(),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: "email@email.com",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              hintTextDirection:
                                  LanguageManager.getTextDirection(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          LanguageManager.getText(196),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        ),
                      ),
                      Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            padding: EdgeInsets.only(left: 7, right: 7),
                            decoration: BoxDecoration(
                                color: Converter.hexToColor(
                                    errors['amount'] != null
                                        ? "#E9B3B3"
                                        : "#F2F2F2"),
                                borderRadius: BorderRadius.circular(12)),
                            child: TextField(
                              onChanged: (t) {
                                body["amount"] = t;
                                setState(() {
                                  errors["amount"] = null;
                                });
                              },
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              textDirection: LanguageManager.getTextDirection(),
                              decoration: InputDecoration(
                                  hintText: "1000",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  hintTextDirection:
                                      LanguageManager.getTextDirection(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 0)),
                            ),
                          ),
                          Container(
                            width: 10,
                          ),
                          Text(Globals.getUnit(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Converter.hexToColor("#344f64")))
                        ],
                      )
                    ],
                  ),
                ),
              )),
              Container(
                margin: EdgeInsets.all(10),
                child: InkWell(
                  onTap: send,
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    child: Text(
                      LanguageManager.getText(194),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
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
              )
            ]));
  }

  void send() {
    hideKeyBoard();
    setState(() {
      errors = {};
    });
    if (body["email"] == null || !body["email"].toString().contains("@")) {
      setState(() {
        errors['email'] = "_";
      });
    }
    if (body["amount"] == null || int.parse(body["amount"]) > widget.balance) {
      setState(() {
        errors['amount'] = "_";
      });
    }

    if (errors.isNotEmpty) return;

    Alert.show(
        context,
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      FlutterIcons.x_fea,
                      size: 24,
                    ),
                  )
                ],
              ),
              Container(
                height: 30,
              ),
              Text(
                LanguageManager.getText(197)
                    .replaceAll("*", body["amount"] + "  " + Globals.getUnit())
                    .replaceAll("#", body["email"]),
                textDirection: LanguageManager.getTextDirection(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Converter.hexToColor("#707070"),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 30,
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      withdrawalConferm();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(194),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(15),
                                spreadRadius: 2,
                                blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Converter.hexToColor("#2094CD")),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Alert.publicClose();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(172),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                  )
                ],
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  void hideKeyBoard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
  }

  void withdrawalConferm() {
    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "user/withdrawalRequisite", context ,(r) {
      Alert.endLoading();
      if (r['state'] == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => EnterCodeWithdrawal(body)));
      }
      if (r["message"] != null) {
        Alert.show(context, Converter.getRealText(r['message']));
      }
    }, body: body);
  }
}
