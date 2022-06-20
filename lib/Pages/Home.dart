import 'dart:async';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/HomeSlider.dart';
import 'package:dr_tech/Components/NavBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Screens/MainScreen.dart';
import 'package:dr_tech/Screens/NotificationsScreen.dart';
import 'package:dr_tech/Screens/ProfileScreen.dart';
import 'package:dr_tech/Screens/ServicesScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'FeatureSubscribe.dart';
import 'Store.dart';

class Home extends StatefulWidget {
  final page;
  const Home({this.page});

  @override
  State<Home> createState() =>  _HomeState();
}

class _HomeState extends State<Home> {
  String nameUserTxt = UserManager.currentUser("username").split(" ")[0];
  int iScreenIndex = 0;
  bool isOpenMessage = false;
  Map<String, String> body = {};

  HomeSlider homeSlider = HomeSlider();
  @override
  void initState() {

    if (widget.page != null) iScreenIndex = widget.page;

    if(
        Globals.getSetting('active_subscribe') == '1' &&
        UserManager.currentUser('id').isNotEmpty &&
        !UserManager.isSubscribe()
    )
        Timer(Duration(seconds: 3), () {
          setState(() {
            isOpenMessage = true;
          });
        });

      Globals.updateVisitableWhySubscribe = (){
        if(mounted)
          Future.delayed(Duration.zero, () {
            setState(() {
              isOpenMessage = false;
            });
          });
      };

    // Timer(Duration(seconds: 10), () {
    //   setState(() {
    //     isOpenMessage = false;
    //   });
    // });
    if (UserManager.currentUser("id").isNotEmpty &&
        (UserManager.currentUser("username") == "" || UserManager.currentUser("email") == "")) {
      Timer(Duration(milliseconds: 200), () {
        Alert.show(
            context,
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserManager.currentUser("username") == "" ?
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Converter.hexToColor("#F2F2F2")),
                    child: TextField(
                      onChanged: (r) {
                        body['username'] = r;
                      },
                      textDirection: LanguageManager.getTextDirection(),
                      textAlign: LanguageManager.getDirection()
                          ? TextAlign.right
                          : TextAlign.left,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: LanguageManager.getText(33)),
                    ),
                  ):Container(),
                  UserManager.currentUser("username") == "" ?Container(height: 15):Container(),
                  UserManager.currentUser("email") == "" ?
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Converter.hexToColor("#F2F2F2")),
                    child: TextField(
                      onChanged: (r) {
                        body['email'] = r;
                      },
                      textDirection: LanguageManager.getTextDirection(),
                      textAlign: LanguageManager.getDirection()
                          ? TextAlign.right
                          : TextAlign.left,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: LanguageManager.getText(282)),
                    ),
                  ):Container(),
                  Container(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      if (UserManager.currentUser("username") == ""  && (body['username'] == null || (body['username'] != null && body['username'].length < 3))) return;
                      if (UserManager.currentUser("email") == ""  &&  (body['email'] == null || (body['email'] != null && body['email'].length < 3))) return;
                      // Navigator.pop(context);
                      Alert.startLoading(context);
                      UserManager.update("username", body['username'], context ,(status) {
                        // DatabaseManager.save("name", name);
                        Alert.endLoading();
                        if (status == true) {
                          Navigator.pop(context);
                          DatabaseManager.save("username", body['username']);
                          DatabaseManager.save("email", body['email']);
                          setState(() {
                            nameUserTxt = body['username'].split(" ")[0];
                          });
                        }
                      }, mapBody: body);
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(34),
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
                  ),
                ],
              ),
            ),
            type: AlertType.WIDGET, isDismissible: false);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    Globals.updateVisitableWhySubscribe = (){};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          iScreenIndex == 2 ? Container() :
          Container(
            decoration: BoxDecoration(color: Converter.hexToColor("#2094cd")),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding:
              EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 25),
              child:
              iScreenIndex != 0 ?
              Text(
                LanguageManager.getText([43, 35, 451, 45, 46][iScreenIndex]),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
                  : Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          (Globals.isPM()
                                  ? LanguageManager.getText(292)
                                  : LanguageManager.getText(32)) +
                              (nameUserTxt.length > 0 ? " - " : '') + nameUserTxt,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                  // InkWell(
                  //   onTap: () {
                  //     var cities = DatabaseManager.liveDatabase['country_cities'];
                  //     if (cities == null || cities == "") return;
                  //     for (var i = 0; i < cities.length; i++) {
                  //       cities[i]['text'] = cities[i]['name'];
                  //     }
                  //     Alert.show(context, cities,
                  //         type: AlertType.SELECT, onSelected: (item) {
                  //           DatabaseManager.liveDatabase["city"] = item;
                  //         });
                  //   },
                  //   child: Row(
                  //     textDirection:
                  //     LanguageManager.getTextDirection(),
                  //     children: [
                  //       Icon(
                  //         FlutterIcons.location_on_mdi,
                  //         size: 18,
                  //         color: Colors.white,
                  //       ),
                  //       Container(
                  //         width: 5,
                  //       ),
                  //       Text(
                  //         DatabaseManager.liveDatabase["city"] != null
                  //             ? DatabaseManager.liveDatabase["city"]
                  //         ["username"]
                  //             .toString()
                  //             : "",
                  //         style: TextStyle(
                  //             fontSize: 14, color: Colors.white),
                  //       ),
                  //       Container(
                  //         width: 5,
                  //       ),
                  //       Icon(
                  //         FlutterIcons.chevron_down_ent,
                  //         size: 18,
                  //         color: Colors.white,
                  //       )
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          Expanded(
              child: [
                ServicesScreen(homeSlider),
                MainScreen(homeSlider, (){
                  setState(() {
                    iScreenIndex = 2;
                  });
                }),
                Store(),
                NotificationsScreen(),
                ProfileScreen(() {
                  setState(() {});
                })
              ][iScreenIndex]),
          AnimatedContainer(
              duration: Duration(milliseconds: 250),
              height: isOpenMessage ? 50 : 0,
              decoration:
              BoxDecoration(color: Converter.hexToColor("#707070")),
              child: ScrollConfiguration(
                  behavior: ScrollBehavior(),
                  child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            textDirection: LanguageManager.getTextDirection(),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                LanguageManager.getText(41),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              InkWell(
                                onTap: () async{
                                  var results = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => FeatureSubscribe()));
                                  if(results.toString().contains('success'))
                                    setState(() {
                                      isOpenMessage = false;
                                    });
                                },
                                child: Text(
                                  LanguageManager.getText(42),
                                  style: TextStyle(
                                      color: Converter.hexToColor("#DBE208"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isOpenMessage = false;
                                  });
                                },
                                child: Icon(
                                  FlutterIcons.close_ant,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              )
                            ]),
                      )))),
          Container(
            alignment: Alignment.bottomCenter,
            color: Colors.transparent,
            child: NavBar(onUpdate: (index) {
              setState(() {
                iScreenIndex = index;
              });
            }, page: iScreenIndex),
          )
          // Container(
          //   height: 70,
          //   color: Colors.transparent,
          // )
        ],
      ),
    );
  }
}
