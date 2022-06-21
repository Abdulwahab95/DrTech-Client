import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/OnlineServices.dart';
import 'package:dr_tech/Pages/Service.dart';
import 'package:dr_tech/Screens/Store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServicesScreen extends StatefulWidget {
  final slider;
  const ServicesScreen(this.slider);

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: CustomBehavior(),
      child: Column(
        children: [
          widget.slider,
          Globals.showNotOriginal()
              ? Container(
                  padding: EdgeInsets.only(right: 15, left: 15, bottom: 0, top: 0),
                  child: Text(
                    Converter.getRealText(318),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                    textDirection: LanguageManager.getTextDirection(),
                  ),
                )
              :Container(),
          getServices(),
        ],
      ),
    );
  }

  Widget getServices() {
    var servicesApi = Globals.getConfig("services");
    if (servicesApi == "") return Container();
    List<Widget> newWidget = [];

    for (var item in servicesApi) {

      newWidget.add(createService(item["icon"], Globals.isRtl()? item["name"]: item["name_en"], () {
          if (item["target"].toString() == "store") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Store()));
            return;
          }
          if (item["target"].toString() == "online_services") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => OnlineServices()));
            return;
          }
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => Service(item['id'], Globals.isRtl()? item["name"]: item["name_en"])));
        }, () {Alert.show(context, item['description']);}));
    }

    return Expanded(
      child: Container(
          child: Directionality(
            textDirection: LanguageManager.getTextDirection(),
            child: GridView.count(
              mainAxisSpacing: 10,
              childAspectRatio: MediaQuery.of(context).size.width > 800 ? 2.45 : 1.45 ,
              primary: false,
              padding: const EdgeInsets.only(right: 10, left: 10),
              crossAxisSpacing: 10,
              crossAxisCount: 2,
              children: newWidget,
      ),
          )),
    );
  }

  Widget createService(icon, text, onTap, onInfo) {
    var size = MediaQuery.of(context).size.width * 0.4;
    if (size > 200) size = 200;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 10,
        height: 10,
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 5,
                  spreadRadius: 1)
            ],
            borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Column(
            children: [
              Center(
                child: Container(
                  width: size * 0.35,
                  height: size * 0.35,
                  alignment: Alignment.center,
                  child: icon.toString().toLowerCase().contains('svg')
                      ? SvgPicture.network(
                          icon,
                          width: size * 0.2,
                          height: size * 0.2,
                        )
                      : Container()
                  ,
                  decoration: BoxDecoration(
                      image: !icon.toString().toLowerCase().contains('svg')
                          ? DecorationImage(
                        fit: BoxFit.fill,
                              image: CachedNetworkImageProvider(
                                  Globals.correctLink(icon)))
                          : null,
                      color: Converter.hexToColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    Converter.getRealText(text),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,//14
                        color: Converter.hexToColor("#707070"),
                        fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: onInfo,
                    child: Text(
                      LanguageManager.getText(53),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: Converter.hexToColor("#707070"),
                          fontWeight: FontWeight.normal),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
