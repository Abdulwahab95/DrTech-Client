import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider();

  @override
  _HomeSliderState createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  ScrollController controller = ScrollController();
  @override
  void initState() {
    tick();
    super.initState();
  }

  void tick() {
    var slides = Globals.getConfig("slider");
    if (slides == "") return;
    Timer(Duration(seconds: 5), () {
      if (!mounted) return;
      var current = controller.offset;
      if (current == controller.position.maxScrollExtent) {
        controller.animateTo(0,
            duration: Duration(milliseconds: 450), curve: Curves.easeInOut);
      } else {
        controller.animateTo(current + MediaQuery.of(context).size.width,
            duration: Duration(milliseconds: 450), curve: Curves.easeInOut);
      }
      tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return getSlider();
  }

  Widget getSlider() {
    var width = MediaQuery.of(context).size.width;
    var height = width * 0.45;
    List<Widget> items = [];
    var slides = Globals.getConfig("slider");
    if (slides != "")
      for (var item in slides) {
        items.add(Stack(
          children: [
            Container(
              width: width - 10,
              height: height,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
            ),
            item['visitableBtn'] == true? Align(
                alignment: Alignment.bottomLeft,
                child: InkWell(
                  onTap: () => _launchURL(item['url']),
                  child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(color: Converter.hexToColor('#344f64') , borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))),
                    margin: EdgeInsets.only(bottom: 20, left: 5),
                    child: Row(
                      children: [
                        Text(Globals.isRtl()? item['text']: item['text_en'] , style: TextStyle(color: Colors.white)), // 'اتصل بالمعلن'
                        Container(width: 5, height: 30),
                        Icon(
                          IconsMap.from[item['icon']],
                          color: Colors.grey,
                          size: 15,)
                      ],
                    ),
                  ),
                ))
                :Container()
          ],
        ));
      }
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView(
          controller: controller,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          children: items,
        ),
      ),
    );
  }

  Future<void> _launchURL(_url) async {
    await launch(_url);
  }

}
