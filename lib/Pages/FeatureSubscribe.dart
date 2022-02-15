
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';

import 'Login.dart';
import 'Subscription.dart';

class FeatureSubscribe extends StatefulWidget {
  const FeatureSubscribe();

  @override
  _FeatureSubscribeState createState() => _FeatureSubscribeState();
}

class _FeatureSubscribeState extends State<FeatureSubscribe> {
  bool isLoading = false;
  Map config;

  @override
  void initState() {
    loadConfig();
    super.initState();
  }

  void loadConfig() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "subscribe/data", context, (r) { // subscription/Config
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        config = r['data'];
        setState(() {});
      }
    }, cashable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          textDirection: LanguageManager.getTextDirection(),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TitleBar(() {Navigator.pop(context);}, 346),
            getSubscriptionPlans(),
          ]),
    );
  }

  Widget getSubscriptionPlans() {
    return Expanded(
        child: isLoading
            ? Center(child : CustomLoading())
            : getContentItems());
  }

  Widget getContentItems() {
    return ScrollConfiguration(
      behavior: CustomBehavior(),
      child: Column(
        // padding: EdgeInsets.symmetric(horizontal: 0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: getFeatures()
      ),
    );
  }

  getFeatures() {
    List<Widget> children = [];

    children.add(Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [subscribeNow()],
    )));

    if (config['Features'] != "")
      for (var item in config['Features']) {
        children.add(Container(padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),child: Text('${item[0]}', textDirection: LanguageManager.getTextDirection(),textAlign: item[2] == '1'? TextAlign.center : TextAlign.start,)));
      }

    children.add(Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [subscribeNow()],
        )));

    return children;
  }

  Widget subscribeNow() {
    return InkWell (
      onTap: () async {
        if (!UserManager.checkLogin()) {
          Alert.show(context, LanguageManager.getText(298),
              premieryText: LanguageManager.getText(30),
              onYes: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
              }, onYesShowSecondBtn: false);
          return;
        }
        var results = await Navigator.push(context, MaterialPageRoute(builder: (_) => Subscription()));
        if(results.toString().contains('success'))
          Navigator.of(context).pop('success');
      },
      child: Container(
        width: 90,
        height: 45,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(75),
          style: TextStyle(color: Colors.white),
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
    );
  }
}
