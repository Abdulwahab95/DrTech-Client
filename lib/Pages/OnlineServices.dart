import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/NotificationIcon.dart';
import 'package:dr_tech/Components/SoonWidget.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/OnlineEngineerServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class OnlineServices extends StatefulWidget {
  const OnlineServices();

  @override
  _OnlineServicesState createState() => _OnlineServicesState();
}

class _OnlineServicesState extends State<OnlineServices> with WidgetsBindingObserver{
  bool isLoading = false;
  String search = "";
  List data = [];
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    load();
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
      print('here_resumed_from: OnlineServices');
      load();
    }
  }

  void load() {
    setState(() {
      isLoading = true;
    });

    NetworkManager.httpGet(
        Globals.baseUrl + "service/categories/6", context, (r) { // /services/loadSubCatigories?search=$search
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
        });
      }
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          Container(
              decoration: BoxDecoration(color: Converter.hexToColor("#2094cd")),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.only(left: 25, right: 25, bottom: 15, top: 30),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            LanguageManager.getDirection()
                                ? FlutterIcons.chevron_right_fea
                                : FlutterIcons.chevron_left_fea,
                            color: Colors.white,
                            size: 26,
                          )),
                      Text(
                        LanguageManager.getText(273),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      NotificationIcon(),
                    ],
                  ))),
          // getSearch(),
          Expanded(
              child: isLoading ? Center(child: CustomLoading()) : getBody())
        ]));
  }

  Widget getSearch() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
          color: Converter.hexToColor("#F2F2F2"),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Expanded(
            child: TextField(
              onSubmitted: (t) {
                search = t;
                load();
              },
              textDirection: LanguageManager.getTextDirection(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  hintText: LanguageManager.getText(102),
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  hintTextDirection: LanguageManager.getTextDirection(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
            ),
          ),
          Container(
            child: Icon(
              FlutterIcons.search_fea,
              size: 20,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget getBody() {
    if(data.isEmpty) return SoonWidget();

    List<Widget> items = [];

    for (var item in data) {
      items.add(
      SplashEffect(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => OnlineEngineerServices(item['id'], item['name'])));
        },
        showShadow: false,
        radius: 10,
        child: Container(
          //height: MediaQuery.of(context).size.width * 0.46,
          margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 2),
                    color: Colors.black.withAlpha(20),
                    spreadRadius: 2,
                    blurRadius: 2)
              ],
              image: DecorationImage(
                  fit: BoxFit.cover,
                  // colorFilter: ColorFilter.mode(Colors.white, BlendMode.darken),
                  image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
          child: Text(
            item["name"],
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.transparent),//Converter.hexToColor("#2094CD")
          ),
        ),
      ));
    }

    return Directionality(
      textDirection: LanguageManager.getTextDirection(),
      child: GridView.count(
        mainAxisSpacing: 15,
        childAspectRatio: MediaQuery.of(context).size.width > 800 ? 2.45 : 1.275 ,
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        crossAxisSpacing: 20,
        crossAxisCount: 2,
        children: items,
      ),
    );

  }
}