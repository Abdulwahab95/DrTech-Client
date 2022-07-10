import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/Product.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Models/UserManager.dart';

class Store extends StatefulWidget {
  const Store();

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  ScrollController sliderController = ScrollController(),
      mainController = ScrollController();
  Map selectedFilters = {},
      filters = {},
      config = {},
      selectedCatigory,
      selectedSubCatigory = {};
  List data = [];
  bool isFilterOpen = false, isConfigLoading = false, isLoading = false;
  int sliderSelectedIndex = -1, pageIndex = 0;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      loadConfig();
    });
    super.initState();
  }

  void loadConfig() {
    setState(() {
      isConfigLoading = true;
    });

    NetworkManager.httpGet(Globals.baseUrl + "store/configuration", context, (r) {
//     var r = {
//   "state": true,
//   "sliders": [
//     {
//       "id": "3",
//       "image": "https:\/\/server.drtechapp.com\/storage\/images\/slide_1.jpg",
//       "url": "",
//       "target": "STORE",
//       "created_at": "2021-07-06 10:01:52"
//     },
//     {
//       "id": "4",
//       "image": "https:\/\/server.drtechapp.com\/storage\/images\/slide_1.png",
//       "url": "",
//       "target": "STORE",
//       "created_at": "2021-07-06 10:01:52"
//     },
//     {
//       "id": "5",
//       "image": "https:\/\/server.drtechapp.com\/storage\/images\/slide_2.jpg",
//       "url": "",
//       "target": "STORE",
//       "created_at": "2021-07-06 10:01:52"
//     }
//   ],
//   "catigories": [
//     {
//       "id": "1",
//       "name": "قسم الجوالات",
//       "name_en": "",
//       "parent_id": "0",
//       "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
//       "created_at": "2021-07-12 08:09:42",
//       "children": [
//         {
//           "id": "3",
//           "name": "ايفون",
//           "name_en": "",
//           "parent_id": "1",
//           "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
//           "created_at": "2021-07-12 08:09:42",
//           "children": [
//             {
//               "id": "6",
//               "name": "iphone 5S",
//               "name_en": "",
//               "parent_id": "3",
//               "icon": "https:\/\/server.drtechapp.com\/storage\/images\/",
//               "created_at": "2021-07-12 08:09:42",
//               "children": []
//             }
//           ]
//         },
//         {
//           "id": "4",
//           "name": "سامسونج",
//           "name_en": "",
//           "parent_id": "1",
//           "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
//           "created_at": "2021-07-12 08:09:42",
//           "children": []
//         },
//         {
//           "id": "5",
//           "name": "هواوي",
//           "name_en": "",
//           "parent_id": "1",
//           "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
//           "created_at": "2021-07-12 08:09:42",
//           "children": []
//         }
//       ]
//     },
//     {
//       "id": "2",
//       "name": "قسم الاكسسوارات ",
//       "name_en": "",
//       "parent_id": "0",
//       "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
//       "created_at": "2021-07-12 08:09:42",
//       "children": []
//     },
//     {
//       "id": "3",
//       "name": "قسم اللابتوبات ",
//       "name_en": "",
//       "parent_id": "0",
//       "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
//       "created_at": "2021-07-12 08:09:42",
//       "children": []
//     }
//   ]
// };
      setState(() {
        isConfigLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          config = r['data'];
          selectedCatigory = config['catigories'][0];
          selectedSubCatigory['id'] = '_ALL';

          print('here_getProducts: $selectedCatigory');
          print('here_getProducts: $selectedSubCatigory');
          // init();
          load();
        });
      }
    }, cashable: true);

  }

  void init() {
    if (sliderSelectedIndex == -1) initSliderLoop();
  }

  void initSliderLoop() {
    Timer(Duration(seconds: 5), () {
      if (!mounted) return;
      initSliderLoop();
    });
    setState(() {
      sliderSelectedIndex++;
      if (sliderSelectedIndex > config['sliders'].length - 1)
        sliderSelectedIndex = 0;
      double size = MediaQuery.of(context).size.width * 0.95;
      sliderController.animateTo(size * sliderSelectedIndex,
          duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
    });
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    Map<String, String> body = {
      "catigory_id": selectedCatigory['id'].toString(),
      "product_type_id": selectedSubCatigory['id'].toString(),
      // "page": pageIndex.toString()
    };
    if(UserManager.currentUser('id').isNotEmpty)
      body['user_id'] = UserManager.currentUser('id');

    NetworkManager.httpGet(Globals.baseUrl + "store/load", context, (r) {
    //  var r =   {
    //   "state": true,
    // "page": "0",
    // "catigory_id": 1,
    // "product_type_id": "_ALL",
    // "data": [
    //   { 'id': 1,
    //     'name': 'iphone 6s for sale',
    //     'price': '160',
    //     'location': 'مكة',
    //     'status': 'USED',
    //     'color': 'احمر',
    //     'brand': 'قسم الجوالات',
    //     'created_at': '2021-07-12 08:09:42',
    //     'is_guaranteed': '1',
    //     'memory': '128',
    //     'description': 'thanks for the invite',
    //     'expires_at': '2021-08-12 08:09:42',
    //     'unit': 'ر.س',
    //     'isLiked': true,
    //     'user': {
    //       'id': '30',
    //       'name': 'عبدالوهاب',
    //       'phone': '123456789',
    //     },
    //     'active': '1',
    //     'images': ['https:\/\/server.drtechapp.com\/storage\/images\/slide_1.jpg']
    //   },
    // ]
    // };

    // $this->id = $row['id'];
    // $this->name = $row['titel'];
    // $this->price = $row['price'];
    // $this->location = $row['location'];
    // $this->status = $row['product_status'];
    // $this->color = $row['color'];
    // $this->brand = $row['brand'];
    // $this->created_at = $row['created_at'];
    // $this->is_guaranteed = $row['is_guaranteed'];
    // $this->memory = $row['memory'];
    // $this->description = $row['description'];
    // $this->expires_at  = $row['expires_at'];
    // $this->unit = 'ر.س';
    // $this->isLiked  = Database::Whare("users_favorite_products", ['user_id' => $user->id, 'product_id' => $this->id], true)->RowCount() > 0;
    // $this->user = new stdClass();
    // $this->user->id = $row['user_id'];
    // $this->user->name = $row['name'];
    // $this->user->phone = $row['phone'];
    // $this->active =   strtotime(date("Y-m-d H:i:s")) <= strtotime($this->expires_at);
    // $this->images = [];
    // $images = Database::Whare('images', ['target_id' => $this->id])->FetchAll(true);
    // foreach ($images as $value) {
    // $this->images[] = IMAGES_URL . $value->name;
    // }

      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          // if (data[r['catigory_id']] == null) data[r['catigory_id']] = {};
          // if (data[r['catigory_id']][r['product_type_id']] == null)  data[r['catigory_id']][r['product_type_id']] = {};
          data = r['data'];
        });
      }
    }, body: body, cashable: true);
  }

  void setSelectedCategory(item) {
    setState(() {
      selectedCatigory = item;
      selectedSubCatigory = {"id": '_ALL'};
      pageIndex = 0;
      load();
    });
  }

  void setSelectedSubcategory(item) {
    setState(() {
      selectedSubCatigory = item;
      pageIndex = 0;
      load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TitleBar(null, 451, withoutBell: true, withoutBack: true),
          isConfigLoading
              ? Expanded(
                  child: Center(
                  child: CustomLoading(),
                ))
              :config.isEmpty ? Container()
              : Expanded(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ScrollConfiguration(
                        behavior: CustomBehavior(),
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          children: [
                            // getSearchAndFilter(),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                              child: Row(
                                textDirection:
                                    LanguageManager.getTextDirection(),
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LanguageManager.getText(139),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Converter.hexToColor("#2094CD")),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 5,
                            ),
                            getSlider(),
                            getCatigories(),
                            // Container(height: 5),
                            getSubCatigories(),
                            // Container(height: 5),
                            Center (child: Wrap(
                              textDirection: LanguageManager.getTextDirection(),
                              // spacing: 10,
                              // alignment: WrapAlignment.spaceEvenl,

                              children: getProducts(),
                            ))
                          ],
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.push(context,
                      //         MaterialPageRoute(builder: (_) => AddProduct()));
                      //   },
                      //   child: Container(
                      //     margin: EdgeInsets.only(bottom: 15),
                      //     padding: EdgeInsets.only(
                      //         left: LanguageManager.getDirection() ? 20 : 12,
                      //         right: LanguageManager.getDirection() ? 12 : 20,
                      //         top: 5,
                      //         bottom: 7),
                      //     child: Icon(
                      //       FlutterIcons.plus_circle_fea,
                      //       size: 22,
                      //       color: Colors.white,
                      //     ),
                      //     decoration: BoxDecoration(
                      //         borderRadius: LanguageManager.getDirection()
                      //             ? BorderRadius.only(
                      //                 topRight: Radius.circular(20),
                      //                 bottomRight: Radius.circular(20))
                      //             : BorderRadius.only(
                      //                 topLeft: Radius.circular(20),
                      //                 bottomLeft: Radius.circular(20)),
                      //         color: Converter.hexToColor("#344F64")),
                      //   ),
                      // ),
                    ],
                  ),
                ),
          // Container(height: 10),
        ],
      ),
    );
  }

  List<Widget> getProducts() {
    List<Widget> products = [];
        for (var item in data) {
          // for(int i=0; i == (item['payment_method'] as List).length -1; i++) {
          //   item['payment_method'][i] =
          //       (data['pay_methodes'] as List).firstWhere((element) => item['payment_method'][i] == element['method']);
          // }
          products.add(Product(item));
        }

    if (isLoading) {
      return [Container(
        width: MediaQuery.of(context).size.width,
        child: CustomLoading(),
        alignment: Alignment.center,
      )];
    }else if(products.isEmpty){
      return [Container(margin: EdgeInsets.only(top: 15),child: Text('لا يوجد منتجات لهذا القسم حالياً, سيتم الإضافة لاحقاً.. ', textDirection: LanguageManager.getTextDirection(),))];
    }

    if(products.length == 1)
      products.add((Container(width: MediaQuery.of(context).size.width * 0.5 - 20)));


    return products;
  }

  Widget getSubCatigories() {
    List<Widget> catigories = [];
    catigories.add(createSubCatigory({"id": "_ALL", "name": LanguageManager.getText(140)}));
    catigories.add(createSubCatigory({"id": "_OFFERS", "name": LanguageManager.getText(141)}));
    for (var item in selectedCatigory['children']) {
      catigories.add(createSubCatigory(item));
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: LanguageManager.getDirection(),
        children: catigories,
      ),
    );
  }

  Widget createSubCatigory(item) {
    bool selected = selectedSubCatigory['id'] == item['id'];
    return InkWell(
        onTap: () {
          setSelectedSubcategory(item);
        },
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
            margin: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                color: selected
                    ? Converter.hexToColor("#2094CD")
                    : Converter.hexToColor("#F2F2F2"),
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              item["name"].toString(),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : Colors.black,
              ),
            )));
  }

  Widget getCatigories() {

    List<Widget> catigories = [];
    for (var item in config['catigories']) {
      bool selected = selectedCatigory == item;
      catigories.add(InkWell(
        onTap: () {
          setSelectedCategory(item);
        },
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: selected
                      ? Converter.hexToColor("#2094CD")
                      : Converter.hexToColor("#EFEFEF"),
                  width: 1),
              color: selected ? Converter.hexToColor("#2094CD") : Colors.white,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: LanguageManager.getTextDirection(),
            children: [
              item["icon"] != null && item["icon"].toString().isNotEmpty
                  ? SvgPicture.network(
                      Globals.correctLink(item['icon']),
                      width: 20,
                      height: 20,
                      color: selected ? Colors.white : Colors.grey,
                    )
                  : Container(),
              Container(
                width: 10,
              ),
              Text(
                item["name"].toString(),
                textDirection: LanguageManager.getTextDirection(),
                style: TextStyle(
                  fontSize: 16,
                  color: selected ? Colors.white : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ));
    }

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: LanguageManager.getDirection(),
        children: catigories,
      ),
    );
  }

  Widget getSlider() {
    double size = MediaQuery.of(context).size.width * 0.95;
    return Center(
      child: Container(
        width: size,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(30), spreadRadius: 3, blurRadius: 3)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(color: Converter.hexToColor("#F2F2F2"), boxShadow: [
              BoxShadow(
                  color: Colors.black,
                  spreadRadius: 2,
                  blurRadius: 2)
            ],),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  scrollDirection: Axis.horizontal,
                  controller: sliderController,
                  children: getSliderContent(Size(size, size * 0.45)),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getSliderDots(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getSliderContent(Size size) {
    List<Widget> sliders = [];
    for (var item in config['sliders']) {
      sliders.add(Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
      ));
    }
    return sliders;
  }

  List<Widget> getSliderDots() {
    List<Widget> sliders = [];
    for (var i = 0; i < config['sliders'].length; i++) {
      bool selected = sliderSelectedIndex == i;
      sliders.add(Container(
        width: selected ? 14 : 8,
        height: 8,
        margin: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Converter.hexToColor(selected ? "#ffffff" : "#344F64")),
      ));
    }
    return sliders;
  }

  Widget getSearchAndFilter() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            height: 10,
          ),
          Row(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Converter.hexToColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(10)),
                  margin:
                      EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
                  padding: EdgeInsets.only(left: 14, right: 14),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          textDirection: LanguageManager.getTextDirection(),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              hintTextDirection:
                                  LanguageManager.getTextDirection(),
                              border: InputBorder.none,
                              hintText: LanguageManager.getText(102)),
                        ),
                      ),
                      Icon(
                        FlutterIcons.magnifier_sli,
                        color: Colors.grey,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ),
              // InkWell(
              //   onTap: () {
              //     setState(() {
              //       isFilterOpen = true;
              //     });
              //   },
              //   child: Column(
              //     textDirection: LanguageManager.getTextDirection(),
              //     children: [
              //       SvgPicture.asset(
              //         "assets/icons/filter.svg",
              //         width: 24,
              //         height: 24,
              //       ),
              //       Text(
              //         LanguageManager.getText(103),
              //         style: TextStyle(
              //             fontSize: 10,
              //             fontWeight: FontWeight.bold,
              //             color: Converter.hexToColor("#2094CD")),
              //       ),
              //     ],
              //   ),
              // ),
              // Container(
              //   width: 10,
              // ),
            ],
          ),
          // Container(
          //   height: 10,
          // ),
          selectedFilters.keys.length > 0
              ? Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: Text(
                          selectedFilters.values
                              .map((e) => e["text"])
                              .toList()
                              .join(" , "),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Converter.hexToColor("#2094CD"),
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedFilters = {};
                            filters = {};
                            load();
                          });
                        },
                        child: Icon(
                          FlutterIcons.close_ant,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ))
              : Container()
        ],
      ),
    );
  }
}
