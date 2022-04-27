import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/AddProduct.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class UserProducts extends StatefulWidget {
  @override
  _UserProductsState createState() => _UserProductsState();
}

class _UserProductsState extends State<UserProducts> {
  Map<int, List> data = {};
  int page = 0;
  bool isLoading;
  var opendOptions;

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    setState(() {isLoading = true;});

    NetworkManager.httpGet(
        Globals.baseUrl + "product/load?page=$page&type=user", context, (r) {

      if (r['state'] == true) {

        if(data.isNotEmpty) {
          var exist = false;
          for (var v in data.values) {
            if (v.toString() == r['data'].toString())
              {
                exist = true;
              }
            print('heree: exist: $exist');
            print('heree: v: $v');
            print('heree: r[\'data\']: ${r['data']}');
            //below is the solution
          }
          if(!exist)
            setState(() {
              page++;
              data[r['page']] = r['data'];
            });
        } else
        setState(() {
          print('heree: first time');
          page++;
          data[r['page']] = r['data'];
        });
        setState(() {isLoading = false;});
      }
    }, cashable: true);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TitleBar(() {Navigator.pop(context);}, 37),
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
    } else if (items.length > 0 && data[0].length == 0 && !isLoading) {
      return EmptyPage("conversation.svg", 97);
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

  Widget createProductItem(item, page, index) {
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
      child: Stack(
        children: [
          Row(
            textDirection: LanguageManager.getTextDirection(),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                textDirection: LanguageManager.getTextDirection(),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: size,
                    height: size,
                    margin: EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 30,
                      width: 70,
                      margin: EdgeInsets.only(top: 5),
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(
                            item['active'] == true ? 167 : 168),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          color: Converter.hexToColor(
                              item['active'] == true ? "#2094CD" : "#FF0000"),
                          borderRadius: LanguageManager.getDirection()
                              ? BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))
                              : BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15))),
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                CachedNetworkImageProvider(Globals.correctLink(item['images'][0]))),
                        borderRadius: BorderRadius.circular(7),
                        color: Converter.hexToColor("#F2F2F2")),
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              opendOptions = item["id"];
                            });
                          },
                          child: Icon(
                            FlutterIcons.dots_vertical_mco,
                            size: 26,
                            color: Converter.hexToColor("#707070"),
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            textDirection: LanguageManager.getTextDirection(),
                            children: [
                              Text(
                                item["price"].toString(),
                                textDirection:
                                    LanguageManager.getTextDirection(),
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
                                textDirection:
                                    LanguageManager.getTextDirection(),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Converter.hexToColor("#2094CD")),
                              )
                            ],
                          ),
                          padding: EdgeInsets.only(
                              top: 2, bottom: 2, right: 10, left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Converter.hexToColor("#F2F2F2")),
                        )
                      ],
                    ),
                    Wrap(
                      textDirection: LanguageManager.getTextDirection(),
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        createInfoIcon(FlutterIcons.md_color_palette_ion,
                            item['color'].toString()),
                        createInfoIcon(
                          FlutterIcons.smartphone_fea,
                          LanguageManager.getText(
                              item['status'] == 'USED' ? 143 : 142),
                        ),
                        createInfoIcon(FlutterIcons.location_on_mdi,
                            item['location'].toString()),
                      ],
                    ),
                    Container(
                      height: 15,
                    ),
                  ],
                ),
              )
            ],
          ),
          opendOptions != item["id"]
              ? Container()
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      opendOptions = null;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: size,
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.all(7),
                      width: 140,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                opendOptions = null;
                              });
                              editProduct(item['id']);
                            },
                            child: Row(
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Icon(
                                  FlutterIcons.pencil_ent,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                Container(
                                  width: 10,
                                ),
                                Text(
                                  LanguageManager.getText(170),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            height: 1,
                            color: Colors.grey,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                opendOptions = null;
                              });
                              deleteProduct(item['id'], page, index);
                            },
                            child: Row(
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Icon(
                                  FlutterIcons.trash_faw,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                Container(
                                  width: 10,
                                ),
                                Text(
                                  LanguageManager.getText(169),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(20),
                                spreadRadius: 2,
                                blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: Converter.hexToColor("#F2F2F2")),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget createInfoIcon(icon, text) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 0),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Converter.hexToColor("#C4C4C4"),
            size: 20,
          ),
          Container(
            width: 2,
          ),
          Text(
            text,
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 16,
                color: Converter.hexToColor("#707070"),
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  void editProduct(id) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddProduct(id: id)));
  }

  void deleteProduct(id, page, index) {
    Alert.show(
        context,
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      FlutterIcons.x_fea,
                      size: 24,
                    ),
                  )
                ],
              ),
              Container(
                child: Icon(
                  FlutterIcons.trash_faw,
                  size: 50,
                  color: Converter.hexToColor("#707070"),
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                LanguageManager.getText(171),
                style: TextStyle(
                    color: Converter.hexToColor("#707070"),
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 30,
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      deleteProductConferm(id, page, index);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(169),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(15),
                                spreadRadius: 2,
                                blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Converter.hexToColor("#FF0000")),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Alert.publicClose();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(172),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                  )
                ],
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  void deleteProductConferm(id, page, i) {
    Alert.startLoading(context);
    Map<String, String> body = {"id": id.toString()};
    NetworkManager.httpPost(Globals.baseUrl + "product/delete", context ,(r) {
      if (r['state'] == true) {
        Alert.endLoading();
        setState(() {
          data[page].removeAt(i);
        });
      }
    }, body: body);
  }
}
