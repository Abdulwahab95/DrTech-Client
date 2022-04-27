import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:dr_tech/Pages/Withdrawal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'AllTransactions.dart';

class Transactions extends StatefulWidget {
  const Transactions();

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  Map<int, List> data = {};
  bool isLoading = false;
  Map errors = {},body = {}, selectedPaymentOption = {};
  List payMethods = [];
  var balance;
  int page = 0;

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
   // if (page > 0 && data.values.last.length == 0) return;
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "user/onlineStatistics", context, (r) { // user/transactions?page=$page
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data[0]    = r['data']['transaction'];  //     page++;
          balance    = r['data']['balance_online'];
          payMethods = r['data']['pay_methods'];
        });
      }
    }, cashable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            textDirection: LanguageManager.getTextDirection(),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleBar(() {Navigator.pop(context);}, 185),
              Expanded(child: getContent()),
              getOptions()
            ]));
  }

  Widget getOptions() {
    if (data.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (double.parse(balance.toString()) <= 0) {
                  Alert.show(context, LanguageManager.getText(241)); // ليس  لديك اي رصيد قابل للسحب
                  return;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Withdrawal(
                            double.parse(balance.toString()),  Globals.getUnit(isUsd: 'online_services'))));
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(191), // سحب الرصيد
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
          ),
          Container(
            width: 10,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                Alert.staticContent = getAddMoneyWidget();
                Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: false);
                //https://test.drtech-api.com/user/payment/paypal?price=79&user_id=3&currency=USD
                // String url = [
                //   Globals.baseUrl,
                //   "payment/debit/?user=",
                //   UserManager.currentUser(Globals.authoKey)
                // ].join();
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(370), // إضافة رصيد
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
                    color: Converter.hexToColor("#2094CD")),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getContent() {
    if (isLoading == true && data.isEmpty)
      return Center(
        child: CustomLoading(),
      );

    List<Widget> items = [];
    items.add(Container(
      padding: EdgeInsets.all(25),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  spreadRadius: 2,
                  blurRadius: 2)
            ]),
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              alignment: Alignment.center,
              width: 110,
              child: Icon(
                FlutterIcons.wallet_faw5s,
                size: 60,
                color: Converter.hexToColor("#344F64"),
              ),
            ),
            Column(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Text(
                  LanguageManager.getText(186),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      color: Converter.hexToColor("#344F64"),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      balance.toString(),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#344F64"),
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                    Container(
                      width: 10,
                    ),
                    Text(
                      Globals.getUnit(isUsd: 'online_services'),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#344F64"),
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    ));

    if (data.length > 0 && data[0].length == 0) {
      return Column(
        children: items..add(EmptyPage("wallet", 188)),
      );
    }

    items.add(Row(
      textDirection: LanguageManager.getTextDirection(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 3),
          child: Text(
            LanguageManager.getText(187),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                color: Converter.hexToColor("#344F64"),
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AllTransactions()));
          },
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 3),
            child: Text(
              LanguageManager.getText(121),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ),
      ],
    ));

    for (var page in data.keys) {
      for (var item in data[page]) {
        items.add(createTransactionItem(item));
      }
    }
    return Recycler(
      children: items,
    );
  }

  Widget createTransactionItem(item) {
    String iconName = item['type'] == "WITHDRAWAL" ? "DEPOSIT" : "WITHDRAWAL";
    Color color  = item['type'] == "WITHDRAWAL" ? Colors.green : Colors.red;
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(color: Colors.grey.withAlpha(30), width: 1))),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: 70,
              child: SvgPicture.asset(
                "assets/icons/${iconName.toLowerCase()}.svg",
                width: 20,
                height: 20,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Text(
                    item['type'] == "WITHDRAWAL"
                        ? LanguageManager.getText(369) + item['id'].toString()
                        : item['order_id'] != 0
                        ? LanguageManager.getText(368) + item['id'].toString() + ' ${item['title']}'
                        : LanguageManager.getText(189) + item['id'].toString()
                    ,
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    Converter.getRealText(item['created_at']),
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      Converter.format(item['amount'].toString(), numAfterComma: 3),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(
                      width: 10,
                    ),
                    Text(
                      Globals.getUnit(isUsd: item['is_usd'].toString() == '1' ? 'online_services' : ''),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.normal, fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['user_payment_id'].toString() == '0'? '' : item['commission'].toString(),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#344F64"), fontWeight: FontWeight.bold, fontSize: 14, height: 1.2),
                    ),
                    Container(width: 10),
                    Text(
                      item['user_payment_id'].toString() == '0'? '' : '\$',
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#344F64"), fontWeight: FontWeight.bold, fontSize: 14, height: 1.2),
                    ),
                  ],
                ),
              ],
            ),

          ],
        ));
  }

  getAddMoneyWidget () {

    TextEditingController _controllerAmount      = new TextEditingController();

    if(body.isNotEmpty && body.containsKey('amount') && body["amount"].toString().isNotEmpty) {
      _controllerAmount.text = body["amount"];
      _controllerAmount.selection = TextSelection.fromPosition(TextPosition(offset: _controllerAmount.text.length));
    }

    return Stack(
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(),
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Text(
                        LanguageManager.getText(126),
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.blue),
                      ),
                    ),
                    Container(
                      child: InkWell(
                          onTap: () {
                              Navigator.pop(context);
                          },
                          child: Icon(FlutterIcons.close_ant)),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: getList(),
              ),
              //----
              Container(
                margin: EdgeInsets.all(5),
                child: Text(
                  LanguageManager.getText(371), // حدد المبلغ
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.blue),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                padding: EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                    color: Converter.hexToColor(
                        errors['amount'] != null
                            ? "#E9B3B3"
                            : "#F2F2F2"),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  textDirection: LanguageManager.getTextDirection(),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllerAmount,
                        onChanged: (t) {
                          body["amount"] = t;
                          if(t.isNotEmpty && errors["amount"] != null){
                            errors["amount"] = null;
                            Alert.staticContent = getAddMoneyWidget();
                            Alert.setStateCall = () {};
                            Alert.callSetState();
                          }
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
                    Text('\$',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Converter.hexToColor("#344f64")))
                  ],
                ),
              ),
              Container(
                width: 20,
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                child: InkWell(
                  onTap: (){
                    errors = {};
                    if ( body["amount"] == null || (body["amount"] != null && body["amount"].toString().isEmpty))
                      errors['amount'] = "_";
                    if(selectedPaymentOption.isEmpty)
                      errors['pay_method'] = "_";
                    if(errors.isNotEmpty) {
                      print('here_errors: $errors');
                      Alert.staticContent = getAddMoneyWidget();
                      Alert.setStateCall = () {};
                      Alert.callSetState();
                      return;
                    }
                    Navigator.of(context).pop();
                    openWebViewCharge();
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      LanguageManager.getText(372), // إضافة
                      style: TextStyle(
                        color: Colors.white,
                      ),
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
              Container(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void openWebViewCharge() async{

    String url = [
      Globals.urlServerGlobal,
      "/user/payment/${selectedPaymentOption['method']}",
      "?user_id=", UserManager.currentUser('id'),
      "&price=${body['amount']}"
      "&currency=USD",
    ].join();

    body = {};

    var results = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                WebBrowser(url, LanguageManager.getText(343) + ' ' + selectedPaymentOption[LanguageManager.getDirection() ? "name" : "name_en"])));//
    selectedPaymentOption = {};
    if (results.toString() == 'success') {
        page = 0;
        data = {};
        load();
    } else if (results == null) {
      Alert.show(context, LanguageManager.getText(240));
      return;
    }
  }

  List<Widget> getList() {
    List<Widget> items = [];
    for (var item in payMethods) {
      items.add(getPaymentOption(item));
    }
    return items;
  }

  Widget getPaymentOption(itemPay) {
    print('here_getPaymentOption: $itemPay');
    return InkWell(
        onTap: () {
          setState(() {
            selectedPaymentOption = itemPay;
            errors.remove('pay_method');
            Alert.staticContent = getAddMoneyWidget();
            Alert.setStateCall = () {};
            Alert.callSetState();
          });
        },
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          width: 3,
                          color: errors['pay_method'] != null
                              ? Colors.red.withAlpha(100)
                              : itemPay['method'] == selectedPaymentOption['method']
                                  ? Converter.hexToColor('#344f64')
                                  : Colors.grey)),
                  child: itemPay['method'] == selectedPaymentOption['method']
                      ? Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:  itemPay['method'] == selectedPaymentOption['method']? Converter.hexToColor('#344f64') : Colors.grey ),
                  )
                      : null,
                ),
              ),
              Container(
                width: 15,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: errors['pay_method'] != null? Colors.red.withAlpha(60) : Converter.hexToColor('#344f64').withAlpha(60),
                            blurRadius: 2,
                            spreadRadius: 2)
                      ]),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Icon(
                          IconsMap.from[itemPay['icon_name']],
                          size: 45, color: Converter.hexToColor("#344F64")),
                      Container(
                        width: 30,
                      ),
                      Text(
                        itemPay[ LanguageManager.getDirection() ? 'name' : 'name_en'],
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

}
