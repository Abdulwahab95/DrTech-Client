import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/RateStarsStateless.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/ProductDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../Models/UserManager.dart';
import '../Network/NetworkManager.dart';
import '../Pages/Login.dart';
import '../Pages/Orders.dart';
import '../Pages/WebBrowser.dart';
import 'Alert.dart';
import 'CustomLoading.dart';
import 'PhoneCall.dart';

class Product extends StatefulWidget {
  final item;
  const Product(this.item);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Map body = {}, errors = {}, selectedPaymentOption = {};

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      print('here_item_p: ${widget.item['payment_method']}');
      if((widget.item['payment_method'] is List) && (widget.item['payment_method'] as List).isNotEmpty)
        selectedPaymentOption = (widget.item['payment_method'] as List)[0];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.5;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetails(widget.item)));
      },
      child: Container(
        width: size,
        // margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border(
              left: BorderSide(color: Colors.grey, width: .5),
              right: BorderSide(color: Colors.grey, width: .5),
              bottom: BorderSide(color: Colors.grey, width: .5)),
          // boxShadow: [
        //   BoxShadow(blurRadius: 2, spreadRadius: 2, color: Colors.black.withAlpha(20))
        // ],
            // borderRadius: BorderRadius.circular(10),
            // color: Colors.white
        ),
        child: Stack(
          textDirection: LanguageManager.getReversTextDirection(),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Text(
                        widget.item['username'].toString(),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Converter.hexToColor("#2094CD"),
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.25),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                spreadRadius: 2,
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
                // Stars
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      RateStarsStateless(
                        12,
                        stars: widget.item['stars'].toInt(),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          Converter.format(widget.item['stars']),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.item['is_best_seller'] == 1?
                    Container(
                      margin: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
                      padding: EdgeInsets.only(left: 2, right: 2),
                      // height: 38,
                      child: Text(
                        LanguageManager.getText(463), //  الأفضل مبيعا
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                          color: Converter.hexToColor("#01365E")),
                    ): Container(height: 44),
                    widget.item['is_i_Liked_Loading'] == true
                        ? Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: CustomLoading(width: 24.0))
                        : InkWell(
                      onTap: () {
                          if(UserManager.currentUser("id").isEmpty) {
                            Alert.show(context, LanguageManager.getText(298), // عليك تسجيل الدخول أولاً
                                premieryText: LanguageManager.getText(30), onYes: () { //تسجيل الدخول
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
                                }, onYesShowSecondBtn: false);
                            return;
                          }
                          setState(() {
                            widget.item['is_i_Liked_Loading'] = true;
                        });
                          print('here_update_is_liked: before ${widget.item['is_i_Liked']}');
                        NetworkManager.httpPost(Globals.baseUrl + "product/${widget.item['is_i_Liked'] != true? 'add' : 'delete'}/favourite", context, (r) { // like?product_id= + widget.item["id"]
                          widget.item['is_i_Liked_Loading'] = false;
                          if (r['state'] == true) {
                            setState(() {
                              widget.item['is_i_Liked'] = r["data"]['product_status'] == 'added'? true : false;
                            });
                          }
                        }, body: {'user_id' : UserManager.currentUser('id'), 'product_id' : widget.item['id'].toString()});
                      },
                        child: Container(
                                margin: EdgeInsets.only(left: 15, right: 15),
                                child: Icon(FlutterIcons.heart_ant,
                                    size: 24,
                                    color: widget.item['is_i_Liked'] != true
                                        ? Colors.grey
                                        : Colors.red),
                              ),
                      ),
                  ]
                ),

                Stack(
                  children: [
                    Container(
                      width: size,
                      height: size,
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: CachedNetworkImageProvider(Globals.correctLink(widget.item['images'][0]))),
                          // borderRadius: BorderRadius.circular(5),
                          // boxShadow: [
                          //   BoxShadow(
                          //       color: Colors.blue.withAlpha(50),
                          //       blurRadius: 2,
                          //       offset: Offset(2, 2),
                          //       spreadRadius: 2.5)
                          // ],
                          color: Converter.hexToColor("#F2F2F2")),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 15),
                    //   child: Row(
                    //     textDirection: LanguageManager.getTextDirection(),
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       // InkWell(
                    //       //   onTap: () {
                    //       //     setState(() {
                    //       //       widget.item['is_i_Liked'] = widget.item['is_i_Liked'] != true ? true : false;
                    //       //     });
                    //       //     NetworkManager.httpGet(Globals.baseUrl + "product/like?product_id=" + widget.item["id"], context, (r) {
                    //       //       if (r['state'] == true) {
                    //       //         setState(() {
                    //       //           widget.item['is_i_Liked'] = r["data"];
                    //       //         });
                    //       //       }
                    //       //     });
                    //       //   },
                    //       //   child: Container(
                    //       //     margin: EdgeInsets.only(left: 5, right: 5),
                    //       //     child: Icon(FlutterIcons.heart_ant,
                    //       //         size: 24,
                    //       //         color: widget.item['is_i_Liked'] != true
                    //       //             ? Colors.grey
                    //       //             : Colors.red),
                    //       //   ),
                    //       // ),
                    //       Container(),
                    //       Container(
                    //         // width: 90,
                    //         padding: EdgeInsets.symmetric(horizontal: 10),
                    //         child: Text(
                    //           LanguageManager.getText(
                    //               widget.item['status'].toString().toUpperCase() == "USED" ? 143 : 142 ),
                    //           textAlign: TextAlign.center,
                    //           style: TextStyle(
                    //               color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                    //         ),
                    //         decoration: BoxDecoration(
                    //             borderRadius: LanguageManager.getDirection()
                    //                 ? BorderRadius.only(
                    //                     topRight: Radius.circular(20),
                    //                     bottomRight: Radius.circular(20))
                    //                 : BorderRadius.only(
                    //                     topLeft: Radius.circular(20),
                    //                     bottomLeft: Radius.circular(20)),
                    //             color: widget.item['status'].toString().toUpperCase() == "NEW"? Colors.red : Converter.hexToColor("#2094CD")),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Positioned.fill(
                    //     child:  Align(
                    //       alignment: LanguageManager.getDirection()? Alignment.bottomLeft : Alignment.bottomRight,
                    //       child: Container(
                    //         margin: EdgeInsets.only(bottom: 15),
                    //         padding: EdgeInsets.symmetric(horizontal: 5),
                    //         decoration: BoxDecoration(
                    //             borderRadius: LanguageManager.getDirection()
                    //                 ? BorderRadius.only(
                    //                 topRight: Radius.circular(20),
                    //                 bottomRight: Radius.circular(20))
                    //                 : BorderRadius.only(
                    //                 topLeft: Radius.circular(20),
                    //                 bottomLeft: Radius.circular(20)),
                    //             color: Colors.white,
                    //             boxShadow: [
                    //               BoxShadow(
                    //                   color: Colors.black.withAlpha(30),
                    //                   spreadRadius: 2,
                    //                   blurRadius: 2)
                    //             ],
                    //         ),
                    //         child:  widget.item['is_offer'].toString() == '1'?
                    //         Column(
                    //           textDirection: LanguageManager.getTextDirection(),
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //         Text(
                    //         widget.item['offer_price'].toString() + ' ' + Globals.getUnit(),
                    //           textDirection: LanguageManager.getTextDirection(),
                    //           style: TextStyle(
                    //               color: Colors.blue,
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.bold),
                    //         ),
                    //             Text(
                    //               widget.item['price'].toString() + ' ' + Globals.getUnit(),
                    //               textDirection: LanguageManager.getTextDirection(),
                    //               style: TextStyle(
                    //                   decoration: TextDecoration.lineThrough,
                    //                   color: Colors.grey))
                    //           ]
                    //         )
                    //           : Text(
                    //           widget.item['price'].toString() + ' ' + Globals.getUnit(),
                    //           textDirection: LanguageManager.getTextDirection(),
                    //           style: TextStyle(
                    //               color: Colors.blue,
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.bold),
                    //         ),
                    //       ),
                    //     ),),
                    widget.item['is_offer'].toString() == '1'?
                    Positioned.fill(
                        child:  Align(
                          alignment: LanguageManager.getDirection()? Alignment.topRight : Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 5, right: 5),
                            padding: EdgeInsets.only(left: 2, right: 2),
                            // height: 38,
                            child:  Row(
                              textDirection: LanguageManager.getTextDirection(),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flash_on_sharp, color: Converter.hexToColor("#01365E"), size: 15),
                                Text(
                                  LanguageManager.getText(464), //  العروض اليومية
                                  textDirection: LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Converter.hexToColor("#01365E")),
                                ),
                              ],
                            ) ,
                            decoration: BoxDecoration(
                                color: Converter.hexToColor("#FAC700")),
                          ),
                        ),): Container(),

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
                        widget.item[LanguageManager.getDirection()? 'name' : 'name_en'],
                        textDirection: LanguageManager.getTextDirection(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Converter.hexToColor("#023459"),
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                        ),
                      )),
                    ],
                  ),
                ),

                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(width: 5),
                    Text(
                    (widget.item[widget.item['is_offer'].toString() == '1'? 'offer_price': 'price'].toString()) + ' ' + Globals.getUnit(),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15, right: 5,left: 5),
                      child: Text(
                        LanguageManager.getText(465), //  يشمل الضريبة
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Colors.black,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                    ),
                  ],
                ),
                widget.item['is_offer'].toString() == '1'?
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(width: 5),
                    Text(
                        widget.item['price'].toString() + ' ' + Globals.getUnit(),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey)),
                    Container(
                      margin: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
                      padding: EdgeInsets.only(left: 4, right: 4),
                      // height: 38,
                      child: Text(  // وفر
                          LanguageManager.getText(466) + ' ' + (((widget.item['price'] - widget.item['offer_price']) * 100) / widget.item['price']).toString().split('.')[0] + ' %',
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                            height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                          color: Colors.red),
                    ),
                  ],
                ) : Container(height: 41.2),
                for(var iconInfo in widget.item['info'])
                  if(iconInfo.runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>')
                    createInfoIcon(iconInfo['icon'], iconInfo[LanguageManager.getDirection()? 'text_ar' : 'text_en'] ?? ''),

                // Container(
                //   height: 8,
                // ),
                Container(height: 10),
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
                                  LanguageManager.getText(350), // اطلبها
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
                Container(height: 10),

              ],
            ),

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

  createUnderLine() {
    return Container(
      height: 1,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 5),
      color: Converter.hexToColor('#C2C2C2'),
    );
  }

  createTextPrice(firstText, secondText, {color, fontSize = 16.0}) {
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




  void createOrderProduct(item) {
    if (!UserManager.checkLogin()) {
      Alert.show(context, LanguageManager.getText(298),
          premieryText: LanguageManager.getText(30),
          onYes: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
          }, onYesShowSecondBtn: false);
      return;
    }

    Alert.staticContent = contentOrderProduct();
    Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: false);

  }

  contentOrderProduct() {
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
                  maxLines: 2,
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
              createDuleOptions("selected_payment_method", 343, 135, 134, selectedPaymentOption["method"]== widget.item['payment_method'][0]['method']),
              Container(height: 10),
              if(widget.item[selectedPaymentOption['method'] == 'cash'? 'cash_invoice_info' : 'online_invoice_info'] != null)
                for (var invoiceInfo in widget.item[selectedPaymentOption['method'] == 'cash'? 'cash_invoice_info' : 'online_invoice_info'])
                  invoiceInfo['text_en'].toString().toLowerCase().contains('total')
                      ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        createUnderLine(),
                        createTextPrice(
                          invoiceInfo[LanguageManager.getDirection()? 'text_ar' : 'text_en'] , //  المجموع
                          Converter.format(invoiceInfo['number'].toString(), numAfterComma: 2) + ' ' + Globals.getUnit(),
                          color: Colors.black,
                          fontSize: 18.0,
                        )
                      ])
                      : createTextPrice(invoiceInfo[LanguageManager.getDirection()? 'text_ar' : 'text_en'], Converter.format(invoiceInfo['number'].toString(), numAfterComma: 2) + ' ' + Globals.getUnit()),

              Container(height: 5),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                      child: Text(LanguageManager.getText(472), // لايمكن إستبدال أو إرجاع هذا المنتج.
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                child: Row(
                  // textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: ()=> excutePayment(),
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

  excutePayment() async {
    Globals.hideKeyBoard(context);
    errors = {};

    if(!(body.containsKey('address') && body['address'].toString().isNotEmpty))
      errors['address'] = true;

    if(!(body.containsKey('other_phone') && body['other_phone'].toString().isNotEmpty))
      errors['other_phone'] = true;

    if(errors.isNotEmpty) {
      Alert.staticContent = contentOrderProduct();
      Alert.setStateCall = () {};
      Alert.callSetState();
      return;
    }

    body['product_id'] = widget.item['id'].toString();

    body['selected_payment_method'] = selectedPaymentOption['method'].toString();

    print('here_selectedPaymentOption: $selectedPaymentOption');
    if(selectedPaymentOption['method'] == 'cash') {
      Navigator.pop(context);

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
    }else if(selectedPaymentOption['method'] == 'myfatoorah'){
      var results = await Navigator.push(context, MaterialPageRoute(builder: (_) =>
          WebBrowser(Globals.urlServerGlobal + "/fatoorah/${UserManager.currentUser('id')}/invoice/${widget.item['id']}", LanguageManager.getText(343) + ' ' + selectedPaymentOption[LanguageManager.getDirection() ? "name" : "name_en"])));
      if (results == null) {
        Alert.show(context, LanguageManager.getText(240));
        return;
      }

      print('here_pay_from web results: $results');
      if (results.toString() == 'success') {
        Navigator.pop(context);

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
  }

  Widget createDuleOptions(key, title, yesOption, noOption, isActive) {

    // if(!(isActive is bool)&& (!body.containsKey('payment_method')))
    //   body["payment_method"] = isActive = jsonEncode(["myfatoorah","cash"]);

    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
        Expanded(
          flex: 1,
            child:
          Text(
            LanguageManager.getText(title),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 16,
                color: Converter.hexToColor("#2094CD"),
                fontWeight: FontWeight.bold),
          )),
          // Container(width: 20),
          // Container(height: 10),
          Expanded(
            flex: 2,
            child: Container(
              child: GestureDetector(
                onTap: () {
                  selectedPaymentOption = widget.item['payment_method'][0];print('here_payment_method: $selectedPaymentOption');
                  body[key] = selectedPaymentOption['method'];
                  Alert.staticContent = contentOrderProduct();
                  Alert.setStateCall = () {};
                  Alert.callSetState();
                },
                child: Row(
                  textDirection: LanguageManager.getTextDirection(),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(width: 2, color: Colors.grey)),
                        child: isActive
                            ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey),
                        )
                            : null,
                      ),
                    ),
                    Container(width: 10),
                    Text(widget.item['payment_method'][0][LanguageManager.getDirection()? 'name' : 'name_en'],
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // if((widget.item['payment_method'] is List) && (widget.item['payment_method'] as List).length > 1)
          // Container(width: 30),
          if((widget.item['payment_method'] is List) && (widget.item['payment_method'] as List).length > 1)
          Expanded(
            flex: 2,
            child: Container(
              child: InkWell(
                onTap: () {
                  selectedPaymentOption = widget.item['payment_method'][1]; print('here_payment_method: $selectedPaymentOption');
                  body[key] = selectedPaymentOption['method'];
                  Alert.staticContent = contentOrderProduct();
                  Alert.setStateCall = () {};
                  Alert.callSetState();
                },
                child: Row(
                  textDirection: LanguageManager.getTextDirection(),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(width: 2, color: Colors.grey)),
                        child: !isActive
                            ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey),
                        )
                            : null,
                      ),
                    ),
                    Container(width: 10),
                    Text(widget.item['payment_method'][1][LanguageManager.getDirection()? 'name' : 'name_en'],
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
