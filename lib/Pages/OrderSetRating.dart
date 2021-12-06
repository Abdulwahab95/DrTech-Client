import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/RateStars.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSetRating extends StatefulWidget {
  final id;
  const OrderSetRating(this.id);

  @override
  _OrderSetRatingState createState() => _OrderSetRatingState();
}

class _OrderSetRatingState extends State<OrderSetRating> {
  Map<String, String> body = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            textDirection: LanguageManager.getTextDirection(),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleBar(() {Navigator.pop(context);}, 183),
              Expanded(
                child: ScrollConfiguration(
                  behavior: CustomBehavior(),
                  child: ListView(
                    children: [
                      Container(
                        height: 40,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Text(
                              LanguageManager.getText(232),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            RateStars(
                              20,
                              onUpdate: (r) {
                                body["exp"] = r.toString();
                              },
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Text(
                              LanguageManager.getText(233),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            RateStars(
                              20,
                              onUpdate: (r) {
                                body["pref"] = r.toString();
                              },
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Text(
                              LanguageManager.getText(234),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            RateStars(
                              20,
                              onUpdate: (r) {
                                body["time"] = r.toString();
                              },
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                        padding: EdgeInsets.only(left: 7, right: 7),
                        decoration: BoxDecoration(
                            color: Converter.hexToColor("#F2F2F2"),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          onChanged: (t) {
                            body["content"] = t.toString();
                          },
                          keyboardType: TextInputType.text,
                          maxLines: 4,
                          textDirection: LanguageManager.getTextDirection(),
                          decoration: InputDecoration(
                              hintText: "",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              hintTextDirection:
                                  LanguageManager.getTextDirection(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0)),
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            sendRating();
                          },
                          child: Container(
                            width: 200,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Converter.hexToColor("#344F64"),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              LanguageManager.getText(235),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]));
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

  void sendRating() {
    if (body["exp"] == null || body["pref"] == null || body["time"] == null) {
      Alert.show(context, LanguageManager.getText(236));
      return;
    }
    try{
      body["rate"] =
          ((int.parse(body["exp"] ) +
            int.parse(body["pref"]) +
            int.parse(body["time"]) ) / 3)
              .toString();
    }catch(e){
      body["rate"] = body["exp"];
      print('ratings_create_error: $e');
    }
    body["order_id"] = widget.id.toString();
    body["rated_by"] = UserManager.currentUser("id");
    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "ratings/create", context ,(r) { // orders/rate
      Alert.endLoading();
      if (r['state'] == true) {
        Navigator.of(context).pop(true);
      }
    }, body: body);
  }
}
