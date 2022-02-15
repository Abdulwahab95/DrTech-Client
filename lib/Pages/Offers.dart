import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Components/phoneCall.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';

import 'Login.dart';

class Offers extends StatefulWidget {
  final String id;
  final String phone;
  final String active;
  Offers(this.id, this.phone, this.active);

  @override
  _OffersState createState() =>
      _OffersState();
}

class _OffersState extends State<Offers> {

  List offers = [];
  bool isLoading = false;
  bool isSubscribe = UserManager.isSubscribe();

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    setState(() {
      isLoading = true;
    });

    NetworkManager.httpGet(Globals.baseUrl + "service/offers/${widget.id}",  context, (r) { // user/service?id=${widget.id}
      setState(() {isLoading = false;});
      if (r['state'] == true) {
        setState(() {
          offers = r['data'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            TitleBar((){Navigator.pop(context);}, LanguageManager.getText(354), without: true), // عروض هذه الخدمة
            isLoading
            ? Expanded(child: Center(child: CustomLoading()))
            : Expanded(child: Container(child: getBodyContents())),
          ],
        ));
  }

  Widget getBodyContents() {
    List<Widget> items = [];

    int i = 0;
    for (var item in offers) {
      items.add(createItem(item, ++i));
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 30),
      children: items,
    );
  }

  Widget createItem(item, int i) {
    return Container(
      // padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Converter.hexToColor("#2094cd"),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 2,
                spreadRadius: 2)
          ]),
      child: InkWell(
        onTap: () {
          setState(() {
            // item['opened'] = item['opened'] == true ? false : true;
          });
        },
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(width: 15),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: LanguageManager.getDirection()
                      ? BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                      : BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),

                child: Column(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        textDirection: LanguageManager.getTextDirection(),
                        children: [
                          Expanded(
                            child: Text(
                              LanguageManager.getText(352) + ' ' +'${Tafqeet.convert(i.toString())}',
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Converter.hexToColor("#2094CD"),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            item['price'].toString() + " " + Globals.getUnit(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 14,
                                color: Converter.hexToColor("#2094CD"),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1,width: double.infinity,color: Colors.grey.withAlpha(100)),
                    Container(
                      padding: EdgeInsets.only(top: 10,right: 10, left: 10 ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['description'].toString(),
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withAlpha(200),
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 16,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        textDirection: LanguageManager.getReversTextDirection(),
                        children: [
                          InkWell(
                            onTap: () {
                              Globals.startNewConversation(
                                  item['provider_id'].toString(), context,
                                  active: widget.active.toString(),
                                  message: Converter.replaceValue(
                                      LanguageManager.getText(351),
                                      item['description'].toString() +
                                          ', ' +
                                          item['price'].toString() +
                                          " " +
                                          Globals.getUnit()));
                            },
                            child: Column(
                              children: [
                                Container(
                                  // height: 40,
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    textDirection: LanguageManager.getTextDirection(),
                                    children: [
                                      Icon(
                                        Icons.chat,
                                        color: Converter.hexToColor("#344f64"),
                                        size: 14,
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                      Text(
                                        LanguageManager.getText(117),
                                        style: TextStyle(
                                            color: Converter.hexToColor("#344f64"),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withAlpha(15),
                                            spreadRadius: 2,
                                            blurRadius: 2)
                                      ],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Converter.hexToColor("#344f64"))),
                                ),
                                Text(
                                  LanguageManager.getText(348),
                                  style: TextStyle(
                                      color: Colors.transparent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          widget.phone.toString().isEmpty || widget.phone.toString().toLowerCase() == 'null'
                              ? Container()
                              : Container(
                            width: 10,
                          ),
                          widget.phone.toString().isEmpty || widget.phone.toString().toLowerCase() == 'null'
                              ? Container()
                              : InkWell(
                                onTap: () => PhoneCall.call(widget.phone, context),
                                child: Column(
                                  children: [
                                    Container(
                                      // height: 40,
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        textDirection: LanguageManager.getTextDirection(),
                                        children: [
                                          Icon(
                                            FlutterIcons.phone_faw,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          Container(
                                            width: 5,
                                          ),
                                          Text(
                                            LanguageManager.getText(96),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Container(
                                            width: 5,
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black.withAlpha(15),
                                                spreadRadius: 2,
                                                blurRadius: 2)],
                                          borderRadius: BorderRadius.circular(12),
                                          color: Converter.hexToColor("#344f64")
                                      ),
                                    ),
                                    Text(
                                      LanguageManager.getText(isSubscribe ? 358 : 348),
                                      style: TextStyle(
                                          color: isSubscribe ? Colors.green : Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
