import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/popup_menu.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider();

  @override
  _HomeSliderState createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {

  ScrollController controller = ScrollController();
  List<PopupMenu> menus = [];
  List<GlobalKey> btnKeyList = [];

  @override
  void initState() {
    PopupMenu.context = context;
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
    var height = width * (MediaQuery.of(context).size.width > 800 ? 0.30 : 0.45);
    List<Widget> items = [];
    var slides = Globals.getConfig("slider");
    if (slides != "")
      for (var item in slides) {

        btnKeyList.add(GlobalKey());
        List<MenuItem> menuItems = [];
        for (var slidesUrlsItem in item['urls'])
          {
            print('here_slidesUrlsItem: $slidesUrlsItem');
            menuItems.add(MenuItem(
              title: slidesUrlsItem[LanguageManager.getDirection() ? 'text' : 'text_en'],
              image: slidesUrlsItem['icon_name_or_url'].toString().contains('/')
                  ? getIcon(slidesUrlsItem)
                  : Icon(
                        IconsMap.from[slidesUrlsItem['icon_name_or_url']],
                        color: Converter.hexToColor(slidesUrlsItem['icon_color']?? '#9E9E9E'),
                        size: 19),
              item: slidesUrlsItem,
            ));
        }
        print('here_menuItems: ${menuItems.length}');
        if(menuItems.isNotEmpty)
          menus.add(PopupMenu(
            items: menuItems,
            backgroundColor: Converter.hexToColor("#344f64"),
            onClickMenu: (MenuItemProvider itemProvider) async {
              print('Click menu -> ${itemProvider.menuTitle}, ${itemProvider.menuItem}');
              await _launchURL(Uri.encodeFull(itemProvider.menuItem['url']));
            },
          ));

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
            menus.isNotEmpty ? Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                      decoration: BoxDecoration(color: Converter.hexToColor(
                          item['btn_color'] ?? '#344f64'),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: item['btn_shadow_white_or_black'].toString() == '0' ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                          //     spreadRadius: 1,
                          //     blurRadius: 7,
                          //     offset: Offset(1, 1), // changes position of shadow
                          //   ),
                          // ],
                      ),
                      margin: EdgeInsets.only(bottom: 20, left: 5),
                      child:Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                        onTap: () async {
                          print('here_onTap: menus. ${menus.length}');
                          if(item['urls'].length > 1)
                              menus[menus.length > 0
                                  ? menus.length - 1
                                  : menus.length].show(
                                  widgetKey: btnKeyList[btnKeyList.length > 0
                                      ? btnKeyList.length - 1
                                      : btnKeyList.length]);
                          else if(menus.length == 1)
                            await _launchURL(Uri.encodeFull(item['urls'][0]['url']));

                        },
                        // onTap: () => (menuItems.length > 1 && item['id'].toString() == item['urls'][0]['id'].toString() ) ? menus[menuItems.length].show(widgetKey: btnKeyList[menuItems.length]) : _launchURL(item['url']),
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          key: btnKeyList[btnKeyList.length > 0 ? btnKeyList.length - 1: btnKeyList.length],
                          child: Row(
                              children: [
                                Text(Globals.isRtl()? item['text']: item['text_en'] , style: TextStyle(color: Converter.hexToColor(item['text_color']?? '#ffffff'))), // 'اتصل بالمعلن'
                                Container(width: 5, height: 30),
                                Icon(
                                  IconsMap.from[item['icon']],
                                  color: Converter.hexToColor(item['icon_color']?? '#9E9E9E'),
                                  size: 15,)
                              ],
                            ),
                        ),),
                        )
                    ),
                  )
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


  static getIcon(slidesUrlsItem) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.contain,
              image: CachedNetworkImageProvider(Globals.correctLink(slidesUrlsItem['icon_name_or_url'])))),
    );
  }

}
