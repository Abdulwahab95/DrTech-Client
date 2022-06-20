import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../Models/UserManager.dart';
import '../Network/NetworkManager.dart';
import '../Pages/Login.dart';
import '../Pages/Orders.dart';
import 'Alert.dart';
import 'PhoneCall.dart';

class Product extends StatefulWidget {
  final item;
  const Product(this.item);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Map body = {}, errors = {};

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.5 - 30;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetails(widget.item)));
      },
      child: Container(
        width: size,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              blurRadius: 2, spreadRadius: 2, color: Colors.black.withAlpha(20))
        ], borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Stack(
          textDirection: LanguageManager.getReversTextDirection(),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size,
                      height: size * 0.5,
                      margin: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: CachedNetworkImageProvider(Globals.correctLink(widget.item['images'][0]))),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blue.withAlpha(50),
                                blurRadius: 2,
                                offset: Offset(2, 2),
                                spreadRadius: 2.5)
                          ],
                          color: Converter.hexToColor("#F2F2F2")),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // InkWell(
                          //   onTap: () {
                          //     setState(() {
                          //       widget.item['isLiked'] = widget.item['isLiked'] != true ? true : false;
                          //     });
                          //     NetworkManager.httpGet(Globals.baseUrl + "product/like?product_id=" + widget.item["id"], context, (r) {
                          //       if (r['state'] == true) {
                          //         setState(() {
                          //           widget.item['isLiked'] = r["data"];
                          //         });
                          //       }
                          //     });
                          //   },
                          //   child: Container(
                          //     margin: EdgeInsets.only(left: 5, right: 5),
                          //     child: Icon(FlutterIcons.heart_ant,
                          //         size: 24,
                          //         color: widget.item['isLiked'] != true
                          //             ? Colors.grey
                          //             : Colors.red),
                          //   ),
                          // ),
                          Container(),
                          Container(
                            // width: 90,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              LanguageManager.getText(
                                  widget.item['status'].toString().toUpperCase() == "USED" ? 143 : 142 ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: LanguageManager.getDirection()
                                    ? BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20))
                                    : BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20)),
                                color: widget.item['status'].toString().toUpperCase() == "NEW"? Colors.red : Converter.hexToColor("#2094CD")),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(
                        widget.item['name'],
                        textDirection: LanguageManager.getTextDirection(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                      Container(
                        margin: EdgeInsets.only(top: 3),
                        child: Text(
                          widget.item['price'].toString() + ' ' + Globals.getUnit(),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                for(var iconInfo in widget.item['info'])
                  if(iconInfo.runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>')
                    createInfoIcon(iconInfo['icon'], iconInfo[LanguageManager.getDirection()? 'text_ar' : 'text_en'] ?? ''),
                // Container(
                //   height: 8,
                // ),
                Container(
                  padding: EdgeInsets.only(right: 7, left: 7, bottom: 7, top: 3),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => PhoneCall.call(widget.item['phone'], context, showDirectOrderButton: true, onTapDirect: (){createOrderProduct(widget.item);}, indexTextDirectOrder: 350),
                          child: Container(
                            height: 30,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Icon(
                                  FlutterIcons.phone_faw,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                Text(
                                  LanguageManager.getText(96),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      spreadRadius: 2,
                                      blurRadius: 2)
                                ],
                                borderRadius: BorderRadius.circular(12),
                                color: Converter.hexToColor("#344f64")),
                          ),
                        ),
                      ),
                      Container(
                        width: 5,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: ()=> createOrderProduct(widget.item),
                          child: Container(
                            height: 30,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Icon(
                                  Icons.chat,
                                  color: Converter.hexToColor("#344f64"),
                                  size: 16,
                                ),
                                Text(
                                  LanguageManager.getText(350),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            widget.item['is_offer'].toString() == '1'?
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.132, right: 5, left: 5), //
              color: Colors.white,
              child: RichText(
                textDirection: LanguageManager.getTextDirection(),
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(text: widget.item['offer_price'].toString() + ' ' + Globals.getUnit()),
                    TextSpan(text: '\n'),
                    TextSpan(
                        text: widget.item['price'].toString() + ' ' + Globals.getUnit(),
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey)),
                  ],
                ),
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Widget createInfoIcon(icon, text) {
    return Container(
      padding: EdgeInsets.only(left: 7, right: 7),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Icon(
            IconsMap.from[icon],
            color: Converter.hexToColor("#C4C4C4"),
            size: 20,
          ),
          Container(
            width: 5,
          ),
          Expanded(
              child: Text(
            text,
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 14,
                color: Converter.hexToColor("#707070"),
                fontWeight: FontWeight.w600),
          ))
        ],
      ),
    );
  }

  void createOrderProduct(item) {
    if (!UserManager.checkLogin()) {
      Alert.show(context, LanguageManager.getText(298),
          premieryText: LanguageManager.getText(30),
          onYes: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
          }, onYesShowSecondBtn: false);
      return;
    }

    Alert.staticContent = contentOrderProduct(item);
    Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: false);

  }

  contentOrderProduct(item) {
    return Container(
    child: SingleChildScrollView(
      child: Column(
        textDirection: LanguageManager.getTextDirection(),
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SplashEffect(
                onTap: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                showShadow: false,
                child: Icon(FlutterIcons.close_ant, size: 24),
              ),
            ],
          ),
            Text(
              Converter.getRealText(LanguageManager.getText(458)), //تأكيد شراء المنتج
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, height: 1.2),
              textAlign: TextAlign.center,
            ),
          Container(height: 15),
          Container(
            width: 120,
            height: 120,
            margin: EdgeInsets.all(7),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(Globals.correctLink(widget.item['images'][0]))),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withAlpha(50),
                      blurRadius: 2,
                      offset: Offset(2, 2),
                      spreadRadius: 2.5)
                ],
                color: Converter.hexToColor("#F2F2F2")),
          ),
          Container(height: 15),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Converter.hexToColor(errors['address'] == true? "#ffd1ce" : "#F2F2F2"), //setPrice == '0'? "#ffd1ce" :
            ),
            child: TextField(
              onChanged: (v) {
                body['address'] = v;
                if(v.isNotEmpty)
                  setState(() {
                    errors['address'] = false;
                  });
              },
              textDirection: LanguageManager.getTextDirection(),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14),
                  hintTextDirection: LanguageManager.getTextDirection(),
                  hintText: LanguageManager.getText(459)), // اكتب عنوانك بالتفصيل:
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          // Container(height: 10),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Converter.hexToColor(errors['other_phone'] == true? "#ffd1ce" : "#F2F2F2"), //setPrice == '0'? "#ffd1ce" :
            ),
            child: TextField(
              onChanged: (v) {
                body['other_phone'] = v;
                if(v.isNotEmpty)
                  setState(() {
                    errors['other_phone'] = false;
                  });
              },
              textDirection: LanguageManager.getTextDirection(),
              maxLines: 1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14),
                  hintTextDirection: LanguageManager.getTextDirection(),
                  hintText: LanguageManager.getText(460)), // ادخل رقم هاتف اخر للتواصل:
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(height: 10),
          createRowText(LanguageManager.getText(454), widget.item[widget.item['is_offer'].toString() == '1'? 'offer_price' : 'price'].toString() + ' ' + Globals.getUnit()), //  سعر المنتج
          createRowText(LanguageManager.getText(455), widget.item['delivery_fee'].toString() + ' ' + Globals.getUnit()), // شحن المنتج
          createUnderLine(),
          createRowText(
              LanguageManager.getText(456), //  المجموع
              (widget.item['delivery_fee'] + widget.item[widget.item['is_offer'].toString() == '1'? 'offer_price' : 'price']).toString() + ' ' + Globals.getUnit(),
              color: Colors.black,
              fontSize: 18.0
          ),
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 15),
            child: Row(
              // textDirection: LanguageManager.getTextDirection(),
              children: [
                Expanded(
                  child: InkWell(
                    onTap: ()=> orderProductFromServer(item),
                    child: Container(
                      width: 90,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        Converter.getRealText(21), // تأكيد
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                    child: InkWell(
                  onTap: (){
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: 45,
                    alignment: Alignment.center,
                    child: Text(
                      LanguageManager.getText(172), // تراجع
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                ))
              ],
            ),
          ),

        ],
      ),
    ));
  }

  createUnderLine() {
    return Container(
      height: 1,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 5),
      color: Converter.hexToColor('#C2C2C2'),
    );
  }

  createRowText(firstText, secondText, {color, fontSize = 16.0}) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Text(firstText, textDirection: LanguageManager.getTextDirection(), style: color == null ? TextStyle(fontSize: fontSize,  color: Colors.black.withAlpha(150),fontWeight: FontWeight.bold) : TextStyle(fontSize: fontSize, color: color)),
          Expanded(child: Container()),
          Text(secondText, textDirection: LanguageManager.getTextDirection(), style: color == null ? TextStyle(fontSize: fontSize, color: Colors.green,  fontWeight: FontWeight.bold) : TextStyle(fontSize: fontSize, color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  void orderProductFromServer(item) {
    Globals.hideKeyBoard(context);
    errors = {};

    if(!(body.containsKey('address') && body['address'].toString().isNotEmpty))
      errors['address'] = true;

    if(!(body.containsKey('other_phone') && body['other_phone'].toString().isNotEmpty))
      errors['other_phone'] = true;

    if(errors.isNotEmpty) {
      Alert.staticContent = contentOrderProduct(item);
      Alert.setStateCall = () {};
      Alert.callSetState();
      return;
    }

    Navigator.pop(context);
    body['product_id'] = item['id'].toString();


    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "orders/create/order/product",context, (r) { // orders/set
      if (r['state'] == true) {
        Alert.endLoading(context2: context);
        Alert.show(context, Converter.getRealText(r['data'] is int? r['data'] : 453),
            onYesShowSecondBtn: false,
            premieryText: Converter.getRealText(300),
            onYes: () {
              Navigator.of(context).pop(true);
              Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'Orders'), builder: (_) => Orders()));
            });
      }
    }, body: body);
  }

}
