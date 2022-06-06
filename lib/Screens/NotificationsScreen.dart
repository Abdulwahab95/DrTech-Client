import 'package:dr_tech/Components/BrokenPage.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';

import '../Models/DatabaseManager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen();

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Widget ui;
  bool isLoading = false;
  int page = 0;
  Map<int, List> data = {};

  @override
  void initState() {
    Globals.reloadPageNotificationLive = (){
      if(mounted) load();
    };
    // print('here_NotificationsScreen: ${DatabaseManager.liveDatabase[Globals.authoKey]}');
    if(DatabaseManager.liveDatabase[Globals.authoKey] != null)
      load();
    super.initState();
  }

  void load() {
    if (isLoading == true) {
      return;
    }
    setState(() {
      ui = null;
      isLoading = true;
    });
    NetworkManager.httpPost(
        Globals.baseUrl + "notifications",  context, (r) { // "user/notifications?page=" + page.toString()
      setState(() {
        isLoading = false;
      });
      try {
        if (r['state'] == true) {
          // page++;
          data[0] = r['data']; // data[r['page']] = r['data'];
          seen();
        }
      } catch (e) {
        ui = BrokenPage(load);
      }
    });
  }

  void seen() {
    NetworkManager.httpPost(Globals.baseUrl + "notifications/seen",  context, (r) {
      setState(() {});
      if (r['state'] == true) {
        UserManager.updateSp('not_seen', 0);
        Globals.updateBottomBarNotificationCount();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (ui != null) return ui;
    if (isLoading && data.keys.length == 0)
      return Center(
        child: CustomLoading(),
      );
    return ScrollConfiguration(
        behavior: CustomBehavior(), child: getNotifications());
  }

  Widget getNotifications() {
    List<Widget> items = [];
    for (var page in data.keys) {
      for (var item in data[page]) {
        items.add(Container(
          child: Column(
            children: [
              Row(
                textDirection: LanguageManager.getTextDirection(),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    child: Icon(
                      IconsMap.from[item["icon"]],
                      size: 24,
                      color: Converter.hexToColor(item['icon_color']?? "#2094CD"),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    width: 10,
                  ),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        textDirection: LanguageManager.getTextDirection(),
                        children: [
                          Text(
                            Converter.getRealText(item[
                            LanguageManager.getDirection()
                                ? "title"
                                : item['title_en'].toString().toLowerCase() == 'null'? 'title' : "title_en"]),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Converter.hexToColor("#2094CD")),
                          ),
                          Text(
                            Converter.getRealText(item[
                            LanguageManager.getDirection()
                                ? "message"
                                : item['message_en'].toString().toLowerCase() == 'null'? 'message' : "message_en"]),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Converter.hexToColor("#707070")),
                          )
                        ],
                      )),
                  Container(
                    width: 10,
                  ),
                  Text(
                    Converter.getRealTime(item["created_at"]),
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Converter.hexToColor("#707070")),
                  )
                ],
              )
            ],
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(7),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(15),
                    offset: Offset(0, 2),
                    spreadRadius: 2,
                    blurRadius: 2)
              ]),
        ));
      }
    }

    if (items.length == 0) return EmptyPage("notifications", 54);

    if (isLoading) {
      items.add(Container(
        height: 70,
        child: CustomLoading(),
        alignment: Alignment.center,
      ));
    }
    return NotificationListener(
      onNotification: (n) {
        if (n is ScrollNotification) {
          if (n.metrics.pixels == n.metrics.maxScrollExtent) {
            // if (isLoading == false) load();
          }
        }
        return true;
      },
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 0),
        children: items,
      ),
    );
  }
}
