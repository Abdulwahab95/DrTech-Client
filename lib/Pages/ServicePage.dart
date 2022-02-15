import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/RateStars.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Components/phoneCall.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/ShareManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/EngineerRatings.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'Login.dart';

class ServicePage extends StatefulWidget {
  final id;
  ServicePage(this.id);

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>
    with TickerProviderStateMixin {
  bool isLoading;
  Map data = {};
  TabController controller;
  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "service/${widget.id}", context, (r) { // user/service?id=${widget.id}
      setState(() {
        isLoading = false;
      });
      if (r["state"] == true) {
        setState(() {
          data = r['data'];
          controller = new TabController(length: (data['images'] as String).split('||').length , vsync: this);
        });
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TitleBar(() {Navigator.pop(context);}, 265),
          Expanded(
              child: isLoading
                  ? Container(
                      child: CustomLoading(),
                      alignment: Alignment.center,
                    )
                  : SingleChildScrollView(
                      child: Column(
                        textDirection: LanguageManager.getTextDirection(),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getServiceInfo(),
                          Container(
                            height: 10,
                          ),
                          Row(
                            textDirection: LanguageManager.getTextDirection(),
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Text(
                                  data['name'].toString(),
                                  textDirection:
                                      LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ),
                              Row(
                                textDirection:
                                    LanguageManager.getTextDirection(),
                                children: [
                                  RateStars(
                                    14,
                                    stars: data['rate'],
                                  ),
                                  Container(
                                    width: 5,
                                  ),
                                  Text(
                                    Converter.format(data['rate']),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey),
                                  ),
                                  Container(
                                    width: 15,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Container(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              data['about'].toString(),
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Converter.hexToColor("#727272")),
                            ),
                          ),
                          Container(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              LanguageManager.getText(119),
                              textDirection:
                              LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          Container(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              //'هاني القحطاني فني جوالات خبرة ٤ سنوات لكل الأعطال يعمل مع شركة الحلول التنفيذية التجارية',
                              data['about_provider'].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Converter.hexToColor("#727272")),
                            ),
                          ),


                          Container(
                            height: 10,
                          ),
                          // Row(
                          //   textDirection: LanguageManager.getTextDirection(),
                          //   children: [
                          //     Container(
                          //       width: 10,
                          //     ),
                          //     Container(
                          //       height: 36,
                          //       width: 160,
                          //       child: Row(
                          //           textDirection:
                          //               LanguageManager.getTextDirection(),
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           children: [
                          //             Container(
                          //               margin: EdgeInsets.only(
                          //                   left: 10, right: 10),
                          //               child: Icon(
                          //                 FlutterIcons.tag_ant,
                          //                 color:
                          //                     Converter.hexToColor("#344F64"),
                          //                 size: 18,
                          //               ),
                          //             ),
                          //             Text(
                          //               LanguageManager.getText(141),
                          //               textDirection:
                          //                   LanguageManager.getTextDirection(),
                          //               textAlign: TextAlign.center,
                          //               style: TextStyle(
                          //                 fontWeight: FontWeight.w600,
                          //                 fontSize: 16,
                          //                 color:
                          //                     Converter.hexToColor("#344F64"),
                          //               ),
                          //             ),
                          //             Container(
                          //               width: 40,
                          //             )
                          //           ]),
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(15),
                          //         /*border: Border.all(
                          //               width: 1.6,
                          //               color: Converter.hexToColor("#344F64"))*/
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // data['offers'].length == 0
                          //     ? Container(
                          //         width:
                          //             MediaQuery.of(context).size.width * 0.9,
                          //         margin: EdgeInsets.all(10),
                          //         decoration: BoxDecoration(
                          //             border: Border.all(
                          //                 color: Colors.grey.withAlpha(50),
                          //                 width: 1),
                          //             borderRadius: BorderRadius.circular(15)),
                          //         padding: EdgeInsets.all(25),
                          //         child: Text(
                          //           LanguageManager.getText(267),
                          //           textAlign: TextAlign.center,
                          //         ),
                          //       )
                          //     : Container(
                          //         child: Column(
                          //           textDirection:
                          //               LanguageManager.getTextDirection(),
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: (data['offers'] as List).map((e) {
                          //             return Container(
                          //               margin: EdgeInsets.all(15),
                          //               padding: EdgeInsets.all(10),
                          //               decoration: BoxDecoration(
                          //                   color: Colors.white,
                          //                   boxShadow: [
                          //                     BoxShadow(
                          //                         color: Colors.black
                          //                             .withAlpha(15),
                          //                         blurRadius: 2,
                          //                         spreadRadius: 2)
                          //                   ],
                          //                   borderRadius:
                          //                       BorderRadius.circular(15)),
                          //               child: Column(
                          //                 textDirection: LanguageManager
                          //                     .getTextDirection(),
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.start,
                          //                 children: [
                          //                   Row(
                          //                     textDirection: LanguageManager
                          //                         .getTextDirection(),
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment
                          //                             .spaceBetween,
                          //                     children: [
                          //                       Text(
                          //                         e["price"].toString() +
                          //                             " " +
                          //                             Globals.getUnit(),
                          //                         textDirection: LanguageManager
                          //                             .getTextDirection(),
                          //                         style: TextStyle(
                          //                             color:
                          //                                 Converter.hexToColor(
                          //                                     "#2094CD"),
                          //                             fontSize: 16,
                          //                             fontWeight:
                          //                                 FontWeight.bold),
                          //                       )
                          //                     ],
                          //                   ),
                          //                   Text(
                          //                     e["description"].toString(),
                          //                     textDirection: LanguageManager
                          //                         .getTextDirection(),
                          //                     style: TextStyle(
                          //                         color: Converter.hexToColor(
                          //                             "#727272"),
                          //                         fontSize: 16,
                          //                         fontWeight:
                          //                             FontWeight.normal),
                          //                   ),
                          //                 ],
                          //               ),
                          //             );
                          //           }).toList(),
                          //         ),
                          //       ),
                          Container(
                            height: 10,
                          ),
                          Container(
                              height: 1,
                              margin: EdgeInsets.only(top: 2, bottom: 2),
                              color: Colors.black.withAlpha(
                                10,
                              )),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              textDirection: LanguageManager.getTextDirection(),
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    LanguageManager.getText(120),
                                    textDirection:
                                        LanguageManager.getTextDirection(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                EngineerRatings(widget.id)));
                                  },
                                  child: Text(
                                    LanguageManager.getText(121),
                                    textDirection:
                                        LanguageManager.getTextDirection(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                               getComments(),
                        ],
                      ),
                    )),
              isLoading
                ? Container()
                : Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                           Expanded(
                              child: InkWell(
                                onTap: () => PhoneCall.call(data['phone'], context),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 46,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        textDirection: LanguageManager.getTextDirection(),
                                        children: [
                                          Icon(
                                            FlutterIcons.phone_faw,
                                            color: Colors.white,
                                          ),
                                          Container(
                                            width: 5,
                                          ),
                                          Text(
                                            LanguageManager.getText(96),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
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
                                    Text(
                                      LanguageManager.getText(UserManager.isSubscribe() ? 358 : 348),
                                      style: TextStyle(
                                          color: UserManager.isSubscribe() ? Colors.green : Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      Container(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => Globals.startNewConversation(data['user_id'], context, active: data['active'].toString()),
                          child: Column(
                            children: [
                              Container(
                                height: 46,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  textDirection: LanguageManager.getTextDirection(),
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      color: Converter.hexToColor("#344f64"),
                                      size: 20,
                                    ),
                                    Container(
                                      width: 5,
                                    ),
                                    Text(
                                      LanguageManager.getText(117),
                                      style: TextStyle(
                                          color: Converter.hexToColor("#344f64"),
                                          fontSize: 15,
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
                              Text(
                                LanguageManager.getText(UserManager.isSubscribe() ? 358 : 348),
                                style: TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget getComments() {
    List<Widget> items = [];
    for (var item in data['ratings']) {
      items.add(Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.grey,
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
                ),
                Container(
                  width: 10,
                ),
                Column(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Row(
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Icon(
                          (item['stars'] != null? item['stars'] : 5) > 2
                              ? FlutterIcons.like_fou
                              : FlutterIcons.dislike_fou,
                          color: (item['stars'] != null? item['stars'] : 5) > 2 ? Colors.orange : Colors.grey,
                          size: 20,
                        ),
                        Container(
                          width: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            item['name'].toString(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Converter.hexToColor("#727272")),
                          ),
                        )
                      ],
                    ),
                    Row(
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Icon(
                          FlutterIcons.clock_fea,
                          color: Colors.grey,
                          size: 18,
                        ),
                        Container(
                          width: 5,
                        ),
                        Text(
                          Converter.getRealTime(item['created_at']),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Converter.hexToColor("#727272")),
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
            Container(height: 10,),
            Text(
              item['comment']?? '',
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Converter.hexToColor("#727272")),
            )
          ],
        ),
      ));
    }
    return Column(
      children: items,
    );
  }

  Widget getServiceInfo() {
    double size = MediaQuery.of(context).size.width;
    return Container(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: LanguageManager.getTextDirection(),
      children: [
        Container(
          width: size,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: EdgeInsets.all(5),
                width: size - 20,
                height: size * 0.5 - 10,
                child: TabBarView(
                    controller: controller,
                  children: (data['images'] as String)
                      .split('||')
                      .map<Widget>((String url) => Container(
                    width: size - 20,
                    height: size * 0.5 - 10,
                    decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(Globals.correctLink(url)))),
                  ))
                      .toList()),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Converter.hexToColor("#F2F2F2")),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(),
                    Row(
                        textDirection: LanguageManager.getTextDirection(),
                        children: (data['images'] as String).split('||')
                            .map<Widget>((String url) => Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: controller.index == (data['images'] as String).split('||').indexOf(url)
                                          ? Colors.white
                                          : Converter.hexToColor("#344F64")),
                                )).toList()),
                    Container(
                      child: InkWell(
                        onTap: () {
                          ShareManager.shearService(data['id'], data['provider_name'] ?? '', service: data['name']?? '');
                        },
                        child: Icon(
                          Icons.share,
                          color: Converter.hexToColor("#344F64"),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ));
  }

}
