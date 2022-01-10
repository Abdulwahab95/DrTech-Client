import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/NotificationIcon.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:dr_tech/Pages/Withdrawal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Transactions extends StatefulWidget {
  const Transactions();

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  Map<int, List> data = {};
  bool isloading = false;
  var balance, unit;
  int page = 0;

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    if (page > 0 && data.values.last.length == 0) return;
    setState(() {
      isloading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "user/transactions?page=$page", context, (r) {
      setState(() {
        isloading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data[r["page"]] = r['data'];
          balance = r['balance'];
          unit = Globals.getUnit();
          page++;
        });
      }
    }, cashable: true);
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
                if (double.parse(balance) <= 0) {
                  Alert.show(context, LanguageManager.getText(241));
                  return;
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Withdrawal(
                            double.parse(balance.toString()), unit)));
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(191),
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
                if (double.parse(balance) >= 0) {
                  Alert.show(context, LanguageManager.getText(239));
                  return;
                }
                String url = [
                  Globals.baseUrl,
                  "payment/debit/?user=",
                  UserManager.currentUser(Globals.authoKey)
                ].join();

                var results = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            WebBrowser(url, LanguageManager.getText(228))));
                if (results != null) {
                  if (results["message"] != null) {
                    Alert.show(
                        context, Converter.getRealText(results['message']));
                  }
                  if (results['state'] == true) {
                    page = 0;
                    data = {};
                    load();
                  }
                } else if (results == null) {
                  Alert.show(context, LanguageManager.getText(240));
                  return;
                }
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(192),
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
    if (isloading == true && data.isEmpty)
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
                      unit.toString(),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#344F64"),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    ));
    items.add(Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Text(
        LanguageManager.getText(187),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(
            color: Converter.hexToColor("#344F64"),
            fontWeight: FontWeight.bold,
            fontSize: 15),
      ),
    ));

    for (var page in data.keys) {
      for (var item in data[page]) {
        items.add(createTransactionItem(item));
      }
    }
    if (data.length > 0 && data[0].length == 0) {
      return Column(
        children: items..add(EmptyPage("wallet", 188)),
      );
    }
    return Recycler(
      onScrollDown: load,
      children: items,
    );
  }

  Widget createTransactionItem(item) {
    Color color = item['type'] == "WITHDRAWAL" ? Colors.red : Colors.green;
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
                "assets/icons/${item['type'].toString().toLowerCase()}.svg",
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
                        ? LanguageManager.getText(189) + item['id'].toString()
                        : LanguageManager.getText(190) +
                            " #" +
                            item['offer_id'].toString(),
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
            Text(
              item['amount'].toString(),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Container(
              width: 10,
            ),
            Text(
              unit.toString(),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.normal, fontSize: 16),
            ),
          ],
        ));
  }
}
