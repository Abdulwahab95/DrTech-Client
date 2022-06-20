import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/OpenImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../Components/Alert.dart';
import '../Components/PhoneCall.dart';
import '../Config/IconsMap.dart';
import '../Models/UserManager.dart';
import '../Network/NetworkManager.dart';
import 'Login.dart';
import 'Orders.dart';

class ProductDetails extends StatefulWidget {
  final args;
  const ProductDetails(this.args);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool isLoading = false;
  ScrollController sliderController = ScrollController();
  int sliderSelectedIndex = -1;
  Map body = {}, errors = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, 162),
          isLoading
              ? Expanded(child: Center(child: CustomLoading()))
              : Expanded(
                  child: ScrollConfiguration(
                  behavior: CustomBehavior(),
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    children: [
                      getSlider(),
                      Container(
                        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                        child: Row(
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Expanded(
                                child: Text(
                              widget.args['name'],
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                            widget.args['is_offer'].toString() == '1'
                            ? RichText(
                              textDirection: LanguageManager.getTextDirection(),
                              text: TextSpan(
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.args['price'].toString() + ' ' + Globals.getUnit(),
                                      style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey)),
                                  TextSpan(text: '\t'),
                                  TextSpan(text: widget.args['offer_price'].toString() + ' ' + Globals.getUnit()),
                                ],
                              ),
                            )
                            : Text(
                              widget.args['price'].toString() + ' ' + Globals.getUnit(),
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      for(var iconInfo in widget.args['details_info'])
                        if(iconInfo.runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>' && iconInfo['icon'] != null && iconInfo['text_ar'] != null )
                          createInfoIcon(iconInfo['icon'], iconInfo[LanguageManager.getDirection()? 'text_ar' : 'text_en'] ?? ''),
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 2, bottom: 0),
                        child: Text(
                          LanguageManager.getText(163),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Wrap(
                          textDirection: LanguageManager.getTextDirection(),
                          children: getProductSpecifications(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 2, bottom: 0),
                        child: Text(
                          LanguageManager.getText(165),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 2, bottom: 0),
                        child: Text(
                          widget.args["description"].toString(),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                )),
          isLoading? Container() :
          Container(
            margin: EdgeInsets.only(bottom: 5, top: 5),
            padding: EdgeInsets.all(7),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => PhoneCall.call(widget.args['phone'], context, showDirectOrderButton: true, onTapDirect: (){createOrderProduct(widget.args);}),
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection:
                        LanguageManager.getTextDirection(),
                        children: [
                          Icon(
                            FlutterIcons.phone_faw,
                            color: Colors.white,
                            size: 20,
                          ),
                          Container(
                            width: 5,
                          ),
                          Text(
                            LanguageManager.getText(96),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                    onTap: ()=> createOrderProduct(widget.args),
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection:
                        LanguageManager.getTextDirection(),
                        children: [
                          Icon(
                            Icons.chat,
                            color: Converter.hexToColor("#344f64"),
                            size: 20,
                          ),
                          Container(
                            width: 5,
                          ),
                          Text(
                            LanguageManager.getText(350),
                            style: TextStyle(
                                color:
                                Converter.hexToColor("#344f64"),
                                fontSize: 16,
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
                              color:
                              Converter.hexToColor("#344f64"))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  List<Widget> getProductSpecifications() {

    List<Widget> items = [];

    for(var item in widget.args['product_specifications'])
      if (item.runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>')
        items.add(createSpecificationsItem(item['icon'], item[LanguageManager.getDirection() ? 'text_ar' : 'text_en'] ?? ''));

    return items;
  }

  Widget createSpecificationsItem(icon, text) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.only(left: 15, right: 15),
      height: 38,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Icon(
            IconsMap.from[icon],
            color: Converter.hexToColor("#C4C4C4"),
          ),
          Container(
            width: 5,
          ),
          Text(
            text.toString(),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Converter.hexToColor("#707070")),
          ),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Converter.hexToColor("#F2F2F2")),
    );
  }

  Widget getSlider() {
    double size = MediaQuery.of(context).size.width * 0.95;
    return Center(
      child: Container(
        margin: EdgeInsets.all(10),
        width: size,
        height: size * 0.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Converter.hexToColor("#F2F2F2")),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  scrollDirection: Axis.horizontal,
                  controller: sliderController,
                  children: getSliderContent(Size(size - 20, size * 0.45)),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 20,
                        height: 0,
                      ),
                      Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: getSliderDots(),
                      ),
                      Icon(
                        FlutterIcons.share_2_fea,
                        color: Converter.hexToColor("#344F64"),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getSliderContent(Size size) {
    List<Widget> sliders = [];
    for (var item in widget.args['images']) {
      sliders.add(InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OpenImage(url: widget.args['images'].toString().replaceAll(',', '||').replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '')))),
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.contain, image: CachedNetworkImageProvider(Globals.correctLink(item)))),
        ),
      ));
    }
    return sliders;
  }

  List<Widget> getSliderDots() {
    List<Widget> sliders = [];
    for (var i = 0; i < widget.args['images'].length; i++) {
      bool selected = sliderSelectedIndex == i;
      sliders.add(Container(
        width: selected ? 14 : 8,
        height: 8,
        margin: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Converter.hexToColor(selected ? "#2094CD" : "#C4C4C4")),
      ));
    }
    return sliders;
  }

  Widget createInfoIcon(icon, text) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Icon(
            IconsMap.from[icon],
            color: Converter.hexToColor("#C4C4C4"),
            size: 20,
          ),
          Container(
            width: 10,
          ),
          Expanded(
              child: Text(
                Converter.getRealTime(text),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 16,
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
                        image: CachedNetworkImageProvider(Globals.correctLink(widget.args['images'][0]))),
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
              createRowText(LanguageManager.getText(454), widget.args[widget.args['is_offer'].toString() == '1'? 'offer_price' : 'price'].toString() + ' ' + Globals.getUnit()), //  سعر المنتج
              createRowText(LanguageManager.getText(455), widget.args['delivery_fee'].toString() + ' ' + Globals.getUnit()), // شحن المنتج
              createUnderLine(),
              createRowText(
                  LanguageManager.getText(456), //  المجموع
                  (widget.args['delivery_fee'] + widget.args[widget.args['is_offer'].toString() == '1'? 'offer_price' : 'price']).toString() + ' ' + Globals.getUnit(),
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
