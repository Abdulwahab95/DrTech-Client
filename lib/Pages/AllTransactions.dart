import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions();

  @override
  _AllTransactionsState createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  Map data = {};
  bool isLoading = false;
  int page = 0;

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "user/transactions", context, (r) {
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data[page] = r['data'];
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
              TitleBar(() {Navigator.pop(context);}, 187),
              Expanded(child: getContent()),
              // getOptions()
            ]));
  }

  Widget getContent() {

    if (isLoading == true && data.isEmpty)
      return Center(
        child: CustomLoading(),
      );

    List<Widget> items = [];

    if (data[page].isEmpty) {
      return Column(
        children: items..add(Expanded(child: EmptyPage("wallet", 188))),
      );
    }


    // for (var page in data.keys) {
    for (var item in data[page]) { // (var item in data[page])
      items.add(createTransactionItem(item));
    }
    // }

    return Recycler(
      children: items,
    );
    // return items[0];
  }

  Widget createTransactionItem(item) {
    print('here_createTransactionItem: $item');
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
                color: color,
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
                    // textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: LanguageManager.getDirection() ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      Converter.format(item['amount'].toString(), numAfterComma: 3),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Container(width: 5),
                    Text(
                      Globals.getUnit(isUsd: item['is_usd'].toString() == '1' ? 'online_services' : item['service_target']),
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
                    Container(width: 5),
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
            Container(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          ],
        ));
  }

}
