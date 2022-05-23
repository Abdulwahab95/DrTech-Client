import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Pages/Conversations.dart';
import 'package:dr_tech/Pages/FeatureSubscribe.dart';
import 'package:dr_tech/Pages/JoinRequest.dart';
import 'package:dr_tech/Pages/Login.dart';
import 'package:dr_tech/Pages/Orders.dart';
import 'package:dr_tech/Pages/Subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Pages/UserFavoritServices.dart';

class MainScreen extends StatefulWidget {
  final slider;
  final goToNotification;
  const MainScreen(this.slider, this.goToNotification);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int count = checkCount();
  bool isSubscribe = checkSubscribe();

  @override
  void initState() {
    Globals.updateChatCount = () {
      if(mounted)
        setState(() {
          count = checkCount();
        });
    };
    // Globals.updateVisitableSubscribe = () {
    //   if(mounted)
    //     setState(() {
    //       isSubscribe = checkSubscribe();
    //     });
    // };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: CustomBehavior(),
      child: Column(
        children: [
          widget.slider,
          getServices(),
        ],
      ),
    );
  }

  Widget getServices() {

    List<Widget> items = [];

    items.add(createServices("checklist", 35, () {
      UserManager.currentUser("id").isNotEmpty
          ? Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'Orders'), builder: (_) => Orders()))
          : goLogin();
    }));

    items.add(createServices("chat", 36, () {
      UserManager.currentUser("id").isNotEmpty
          ? Navigator.push(context, MaterialPageRoute(builder: (_) => Conversations()))
          : goLogin();
    }));



    // if(isSubscribe)
      items.add(createServices("info", 40, () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => UserManager.isSubscribe()? Subscription() : FeatureSubscribe()));
      }));
    // else
    //   items.add(createServices("bell", 45, () { // الإشعارات
    //     widget.goToNotification();
    //   }));

    Globals.getSetting('show_favourite_services') == 'false' ? Container() :
    items.add(createServices("sharing", 39, () {
      UserManager.currentUser("id").isNotEmpty
          ? Navigator.push(context, MaterialPageRoute(builder: (_) => UserFavoriteServices()))
      : goLogin();
    })); // الخدمات المفضلة

    Globals.getSetting('show_record_as_provider') == 'false' ? Container() :
    items.add(createServices(FlutterIcons.server_fea, 61, () { // سجل كمزود خدمة
      Navigator.push(context, MaterialPageRoute(builder: (_) => JoinRequest()));
    }));

    items.add(createServices(FlutterIcons.share_fea, 64, () { // شارك التطبيق
      Alert.show(context,
          Container(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        LanguageManager.getText(64),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    getShearinIcons(),
                  ])),
          type: AlertType.WIDGET);
    }));

    // items.add(createServices("product", 37, () {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (_) => UserProducts()));
    // }));
    // items.add(createServices("star", 38, () {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (_) => UserFavoritProducts()));
    // }));


    items.add(Container(
      height: 10,
    ));
    return Expanded(
      child: ScrollConfiguration(
          behavior: CustomBehavior(),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            children: items,
          )),
    );
  }

    void goLogin() {
    Alert.show(context, LanguageManager.getText(298),
        premieryText: LanguageManager.getText(30),
        onYes: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
        }, onYesShowSecondBtn: false);
  }

  Widget createServices(icon, titel, onTap) {
    print('here_count: $count');
    var width = MediaQuery.of(context).size.width * 0.9;
    // if (width > 400) width = 400;
    double height = 70;
    return Container(
      margin: EdgeInsets.only(top: 12),
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          width: width,
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Container(
                width: 10,
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Center(
                    child: Container(
                      width: height * 0.8,
                      height: height * 0.8,
                      alignment: Alignment.center,
                      child: icon.runtimeType == String
                      ? SvgPicture.asset(
                        "assets/icons/$icon.svg",
                        width: height * 0.4,
                        height: height * 0.4,
                        color: Converter.hexToColor("#344f64"),
                      )
                      :Icon(
                        icon,
                        color: Converter.hexToColor("#344f64"),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Converter.hexToColor("#F2F2F2")),
                    ),
                  ),
                  count > 0 && titel == 36
                      ? Container(
                    margin: EdgeInsets.only(top: 3),
                          alignment: Alignment.center,
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.red),
                            child: Text(
                              count > 99 ? '+99' : count.toString(),
                              style: TextStyle(fontSize: 7, color: Colors.white,fontWeight: FontWeight.w900 ),
                              textAlign: TextAlign.center,),
                            )
                      : Container(),
                ],
              ),
              Container(
                width: 20,
              ),
              Expanded(
                child: Text(
                  LanguageManager.getText(titel),
                  textAlign: LanguageManager.getDirection()
                      ? TextAlign.right
                      : TextAlign.left,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Converter.hexToColor("#707070")),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(20),
                    offset: Offset(0, 2),
                    blurRadius: 1,
                    spreadRadius: 1)
              ]),
        ),
      ),
    );
  }

  Widget getShearinIcons() {
    List<Widget> shearIcons = [];
    if (Globals.getConfig("sharing") != "")
      for (var item in Globals.getConfig("sharing")) {
        shearIcons.add(GestureDetector(
          onTap: () async {
            launch(Uri.encodeFull(item['url']));
          },
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: CachedNetworkImageProvider(Globals.correctLink(item["icon"])))),
          ),
        ));
      }
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: shearIcons,
      ),
    );
  }

  static bool checkSubscribe() {
    return Globals.getSetting('active_subscribe') == '1' && UserManager.currentUser('id').isNotEmpty && UserManager.isSubscribe();
  }

  static int checkCount() {
    return UserManager.currentUser('chat_not_seen').isNotEmpty? int.parse(UserManager.currentUser('chat_not_seen')) : 0;
  }
}
