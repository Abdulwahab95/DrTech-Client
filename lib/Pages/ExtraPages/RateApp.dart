import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/RateStars.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RateApp extends StatefulWidget {
  const RateApp();

  @override
  _RateAppState createState() => _RateAppState();
}

class _RateAppState extends State<RateApp> {
  Map<String, String> body = {'stars':'5'};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TitleBar((){Navigator.pop(context);}, 65, without: true),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            alignment: Alignment.center,
            child: Text(
              LanguageManager.getText(67),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Converter.hexToColor("#8D8C8E")),
            ),
          ),
          RateStars(30, spacing: 0.5, stars: 5,onUpdate: (stars) {
            body["stars"] = stars.toString();
          }),
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(20),
                      offset: Offset(0, 4),
                      spreadRadius: 1,
                      blurRadius: 5)
                ],
                color: Colors.white),
            child: TextField(
              onChanged: (t) {
                body["comment"] = t;
              },
              textDirection: LanguageManager.getTextDirection(), // 'صف لنا تجربتك (إختيارية)'
              decoration: InputDecoration(border: InputBorder.none, hintText: LanguageManager.getText(291), hintTextDirection: LanguageManager.getTextDirection()),
              maxLines: 4,
            ),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: send,
              child: Container(
                width: 320,
                height: 56,
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  LanguageManager.getText(70),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Converter.hexToColor("#344F64")),
              ),
            ),
          ))
        ],
      ),
    );
  }

  void send() {
    if (body["stars"] == null) {
      Alert.show(context, LanguageManager.getText(69));
      return;
    }

    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "application/rate/create", context ,(r) { // user/app
      if (r['state'] == true) {
        Alert.endLoading();
        Navigator.pop(context);
        Alert.show(
            context,
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LanguageManager.getText(71),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  Container(
                    height: 15,
                  ),
                  Text(
                    LanguageManager.getText(72),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  getShearinIcons(),
                ],
              ),
            ),
            type: AlertType.WIDGET);
      }
    }, body: body);
  }

  Widget getShearinIcons() {
    List<Widget> shearIcons = [];
    if (Globals.getConfig("sharing") != "")
      for (var item in Globals.getConfig("sharing")) {
        shearIcons.add(GestureDetector(
          onTap: () async {
            await launch(Uri.encodeFull(item['url'])) ;
            // void _launchURL() async =>
            // item['url']= 'https://api.whatsapp.com/';
            //     await canLaunch(item['url']) ? await launch(item['url']) : throw 'Could not launch ${item['url']}';
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
}
