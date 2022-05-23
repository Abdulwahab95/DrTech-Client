import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Components/PhoneCall.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/OrderSetRating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'LiveChat.dart';

class OrderDetails extends StatefulWidget {
  final data;
  OrderDetails(this.data);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> with WidgetsBindingObserver {

  Map cancel = {}, errors = {}, data = {};

  @override
  void initState() {
    print('here_OrderDetails: ${widget.data}' );
    WidgetsBinding.instance.addObserver(this);
    data = widget.data;
    Globals.reloadPageOrderDetails = (){
      if(mounted) load();
    };
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('here_resumed_from: OrderDetails');
      load();
    }
  }

  void load() {
    NetworkManager.httpGet(Globals.baseUrl + "orders/details/${widget.data['id']}", context, (r){// orders/load?page=$page&status=$status
      if(mounted)
        setState(() {
          data['status'] = r['data']['status'];
          data['canceled_reason'] = r['data']['canceled_reason'];
          data['who_canceled'] = r['data']['who_canceled'];
          data['price'] = r['data']['price'];
        });
    }, cashable: false);
  }

  @override
  Widget build(BuildContext context) {
    print('here_OrderDetails_build: $data');
    return Scaffold(
        body: Column(
            textDirection: LanguageManager.getTextDirection(),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleBar(() {Navigator.pop(context);}, 178),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width * 0.455,
                margin:
                EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Converter.hexToColor("#F2F2F2"),
                    image: DecorationImage(
                        // fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(Globals.correctLink(data['service_icon'])))
                ),
                alignment: LanguageManager.getDirection()? Alignment.topLeft: Alignment.topRight,
                child: Row(
                  textDirection: LanguageManager.getDirection()? TextDirection.ltr : TextDirection.rtl,
                  children: [
                    Container(
                      height: 30,
                      padding: EdgeInsets.only(left: 5, right: 10),
                      // width: 60,
                      margin: EdgeInsets.only(top: 5),
                      alignment: Alignment.center,
                      child: Text(
                        getStatusText(data["status"]).replaceAll('\n', ' '),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          color: Converter.hexToColor(
                              data["status"] == 'CANCELED' || data["status"] == 'ONE_SIDED_CANCELED'
                                  ? "#f00000"
                                  : data["status"] == 'WAITING'
                                    ? "#0ec300"
                                    : "#2094CD"),
                          borderRadius: LanguageManager.getDirection()
                              ? BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15))
                              : BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15))),
                    ),
                  ],
                ),
              ),
              Container(
                height: 10,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    textDirection: LanguageManager.getTextDirection(),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["service_name"].toString(),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Converter.hexToColor("#2094CD")),
                      ),
                      Container(
                        height: 10,
                      ),
                      Row(
                        textDirection: LanguageManager.getTextDirection(),
                        children: [
                          Text(
                            LanguageManager.getText(95),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Converter.hexToColor("#2094CD")),
                          ),
                          Container(
                            width: 30,
                          ),
                          Container(
                            child: data['price'] == 0
                                ? Text(
                              LanguageManager.getText(405),
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Converter.hexToColor("#2094CD")),
                            )
                            : Row(
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Text(
                                  data["price"].toString(),
                                  textDirection:
                                  LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Converter.hexToColor("#2094CD")),
                                ),
                                Container(
                                  width: 5,
                                ),
                                Text(
                                  Globals.getUnit(isUsd: data['service_target']),
                                  textDirection:
                                  LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Converter.hexToColor("#2094CD")),
                                )
                              ],
                            ),
                            padding: EdgeInsets.only(
                                top: 2, bottom: 2, right: 10, left: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Converter.hexToColor("#F2F2F2")),
                          ),
                        ],
                      ),
                      Container(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: LanguageManager.getTextDirection(),
                        children: [
                          Row(
                            textDirection: LanguageManager.getTextDirection(),
                            children: [
                              Icon(
                                Icons.person,
                                color: Converter.hexToColor("#C4C4C4"),
                                size: 20,
                              ),
                              Container(
                                width: 7,
                              ),
                              Text(
                                data['name'].toString(),
                                style: TextStyle(
                                    color: Converter.hexToColor("#707070"),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                                textDirection:
                                LanguageManager.getTextDirection(),
                              )
                            ],
                          ),
                          Row(
                            textDirection: LanguageManager.getTextDirection(),
                            children: [
                              InkWell(
                                 onTap: () => PhoneCall.call(data['number_phone'], context, allowNotSubscribe: ((data["status"] == 'PENDING' || data["status"] == 'WAITING') && data["service_target"] != 'online_services' ) || UserManager.isSubscribe(), isOnlineService: data["service_target"] == 'online_services'),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    FlutterIcons.phone_faw,
                                    color: Converter.hexToColor("#344F64"),
                                    size: 22,
                                  ),
                                ),
                              ),
                              data["service_target"] == 'online_services'?
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => LiveChat(data['provider_id'].toString())));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.message,
                                    color: Converter.hexToColor("#344F64"),
                                    size: 22,
                                  ),
                                ),
                              ) : Container(),
                            ],
                          )
                        ],
                      ),
                      Container(
                        height: 10,
                      ),
                      Text(
                        LanguageManager.getText(258) + ': ' + data['description'].toString(),
                        style: TextStyle(
                            color: Converter.hexToColor("#707070"),
                            fontWeight: FontWeight.normal,
                            fontSize: 14),
                        textDirection: LanguageManager.getTextDirection(),
                      ),
                      data['status'] == 'ONE_SIDED_CANCELED' || data['status'] == 'CANCELED'
                          ? Container(height: 1,color: Colors.red.withAlpha(20), margin: EdgeInsets.symmetric(vertical: 15),)
                          : Container(),
                      data['status'] == 'ONE_SIDED_CANCELED' || data['status'] == 'CANCELED'
                          ? Text(
                          LanguageManager.getText(data['who_canceled'] == 'user'? 391 : 392) + ': ',
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
                      data['status'] == 'ONE_SIDED_CANCELED' || data['status'] == 'CANCELED'
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: Text(data['canceled_reason'] ?? '',
                          textDirection: LanguageManager.getTextDirection()))
                      : Container(),

                    ],
                  ),
                ),
              ),
              // data['status'] != 'PENDING' &&
              //     data['status'] != 'WAITING'
              //     ? Container()
              //     :
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(width: 30),
                data['status'] == 'WAITING'
                  ? Expanded(
                  flex: 1,
                    child: InkWell(
                      onTap: completedOrder,
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        child: Text(
                          LanguageManager.getText(179), // استلام الطلب
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  spreadRadius: 2,
                                  blurRadius: 2)
                            ],
                            borderRadius: BorderRadius.circular(8),
                            color: Converter.hexToColor("#0ec300")),
                      ),
                    ),
                  )
                    :Container(),
                  data['status'] != 'WAITING'
                      ? Container()
                      : Container(width: 15),
                  data['status'] == 'PENDING' || data['status'] == 'WAITING' || data['status'] == 'ONE_SIDED_CANCELED'
                  ? Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        data['status'] == 'ONE_SIDED_CANCELED' && data['who_canceled'] == 'user'? pendingOrder() : cancelOrder();
                      },
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        child: Text(
                          LanguageManager.getText(data['service_target'] == 'online_services'
                                ? data['status'] == 'ONE_SIDED_CANCELED'
                                  ? data['who_canceled'] == 'user' ? 390 : 180 // طلب إكمال الخدمة
                                  : 388 // أرسل طلب إلغاء
                                : 180), // إلغاء الطلب
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  spreadRadius: 2,
                                  blurRadius: 2)
                            ],
                            borderRadius: BorderRadius.circular(8),
                            color: Converter.hexToColor( data['status'] == 'ONE_SIDED_CANCELED' && data['who_canceled'] == 'user'  ? "#0ec300" : "#FF0000")),
                      ),
                    ),
                  )
                :Container(),
                  Container(width: 30),
                ],
              ),
              Container(
                height: 15,
              )
            ]));
  }

  void cancelOrderConferm() {

    errors = {};
    Alert.staticContent = getCancelWidget();
    Alert.setStateCall = () {};
    Alert.callSetState();

    if(cancel.isEmpty && data['status'].toString() != 'ONE_SIDED_CANCELED') {
      errors['canceled_reason'] = true;
      Alert.staticContent = getCancelWidget();
      Alert.setStateCall = () {};
      Alert.callSetState();
    }

    print('here_cancelOrderConferm: cancel: $cancel ${cancel.isEmpty}, errors: $errors');

    if (errors.keys.length > 0) {
      Globals.vibrate();
      return;
    }

    Navigator.pop(context);

    Alert.startLoading(context);

    cancel["status"] = data['service_target'].toString() == 'online_services' &&
        data['status'].toString() != 'ONE_SIDED_CANCELED'
        ? 'ONE_SIDED_CANCELED'
        : 'CANCELED';

    if(data['status'].toString() != 'ONE_SIDED_CANCELED')
      cancel["canceled_by"] = UserManager.currentUser("id");

    NetworkManager.httpPost(Globals.baseUrl + "orders/status/${data['id']}", context ,(r) { // orders/cancel
      if (r['state'] == true) {
        Globals.result = true;
        Navigator.popUntil(context, ModalRoute.withName('Orders'));
      }
    }, body: cancel);
  }

  void completedOrderConferm() {
    Alert.startLoading(context);
    // Map<String, String> body = {"id": data['id'].toString()};
    NetworkManager.httpPost(Globals.baseUrl + "orders/status/${data['id']}", context ,(r) async { //orders/completed
      if (r['state'] == true) {
        Alert.endLoading();
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSetRating(data['id'])));
        var results = await Navigator.push(context, MaterialPageRoute(builder: (_) => OrderSetRating(data['id'])));
        print('here_2: $results');
        if (results == true) {
          Globals.result = true;
          Navigator.popUntil(context, ModalRoute.withName('Orders'));
          Alert.show(context, Converter.getRealText(237));
        }
      }
    }, body: {"status":"COMPLETED"});
  }

  getCancelWidget() {
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
                  Navigator.pop(context);
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
              color: Converter.hexToColor("#f00000"),
            ),
          ),
          Container(height: 30),
          Text(
            LanguageManager.getText(296), // هل أنت متأكد من إلغاء الطلب؟
            style: TextStyle(
                color: Converter.hexToColor("#707070"),
                fontWeight: FontWeight.bold),
          ),
          data['status'] == 'ONE_SIDED_CANCELED' && data['who_canceled'] != 'user'
          ? Container()
          : Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Converter.hexToColor(errors['canceled_reason'] == true? "#ffd1ce" : "#F2F2F2"),
            ),
            child: TextField(
              onChanged: (v) {
                cancel["canceled_reason"] = v;
              },
              textDirection: LanguageManager.getTextDirection(),
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: InputBorder.none,
                  hintTextDirection: LanguageManager.getTextDirection(),
                  hintText: LanguageManager.getText(297)), // اكتب سبب الإلغاء...
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
                  width: MediaQuery.of(context).size.width * 0.45,
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
                  cancelOrderConferm();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    LanguageManager.getText(
                        data['service_target'].toString() == 'online_services' &&
                        data['who_canceled'] == 'user'
                        ? 388 // أرسل طلب إلغاء
                        : 180), // الغاء الطلب
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
                      color: Converter.hexToColor("#FF0000")),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
  void cancelOrder() {
    cancel = {};
    errors = {};

    if(Alert.callSetState != null) {
      Alert.staticContent = getCancelWidget();
      Alert.setStateCall = () {};
      Alert.callSetState();
    }

    Alert.show(context, getCancelWidget(), type: AlertType.WIDGET);
  }

  void completedOrder() {
    Alert.show(
        context,
        Container(
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
                      Navigator.pop(context);
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
                  FlutterIcons.info_fea,
                  size: 60,
                  color: Converter.hexToColor("#2094CD"),
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                LanguageManager.getText(181),
                style: TextStyle(
                    color: Converter.hexToColor("#707070"),
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 30,
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Alert.publicClose();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
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
                      Navigator.pop(context);
                      completedOrderConferm();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(182),
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
                          color: Converter.hexToColor("#2094CD")),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  pendingOrder() {
    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "orders/status/${data['id']}",  context, (r) { // orders/completed
      print('here_response: ${r['state'] == true}, r $r');
      if (r['state'] == true) {
        Globals.result = true;
        Navigator.popUntil(context, ModalRoute.withName('Orders'));
      }
    }, body: {"status":"PENDING"});
  }

  String getStatusText(status) {
    return LanguageManager.getText({
      'PENDING': 93,
      'WAITING': 92,
      'COMPLETED': 94,
      'CANCELED': 184,
      'ONE_SIDED_CANCELED': 389,
    }[status.toString().toUpperCase()] ??
        92);
  }

}
