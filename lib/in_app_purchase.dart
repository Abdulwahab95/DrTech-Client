import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Flutter Inapp Plugin by dooboolab'),
          ),
          body: InApp()),
    );
  }
}

class InApp extends StatefulWidget {
  @override
  _InAppState createState() => new _InAppState();
}

class _InAppState extends State<InApp> {
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  final List<String> _productLists = Platform.isAndroid
  ? [
    'android.test.purchased',
    'point_1000',
    '5000_point',
    'android.test.canceled',
    ]
  : [
    'subscription_week',
    'subscription_one_month',
    'subscription_three_month',
    'subscription_six_month',
    'subscription_one_year',
  ];

  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    if (_conectionSubscription != null) {
      _conectionSubscription.cancel();
      _conectionSubscription = null;
    }
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion.catchError((e)=> printWithTel(e.toString()) );
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // prepare
    var result = await connectBilling();
    printWithTel('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    // refresh items for android
    try {
      String msg = await FlutterInappPurchase.instance.consumeAll().catchError((e)=> printWithTel(e.toString()) );
      printWithTel('consumeAllItems: $msg');
    } catch (err) {
      printWithTel('consumeAllItems error: $err');
    }

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
          printWithTel('connected: $connected');
        });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
          printWithTel('purchase-updated:');
          printWithTel('purchase-updated: ${productItem.productId}');
          printWithTel('purchase-updated: $productItem');
        });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
          printWithTel('purchase-error:');
          printWithTel('purchase-error: ${purchaseError.message}');
          printWithTel('purchase-error: $purchaseError');
        });
  }

  void _requestPurchase(IAPItem item) {
    FlutterInappPurchase.instance.requestPurchase(item.productId).whenComplete(() => printWithTel('whenComplete complete')).catchError((e)=>printWithTel('_requestPurchase e: $e')).then((value) => printWithTel('_requestPurchase: $value'));
  }

  Future _getProduct() async {
    List<IAPItem> items =
    await FlutterInappPurchase.instance.getProducts(_productLists).catchError((e)=> printWithTel(e.toString()) );
    for (var item in items) {
      printWithTel(
          '${item.productId}, '
          '${item.localizedPrice}, '
          '${item.subscriptionPeriodNumberIOS}, '
          '${item.subscriptionPeriodUnitIOS}, ');
      this._items.add(item);
    }

    setState(() {
      this._items = items;
      this._purchases = [];
    });
  }

  Future _getPurchases() async {
    List<PurchasedItem> items =
    await FlutterInappPurchase.instance.getAvailablePurchases().catchError((e)=> printWithTel(e.toString()) );

    for (var item in items) {
      printWithTel(
          '${item.productId}, ${item.transactionId}, ${item.transactionDate}, ' +
              '${item.originalTransactionDateIOS}, ${item.originalTransactionIdentifierIOS}, ${item.transactionStateIOS}, '
      );
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
      this._purchases = items;
    });

  }

  Future _getPurchaseHistory() async {
    List<PurchasedItem> items =
    await FlutterInappPurchase.instance.getPurchaseHistory().catchError((e)=> printWithTel(e.toString()) );
    for (var item in items) {
      printWithTel(
          '${item.productId}, ${item.transactionId}, ${item.transactionDate}, ' +
              '${item.originalTransactionDateIOS}, ${item.originalTransactionIdentifierIOS}, ${item.transactionStateIOS}, '
      );
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
      this._purchases = items;
    });
  }

  List<Widget> _renderInApps() {
    List<Widget> widgets = this
        ._items
        .map((item) => Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                item.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            ),
            FlatButton(
              color: Colors.orange,
              onPressed: () {
                printWithTel("---------- Buy Item Button Pressed");
                this._requestPurchase(item);
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 48.0,
                      alignment: Alignment(-1.0, 0.0),
                      child: Text('Buy Item'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ))
        .toList();
    return widgets;
  }

  List<Widget> _renderPurchases() {
    List<Widget> widgets = this
        ._purchases
        .map((item) => Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                item.toString(),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    ))
        .toList();
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 20;
    double buttonWidth = (screenWidth / 3) - 20;

    return Container(
      padding: EdgeInsets.all(10.0),
      child: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  'Running on: $_platformVersion\n',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: buttonWidth,
                        height: 60.0,
                        margin: EdgeInsets.all(7.0),
                        child: FlatButton(
                          color: Colors.amber,
                          padding: EdgeInsets.all(0.0),
                          onPressed: () async {
                            printWithTel("---------- Connect Billing Button Pressed");
                            await connectBilling();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            alignment: Alignment(0.0, 0.0),
                            child: Text(
                              'Connect Billing',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: buttonWidth,
                        height: 60.0,
                        margin: EdgeInsets.all(7.0),
                        child: FlatButton(
                          color: Colors.amber,
                          padding: EdgeInsets.all(0.0),
                          onPressed: () async {
                            printWithTel("---------- End Connection Button Pressed");
                            await FlutterInappPurchase.instance.finalize().catchError((e)=> printWithTel(e.toString())).whenComplete(() =>printWithTel('complete disconnect'));
                            if (_purchaseUpdatedSubscription != null) {
                              _purchaseUpdatedSubscription.cancel();
                              _purchaseUpdatedSubscription = null;
                            }
                            if (_purchaseErrorSubscription != null) {
                              _purchaseErrorSubscription.cancel();
                              _purchaseErrorSubscription = null;
                            }
                            setState(() {
                              this._items = [];
                              this._purchases = [];
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            alignment: Alignment(0.0, 0.0),
                            child: Text(
                              'End Connection',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            width: buttonWidth,
                            height: 60.0,
                            margin: EdgeInsets.all(7.0),
                            child: FlatButton(
                              color: Colors.green,
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                printWithTel("---------- Get Items Button Pressed");
                                this._getProduct();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                alignment: Alignment(0.0, 0.0),
                                child: Text(
                                  'Get Items',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            )),
                        Container(
                            width: buttonWidth,
                            height: 60.0,
                            margin: EdgeInsets.all(7.0),
                            child: FlatButton(
                              color: Colors.green,
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                printWithTel("---------- Get Purchases Button Pressed");
                                this._getPurchases();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                alignment: Alignment(0.0, 0.0),
                                child: Text(
                                  'Get Purchases',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            )),
                        Container(
                            width: buttonWidth,
                            height: 60.0,
                            margin: EdgeInsets.all(7.0),
                            child: FlatButton(
                              color: Colors.green,
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                printWithTel("---------- Get Purchase History Button Pressed");
                                this._getPurchaseHistory();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                alignment: Alignment(0.0, 0.0),
                                child: Text(
                                  'Get Purchase History',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            )),
                      ]),
                ],
              ),
              Column(
                children: this._renderInApps(),
              ),
              Column(
                children: this._renderPurchases(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  printWithTel(String str){
    print('here:' + str);
    // Globals.printTel(str);
  }

  connectBilling() async{
    return await FlutterInappPurchase.instance
        .initialize()
        .catchError((e) {
      printWithTel(e.toString());
    })
        .whenComplete(() {
      printWithTel('complete connect billing');
      Timer(Duration(seconds: 2), ()
      {
        _getProduct();
      });
    });
  }
}


// {
//   'productId': 'subscription_three_month',
//   'price': 114.99,
//   'currency': 'AED',
//   'localizedPrice': 'AED 114.99',
//   'title': ,
//   'description': ,
//   'introductoryPrice': ,
//   'introductoryPricePaymentModeIOS': ,
//   'subscriptionPeriodNumberIOS': 3,
//   'subscriptionPeriodUnitIOS': 'MONTH',
//   'introductoryPricePaymentModeIOS': ,
//   'introductoryPriceNumberOfPeriodsIOS': ,
//   'introductoryPriceSubscriptionPeriodIOS': ,
//   'subscriptionPeriodAndroid': null,
//   'introductoryPriceCyclesAndroid': null,
//   'introductoryPricePeriodAndroid': null,
//   'freeTrialPeriodAndroid': null,
//   'iconUrl': null,
//   'originalJson': null,
//   'originalPrice': null,
//   'discounts': []
// }