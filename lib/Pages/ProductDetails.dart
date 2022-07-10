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
import 'WebBrowser.dart';

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
  Map body = {}, errors = {}, selectedPaymentOption = {};

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if((widget.args['payment_method'] is List) && (widget.args['payment_method'] as List).isNotEmpty)
        selectedPaymentOption = (widget.args['payment_method'] as List)[0];
    });
    super.initState();
  }
  
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
                              widget.args[LanguageManager.getDirection()? 'name' : 'name_en'],
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
                    onTap: () => PhoneCall.call(widget.args['phone'], context, showDirectOrderButton: true, onTapDirect: (){createOrderProduct(widget.args);}, indexTextDirectOrder: 350),
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
              createDuleOptions("selected_payment_method", 343, 135, 134, selectedPaymentOption["method"]== widget.args['payment_method'][0]['method']),
              Container(height: 10),
              if(widget.args[selectedPaymentOption['method'] == 'cash'? 'cash_invoice_info' : 'online_invoice_info'] != null)
                for (var invoiceInfo in widget.args[selectedPaymentOption['method'] == 'cash'? 'cash_invoice_info' : 'online_invoice_info'])
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

    body['product_id'] = widget.args['id'].toString();

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
          WebBrowser(Globals.urlServerGlobal + "/fatoorah/${UserManager.currentUser('id')}/invoice/${widget.args['id']}", LanguageManager.getText(343) + ' ' + selectedPaymentOption[LanguageManager.getDirection() ? "name" : "name_en"])));
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
                  selectedPaymentOption = widget.args['payment_method'][0];print('here_payment_method: $selectedPaymentOption');
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
                    Text(widget.args['payment_method'][0][LanguageManager.getDirection()? 'name' : 'name_en'],
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
          // if((widget.args['payment_method'] is List) && (widget.args['payment_method'] as List).length > 1)
          // Container(width: 30),
          if((widget.args['payment_method'] is List) && (widget.args['payment_method'] as List).length > 1)
            Expanded(
              flex: 2,
              child: Container(
                child: InkWell(
                  onTap: () {
                    selectedPaymentOption = widget.args['payment_method'][1]; print('here_payment_method: $selectedPaymentOption');
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
                      Text(widget.args['payment_method'][1][LanguageManager.getDirection()? 'name' : 'name_en'],
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
