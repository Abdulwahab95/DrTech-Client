import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/Orders.dart';
import 'package:dr_tech/Pages/Transactions.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class PaymentOptions extends StatefulWidget {
  final messageItem, liveChatContext;
  PaymentOptions(this.messageItem, this.liveChatContext);

  @override
  _PaymentOptionsState createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  List data;
  Map selectedPaymentOption = {};
  bool isProcessing = false;

  @override
  void initState() {
    print('here_messageItem: ${widget.messageItem}');
    super.initState();
    Future.delayed(Duration.zero, () {
      if( widget.messageItem['message']['target'] == 'online_services')
        offerAccept('');
      else
        load();
    });

  }

  void load() {
    setState(() { data = ["CACH"]; });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null || isProcessing)
      return Container(
        height: 30,
        child: CustomLoading(),
        alignment: Alignment.center,
      );
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: getList(),
      ),
    );
  }

  List<Widget> getList() {
    List<Widget> items = [];
    items.add(Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            width: 20,
          ),
          Text(
            LanguageManager.getText(126),
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.blue),
          ),
          InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Icon(FlutterIcons.x_fea)),
        ],
      ),
    ));
    items.add(Container(
      height: 20,
    ));
    if( widget.messageItem['message']['target'] != 'online_services')
    for (var item in widget.messageItem['message']['pay_methods']) {
      items.add(getPaymentOption(item));
    }
    items.add(Container(
      height: 20,
    ));
    items.add(InkWell(
      onTap: selectedPaymentOption.isEmpty ? null : excutePayment,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(136),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  spreadRadius: 2,
                  blurRadius: 2)
            ],
            borderRadius: BorderRadius.circular(8),
            color: Converter.hexToColor("#344f64")
                .withAlpha(selectedPaymentOption.isEmpty ? 100 : 255)),
      ),
    ));
    return items;
  }

  // Widget getPaymentMethod(itemKey) {
  //   switch (itemKey) {
  //     case "CACH":
  //       return getPaymentOption(134, "cach", "CACH");
  //       break;
  //     case "CARD":
  //       return getPaymentOption(135, "visa", "CARD");
  //       break;
  //     default:
  //   }
  //   return Container();
  // }

  Widget getPaymentOption(itemPay) {
    print('here_getPaymentOption: $itemPay');
    return InkWell(
        onTap: () {
          setState(() {
            selectedPaymentOption = itemPay;
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
                      border: Border.all(width: 3, color: Colors.grey)),
                  child: itemPay['method'] == selectedPaymentOption['method']
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey),
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
                            color: Colors.black.withAlpha(20),
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

  void excutePayment() async {
    print('here_excutePayment: $selectedPaymentOption');
    if (selectedPaymentOption.isEmpty) {
      return;
    }
    if (selectedPaymentOption['method'] == "cash") {
      setState(() {
        isProcessing = true;
      });
      offerAccept('');
    } else {
      // /payment/myfatoorah?offer_id=79&user_id=3
      String url = [
        Globals.urlServerGlobal,
        // "test.drtech-api.com",
        "/payment/${selectedPaymentOption['method']}",
        "?user_id=", UserManager.currentUser('id'),
        "&offer_id=", widget.messageItem["message"]['id'],
        "&currency=USD",
        "&message_id=", widget.messageItem['id']
      ].join();

      var results = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>
              WebBrowser(url, LanguageManager.getText(343) + ' ' + selectedPaymentOption[LanguageManager.getDirection() ? "name" : "name_en"])));
      if (results == null) {
        Alert.show(context, LanguageManager.getText(240));
        return;
      }

      print('here_pay_from web results: $results');
      if (results.toString() == 'success') {
        onResponse({'state':true});
      }
    }
  }

  void offerAccept(paymentToken) {
    Map<String, String> body = {
      "message_id": widget.messageItem["id"].toString(),
      "offer_id": widget.messageItem["message"]['id'].toString(),
      "token": paymentToken
    };
    NetworkManager.httpPost(Globals.baseUrl + "orders/create",context, (r) { // orders/set
      onResponse(r);
    }, body: body);
  }

  void onResponse(r) {
    if (r['state'] == true) {
      Navigator.of(context).pop(true);
      Alert.show(widget.liveChatContext, Converter.getRealText(299),
          onYesShowSecondBtn: false,
          premieryText: Converter.getRealText(300),
          onYes: () {
            Navigator.of(widget.liveChatContext).pop(true);
            Navigator.push(widget.liveChatContext, MaterialPageRoute(settings: RouteSettings(name: 'Orders'), builder: (_) => Orders()));
          });
    }else{
      Navigator.of(context)..pop();
      Alert.show(context,getNotEnoughMoneyWidget(r['message'].toString().replaceAll('\\n', '\n')),type: AlertType.WIDGET);
    }
  }

  getNotEnoughMoneyWidget(message) {
    return Container(
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
                  Navigator.pop(widget.liveChatContext);
                },
                child: Icon(
                  FlutterIcons.x_fea,
                  size: 24,
                ),
              )
            ],
          ),
          Container(
            child: Icon(
              FlutterIcons.cancel_mdi,
              size: 50,
              color: Converter.hexToColor("#F5A623"),
            ),
          ),
          Container(height: 30),
          Text(
            message,
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 16,
                //color: Converter.hexToColor("#707070"),
                fontWeight: FontWeight.bold),
          ),
          Container(height: 30),
          Row(
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  Alert.publicClose();
                },
                child: Container(
                  width: MediaQuery.of(widget.liveChatContext).size.width * 0.45,
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
              ),
              InkWell(
                onTap: () {
                  Navigator.of(widget.liveChatContext).pop();
                  Navigator.push(widget.liveChatContext, MaterialPageRoute(builder: (_) => Transactions()));
                },
                child: Container(
                  width: MediaQuery.of(widget.liveChatContext).size.width * 0.45,
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    LanguageManager.getText(370), // الغاء الطلب
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
                      color: Converter.hexToColor("#F5A623")),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

}
