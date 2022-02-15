
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/SubscriptionSlider.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Subscription extends StatefulWidget {
  const Subscription();

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  bool isLoading = false, isUserSubscriped = false;
  Map data;
  Map selectedPlan;
  Map coupon;
  String code;
  @override
  void initState() {
    loadConfig();
    super.initState();
  }

  void loadConfig() {
    setState(() {
      isLoading = true;
    });

    NetworkManager.httpPost(Globals.baseUrl + "subscribe/data", context, (r) { // subscription/Config

      setState(() {
        isLoading = false;
      });

      if (r['state'] == true) {

        data = r['data'];
        UserManager.updateSp('total_days', data['subscribe']['total_days'].toString());
        UserManager.updateSp('remain_days', data['subscribe']['remain_days'].toString());

        isUserSubscriped = UserManager.isSubscribe();

        print('here_subscribe: ${UserManager.currentUser('remain_days')}, ${data['subscribe']['remain_days']}');
        selectedPlan = data['packes'][data['selected_plan'] ?? 0];

        setState(() {});
      }
    }, cachable: false, body: {'user_id': UserManager.currentUser("id")});
  }

  void hideKeyBoard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
  }

  void checkCoupon() {
    if (code == null || code.isEmpty) {
      return;
    }
    hideKeyBoard();
    Map<String, String> body = {"code": code.toString()};
    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "subscription/checkPromoCode", context ,(r) {
      Alert.endLoading();
      if (r['status']) {
        if (r['valid'] == true) {
          String cutValue = r["code"]["amount"].toString();
          cutValue +=
              r["code"]["type"] == "PERCENTAGE" ? "%" : " " + Globals.getUnit();
          Alert.show(context, LanguageManager.getText(227) + "\n" + cutValue);
          setState(() {
            coupon = r["code"];
          });
        } else {
          Alert.show(context, LanguageManager.getText(226));
        }
      }
    }, body: body);
  }

  String getRealPrice(priceValue) {
    double price = double.parse(priceValue.toString());
    if (coupon != null) {
      double amount = double.parse(coupon["amount"]);
      switch (coupon['type']) {
        case "VALUE":
          price -= amount;
          break;
        case "PERCENTAGE":
          price -= (price * amount / 100.0);
          break;
        default:
      }
    }
    if (price < 0) price = 0;
    return Converter.format(price.toString(), numAfterComma: 3);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _close,
      child: Scaffold(
        body: Column(
            textDirection: LanguageManager.getTextDirection(),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleBar(() {_close();}, 40),
              isUserSubscriped ? getUserSubscription() : getSubscriptionPlans()
            ]),
      ),
    );
  }

  Widget getUserSubscription() {

    double prograssBarWidth = MediaQuery.of(context).size.width * 0.8;
    return Expanded(
        child: isLoading
            ? Center(
                child: CustomLoading(),
              )
            : Container(
                child: Column(
                  children: [
                    Container(
                      height: 20,
                    ),
                    Text(
                      LanguageManager.getText(229),
                      style: TextStyle(
                          color: Converter.hexToColor("#2094CD"),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 50,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LanguageManager.getText(347),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                color: Converter.hexToColor("#727272"),
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          ),
                          Text(
                            getRemainingTime(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                color: Converter.hexToColor("#2094CD"),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Container(
                        alignment: Alignment.centerRight,
                        width: prograssBarWidth,
                        height: 12,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.blueGrey.withAlpha(25)),
                        child: Container(
                          width: prograssBarWidth *
                              (1 - (data['subscribe']["remain_days"] / totalInSecounds())),
                          height: 12,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Converter.hexToColor("#344F64")),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     loadConfig();
                    //     setState(() {
                    //       isUserSubscriped = false;
                    //     });
                    //   },
                    //   child: Container(
                    //     width: 200,
                    //     height: 46,
                    //     alignment: Alignment.center,
                    //     decoration: BoxDecoration(
                    //         color: Converter.hexToColor("#344F64"),
                    //         borderRadius: BorderRadius.circular(10)),
                    //     child: Text(
                    //       LanguageManager.getText(231),
                    //       style: TextStyle(
                    //           color: Colors.white, fontWeight: FontWeight.bold),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ));
  }

  String getRemainingTime() {
    if (data['subscribe']["remain_days"] < 24 * 60 * 60) {
      return Converter.intToTimeWithText(data['subscribe']["remain_days"],
          format: "hh, mm");
    } else
      return (data['subscribe']["remain_days"] ~/ (24 * 60 * 60)).toString() +
          " " + LanguageManager.getText(58);
  }

  Widget getSubscriptionPlans() {
    return Expanded(
        child: isLoading
            ? Center(
                child: CustomLoading(),
              )
            : getConntetItems());
  }

  Widget getConntetItems() {
    return ScrollConfiguration(
      behavior: CustomBehavior(),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 0),
        children: [
          SubscriptionSlider(data["sliders"]),
          getContent(),
        ],
      ),
    );
  }

  Widget getContent() {
    return Column(
      textDirection: LanguageManager.getTextDirection(),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          LanguageManager.getText(220),
          textDirection: LanguageManager.getTextDirection(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Converter.hexToColor("#2094CD")),
        ),
        Container(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          margin: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black.withAlpha(8)),
          child: Wrap(
            textDirection: LanguageManager.getTextDirection(),
            children: getPlans(),
          ),
          // child: Container(
          //     child: Directionality(
          //       textDirection: LanguageManager.getTextDirection(),
          //       child: GridView.count(
          //         // mainAxisSpacing: 10,
          //         shrinkWrap: true,
          //         physics: NeverScrollableScrollPhysics(),
          //         //childAspectRatio: MediaQuery.of(context).size.width > 800 ? 2.45 : 1.45 ,
          //         // primary: false,
          //         // padding: const EdgeInsets.only(right: 10, left: 10),
          //         crossAxisSpacing: 10,
          //         crossAxisCount: 2,
          //         children: getPlans(),
          //       ),
          //     )),
        ),
        Container(
          height: 20,
        ),
        Column(
          textDirection: LanguageManager.getTextDirection(),
          children: getPaymentMethod(),
        ),
        Container(
          height: 10,
        ),
        // Container(
        //   padding: EdgeInsets.only(left: 5, right: 5),
        //   child: Row(
        //     textDirection: LanguageManager.getTextDirection(),
        //     children: [
        //       Text(
        //         LanguageManager.getText(86),
        //         style: TextStyle(
        //             color: Converter.hexToColor("#707070"),
        //             fontSize: 14,
        //             fontWeight: FontWeight.bold),
        //       ),
        //       Container(
        //         width: 10,
        //       ),
        //       Text(
        //         LanguageManager.getText(87),
        //         style: TextStyle(
        //             color: Converter.hexToColor("#2094CD"),
        //             fontSize: 14,
        //             fontWeight: FontWeight.bold),
        //       )
        //     ],
        //   ),
        // ),
        // Container(
        //   height: 10,
        // ),
        // Row(
        //   textDirection: LanguageManager.getTextDirection(),
        //   crossAxisAlignment: CrossAxisAlignment.end,
        //   children: [
        //     Expanded(
        //       child: Container(
        //         margin: EdgeInsets.only(left: 10, right: 10, top: 0),
        //         padding: EdgeInsets.only(left: 7, right: 7),
        //         decoration: BoxDecoration(
        //             color: Converter.hexToColor("#F2F2F2"),
        //             borderRadius: BorderRadius.circular(12)),
        //         child: TextField(
        //           onChanged: (t) {
        //             code = t;
        //           },
        //           textDirection: LanguageManager.getTextDirection(),
        //           decoration: InputDecoration(
        //               hintText: "",
        //               hintStyle: TextStyle(color: Colors.grey),
        //               border: InputBorder.none,
        //               hintTextDirection: LanguageManager.getTextDirection(),
        //               contentPadding:
        //                   EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
        //         ),
        //       ),
        //     ),
        //     InkWell(
        //       onTap: () {
        //         checkCoupon();
        //       },
        //       child: Container(
        //         width: 120,
        //         height: 46,
        //         alignment: Alignment.center,
        //         decoration: BoxDecoration(
        //             color: Converter.hexToColor("#344F64"),
        //             borderRadius: BorderRadius.circular(10)),
        //         child: Text(
        //           LanguageManager.getText(225),
        //           style: TextStyle(
        //               color: Colors.white, fontWeight: FontWeight.bold),
        //         ),
        //       ),
        //     ),
        //     Container(
        //       width: 20,
        //     )
        //   ],
        // ),
        // Container(
        //   height: 30,
        // ),
      ],
    );
  }

  List<Widget> getPlans() {
    List<Widget> items = [];
    if (data["packes"] != null)
      for (var plan in data["packes"]) {
        // items.add(Text('d'));
        items.add(Wrap(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(width: MediaQuery.of(context).size.width * 0.05),
            createSubcriptionsPlan(plan),
          ],
        ));
      }
    return items;
  }

  Widget createSubcriptionsPlan(plan) {
    bool isActive = selectedPlan == plan;
    Color color = isActive ? Colors.green : Converter.hexToColor("#344F64");
    return InkWell(
      onTap: () {
        setState(() {
          selectedPlan = plan;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        width: MediaQuery.of(context).size.width * 0.40 - 25,
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              child: !isActive
                  ? Container()
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: color)),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 2, color: color)),
            ),
            Container(
              width: 10,
            ),
            Text(
              plan[LanguageManager.getDirection() ? "name" :'name_en'],
              textDirection:  LanguageManager.getTextDirection(),
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  Widget getCouponBadge() {
    return coupon != null
        ? Container(
            width: 24,
            height: 24,
            margin: EdgeInsets.all(2),
            alignment: Alignment.center,
            child: Text(
              "%",
              style: TextStyle(
                  fontFamily: "",
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(50)),
          )
        : Container();
  }

  void cartPayment(Map pay) async {
    String url = [
      Globals.baseUrl,
      "payment/subscription/?user=",
      UserManager.currentUser(Globals.authoKey),
      "&plan_id=",
      selectedPlan["id"],
      "&method=",
      "2",
      "&coupon_id=",
      coupon != null ? coupon['id'] : "0"
    ].join();

    url = [Globals.baseUrl ,
      'subscribe/payment/?method=', pay['method'],
      '&price=', selectedPlan[pay['price_type']?? "price_usd"],
      '&days=', selectedPlan['days'],
      '&user_id=', UserManager.currentUser('id'),
    ].join();

    var results = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => WebBrowser(url, LanguageManager.getText(343) + ' ' + pay[LanguageManager.getDirection() ? "name" : "name_en"])));

    print('here_pay_from web results: $results');
    if (results.toString() == 'success') {
      isUserSubscriped = true;
      loadConfig();
    }
  }


  List<Widget> getPaymentMethod() {
    List<Widget> items = [];
    if (data["pay_methods"] != null)
      for (var pay in data["pay_methods"]) {
        print('getPaymentMethod: $pay');
        items.add(createPayment(pay));
      }
    return items;
  }

  createPayment(pay) {
    return InkWell(
      onTap: () => cartPayment(pay),
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(30),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(0, 1))
        ], borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Converter.hexToColor("#F2F2F2")),
                    child: Icon(
                        IconsMap.from[pay['icon_name']],
                        size: 30, color: Converter.hexToColor("#344F64")),
                  ),
                  Container(
                    width: 20,
                  ),
                  Column(
                    textDirection: LanguageManager.getTextDirection(),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pay[LanguageManager.getDirection() ? "name" : "name_en"],//LanguageManager.getText(135),
                        textDirection: LanguageManager.getTextDirection(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Converter.hexToColor("#2094CD")),
                      ),
                      Text(
                        getRealPrice(selectedPlan[pay['price_type']?? "price_usd"]).toString() +
                            " " +
                            (LanguageManager.getDirection()? pay['unit'] : pay['unit_en']) +
                            " / " +
                            selectedPlan[LanguageManager.getDirection() ? "name" : "name_en"],
                        textDirection: LanguageManager.getTextDirection(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.3,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Converter.hexToColor("#424242")),
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  selectedPlan["extra_days"] != null
                      ? Container(
                    padding:
                    EdgeInsets.only(left: 15, right: 15, top: 2, bottom: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Converter.hexToColor("#FBEDCD")),
                    child: Text(
                      "+" +
                          selectedPlan["extra_days"].toString() +
                          " " +
                          LanguageManager.getText(221),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )
                      :Container(),
                  Container(
                    width: 40,
                    child: Icon(
                      LanguageManager.getDirection()
                          ? FlutterIcons.chevron_left_fea
                          : FlutterIcons.chevron_right_fea,
                      color: Converter.hexToColor("#2094CD"),
                    ),
                  )
                ],
              ),
            ),
            getCouponBadge()
          ],
        ),
      ),
    );
  }


  int totalInSecounds() {
    return data['subscribe']["total_days"] * 24 * 60 * 60;
  }

  Future<bool> _close() async{
    if(isUserSubscriped) {
      Navigator.of(context).pop('success');
    } else {
      Navigator.pop(context);
    }
  }

}
