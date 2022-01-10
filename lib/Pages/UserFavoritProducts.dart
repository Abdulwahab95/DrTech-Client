import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class UserFavoritProducts extends StatefulWidget {
  @override
  _UserFavoritProductsState createState() => _UserFavoritProductsState();
}

class _UserFavoritProductsState extends State<UserFavoritProducts> {
  Map<int, List> data = {};
  int page = 0;
  bool isLoading;

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(
        Globals.baseUrl + "product/load?page=$page&type=favorit", context, (r) {
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          page++;
          data[r['page']] = r['data'];
        });
      }
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TitleBar(() {Navigator.pop(context);}, 38),
          Expanded(
            child: getProducts(),
          )
        ],
      ),
    );
  }

  Widget getProducts() {
    List<Widget> items = [];
    for (var page in data.keys) {
      for (var i = 0; i < data[page].length; i++) {
        var item = data[page][i];
        items.add(createProductItem(item, page, i));
      }
    }

    if (items.length == 0 && isLoading) {
      return Container(
        alignment: Alignment.center,
        child: CustomLoading(),
      );
    } else if (items.length == 0 && data[0].length == 0 && !isLoading) {
      return EmptyPage("Loving", 166);
    }

    return Recycler(
      children: items,
      onScrollDown: () {
        if (!isLoading) {
          if (data.length > 0 && data[0].length == 0) return;
          load();
        }
      },
    );
  }

  Widget createProductItem(item, page, i) {
    double size = 120;
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 0),
      padding: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                color: Colors.black.withAlpha(20),
                spreadRadius: 2,
                blurRadius: 4)
          ]),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(Globals.correctLink(item['images'][0]))),
                    borderRadius: BorderRadius.circular(7),
                    color: Converter.hexToColor("#F2F2F2")),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    item['isLiked'] = item['isLiked'] != true ? true : false;
                  });
                  NetworkManager.httpGet(
                      Globals.baseUrl + "product/like?product_id=" + item["id"], context, (r) {
                    if (r['state'] == true) {
                      setState(() {
                        data[page].removeAt(i);
                      });
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: Icon(FlutterIcons.heart_ant,
                      size: 24,
                      color:
                          item['isLiked'] != true ? Colors.grey : Colors.red),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              textDirection: LanguageManager.getTextDirection(),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Expanded(
                      child: Text(
                        item["name"].toString(),
                        textDirection: LanguageManager.getTextDirection(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Converter.hexToColor("#2094CD")),
                      ),
                    ),
                    Container(
                      width: 5,
                    ),
                    Container(
                      height: 30,
                      width: 70,
                      margin: EdgeInsets.only(top: 5),
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(
                            item['status'] == 'USED' ? 143 : 142),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                      ),
                      decoration: BoxDecoration(
                          color: Converter.hexToColor("#2094CD"),
                          borderRadius: LanguageManager.getDirection()
                              ? BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))
                              : BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                    )
                  ],
                ),
                Container(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      item['color'],
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Converter.hexToColor("#4c4c4c")),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        textDirection: LanguageManager.getTextDirection(),
                        children: [
                          Text(
                            item["price"].toString(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Converter.hexToColor("#2094CD")),
                          ),
                          Container(
                            width: 5,
                          ),
                          Text(
                            Globals.getUnit(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Converter.hexToColor("#2094CD")),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Icon(
                      FlutterIcons.location_on_mdi,
                      color: Converter.hexToColor("#C4C4C4"),
                      size: 20,
                    ),
                    Container(
                      width: 7,
                    ),
                    Text(
                      item['location'].toString(),
                      style: TextStyle(
                          color: Converter.hexToColor("#707070"),
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                      textDirection: LanguageManager.getTextDirection(),
                    )
                  ],
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Icon(
                      Icons.person,
                      color: Converter.hexToColor("#C4C4C4"),
                      size: 20,
                    ),
                    Container(
                      width: 7,
                    ),
                    Text(
                      item['user']['name'].toString(),
                      style: TextStyle(
                          color: Converter.hexToColor("#707070"),
                          fontWeight: FontWeight.normal,
                          fontSize: 14),
                      textDirection: LanguageManager.getTextDirection(),
                    )
                  ],
                ),
                Container(
                  height: 7,
                ),
                Container(
                  padding: EdgeInsets.all(7),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            height: 35,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Icon(
                                  FlutterIcons.phone_faw,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                Container(
                                  width: 5,
                                ),
                                Text(
                                  LanguageManager.getText(96),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      spreadRadius: 2,
                                      blurRadius: 2)
                                ],
                                borderRadius: BorderRadius.circular(12),
                                color: Converter.hexToColor("#344f64")),
                          ),
                        ),
                      ),
                      Container(
                        width: 5,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            height: 35,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Icon(
                                  Icons.chat,
                                  color: Converter.hexToColor("#344f64"),
                                  size: 18,
                                ),
                                Container(
                                  width: 5,
                                ),
                                Text(
                                  LanguageManager.getText(117),
                                  style: TextStyle(
                                      color: Converter.hexToColor("#344f64"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      spreadRadius: 2,
                                      blurRadius: 2)
                                ],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Converter.hexToColor("#344f64"))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
