import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class FrequentlyAskedQuestions extends StatefulWidget {
  FrequentlyAskedQuestions();

  @override
  _FrequentlyAskedQuestionsState createState() =>
      _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> {
  bool isLoading = false;
  List data = [];

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "faq", context, (r) {//information/FrequentlyAskedQuestions
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            TitleBar((){Navigator.pop(context);}, 62, withoutBell: true),
            Expanded(child: Container(child: isLoading ? Center(child: CustomLoading(),) : getBodyContents())),
          ],
        ));
  }

  Widget getBodyContents() {
    List<Widget> items = [];

    for (var item in data) {
      items.add(createItem(item));
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 0),
      children: items,
    );
  }

  Widget createItem(item) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        textDirection: LanguageManager.getTextDirection(),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 2,
                      spreadRadius: 2)
                ]),
            child: InkWell(
              onTap: () {
                setState(() {
                  item['opened'] = item['opened'] == true ? false : true;
                });
              },
              child: Row(
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Expanded(
                    child: Text(
                      item['title'],
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          fontSize: 16,
                          color: Converter.hexToColor("#2094CD"),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    item['opened'] == true
                        ? FlutterIcons.chevron_up_fea
                        : FlutterIcons.chevron_down_fea,
                    size: 24,
                  )
                ],
              ),
            ),
          ),
          item['opened'] == true
              ? Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    item['content'],
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        fontSize: 14,
                        color: Converter.hexToColor("#727272"),
                        fontWeight: FontWeight.bold),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
