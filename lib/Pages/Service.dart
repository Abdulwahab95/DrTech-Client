

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/RateStars.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/ShareManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Login.dart';
import 'ServicePage.dart';

class Service extends StatefulWidget {
  final target, title;
  const Service(this.target, this.title);

  @override
  _ServiceState createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  Map<String, String> filters = {};
  Map selectOptions = {};
  Map<String, dynamic> selectedFilters = {};
  Map<String, dynamic> configFilters;
  int page = 0;
  Map<int, List> data = {};
  bool isLoading = false, isFilterOpen = false, applyFilter = false,
      showSelectCountry = false, showSelectCity    = false, showSelectStreet  = false;

  ScrollController controller = ScrollController();

  @override
  void initState() {
    getConfig();
    load();
    super.initState();
  }

  void getConfig() {
    NetworkManager.httpPost(
        Globals.baseUrl + "services/filters", context, (r) { // ?target=${widget.target}
      if (r['state'] == true) {
        setState(() {
          configFilters = r['data'];
          List CCS= (r['data']['is_country_city_street'] as String).split('-').toList();
          showSelectCountry = CCS[0] == '1'?   true : false;
          showSelectCity    = CCS[1] == '1'?   true : false;
          showSelectStreet  = CCS[2] == '1'?   true : false;
        });
      }
    }, cachable: true, body: {'service_id': widget.target.toString()});
  }

  void load() {
    print('here_apply_filter: $applyFilter');
    timerLock = false;
    // var r = {
    //   "data": [
    //     {
    //       "id": "1",
    //       "provider_name": "عبدالوهاب عبدالهادي",
    //       "thumbnail": "https://drtech.takiddine.co/images/avatars/2021-10-16_12:58:21.956758.jpeg",
    //       "phone": "965095703",
    //       "provider_services_title": "سوفت وير لكل الهواتف	",
    //       "city_id": "8363",
    //       "street_id": "633",
    //       "stars": 5,
    //       "city_name": "مكة",
    //       "street_name": "الرياض",
    //       "verified": true,
    //       "available": true
    //     }
    //   ]
    // };
    //       setState(() {
    //         data[0] = r['data'];
    //       });
    //----------------------

    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    if(filters.isEmpty && UserManager.currentUser('country_id').isNotEmpty)
      filters['country_id_with_null'] = UserManager.currentUser('country_id');


    NetworkManager.httpPost(   // services/load?target=${widget.target}&page$page
        Globals.baseUrl + "services/details/${widget.target}", context, (r) {
      if (r['state'] == true) {
        setState(() {
          isLoading = false;
          data[0] = r['data']; // r['page']
        });
      }
    }, body: filters, cachable: true);
  }

  void startNewConversation(id) {
    UserManager.currentUser("id").isNotEmpty
        ? Navigator.push(context, MaterialPageRoute(builder: (_) => LiveChat(id.toString())))
        : Alert.show(context, LanguageManager.getText(298),
              premieryText: LanguageManager.getText(30),
              onYes: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
              }, onYesShowSecondBtn: false);
  }

  @override
  Widget build(BuildContext context) {
    print('id: ${widget.target}');
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              TitleBar(() {Navigator.pop(context);}, widget.title),
              data.isNotEmpty && data[0].length != 0 || applyFilter? getSearchAndFilter() : Container(),
              Expanded(
                child:
                isLoading? Center(child: CustomLoading()) : getEngineersList()
              )
            ],
          ),
          !isFilterOpen
              ? Container()
              : SafeArea(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    color: Colors.black.withAlpha(isFilterOpen ? 85 : 0),
                    width: MediaQuery.of(context).size.width,
                    alignment: !LanguageManager.getDirection()
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(10),
                              spreadRadius: 2,
                              blurRadius: 2)
                        ],
                        borderRadius: !LanguageManager.getDirection()
                            ? BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10))
                            : BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                        color: Colors.white,
                      ),
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                textDirection: LanguageManager.getTextDirection(),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isFilterOpen = !isFilterOpen;
                                      });
                                    },
                                    child: Icon(
                                      FlutterIcons.close_ant,
                                      size: 20,
                                    ),
                                  ),
                                  Text(
                                    LanguageManager.getText(106),
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    width: 20,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 1,
                              color: Colors.black.withAlpha(15),
                            ),
                            ...(configFilters == null
                                ? [
                                    Container(
                                      height: 150,
                                      alignment: Alignment.center,
                                      child: CustomLoading(),
                                    )
                                  ]
                                : [
                                    Expanded(
                                      child: ScrollConfiguration(
                                          behavior: CustomBehavior(),
                                          child: ListView(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 0),
                                            children: getFilters(),
                                          )),
                                    )
                                  ]),
                            Container(
                              height: 1,
                              color: Colors.black.withAlpha(15),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 10, top: 10),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isFilterOpen = false;
                                    applyFilter = true;
                                    load();
                                  });
                                },
                                child: Container(
                                  width: 190,
                                  height: 45,
                                  alignment: Alignment.center,
                                  child: Text(
                                    LanguageManager.getText(116), // تطبيق الفلتر
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
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
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  List<Widget> getFilters() {
    List<Widget> items = [];

    if(showSelectCountry || UserManager.currentUser('country_id').isEmpty)
      items.add(getFilterOption(312, configFilters['countries'], "countries", keyId: 'country_id'));
    else
      (configFilters['countries'] as List<dynamic>).forEach((element) {
        if((element as Map)['id'].toString() == UserManager.currentUser('country_id')) {
          configFilters['city'] = element['cities'] as List<dynamic>;
        }
      });

    if(showSelectCity && UserManager.currentUser('country_id').isEmpty)
      items.add(getFilterOption(107, selectedFilters['countries'] != null
          ? selectedFilters['countries']['cities']
          : LanguageManager.getText(113), "city", keyId: 'city_id', message: LanguageManager.getText(311))); // configFilters['city']

    else items.add(getFilterOption(107, configFilters['city'], "city", keyId: 'city_id')); //


    if(showSelectStreet)
      items.add(getFilterOption(108, selectedFilters['city'] != null
              ? selectedFilters['city']['street']
              : LanguageManager.getText(113),
          "street", keyId:'street_id',
          message: LanguageManager.getText(113))); // يرجي اختيار المدينة اولا قبل اختيار الحي

    items.add(getFilterOption(283, configFilters['Categories'], "Categories", keyId: 'service_categories_id'));

    items.add(getSelectedOptions('subcategories',  keyId: 'service_subcategories_id'));
    items.add(getSelectedOptions('service_sub_2',  keyId: 'sub2_id'));
    items.add(getSelectedOptions('service_sub_3',  keyId: 'sub3_id'));
    items.add(getSelectedOptions('service_sub_4',  keyId: 'sub4_id'));
    // items.add(getFilterOption(109, configFilters['device'], "device"));
    // items.add(getFilterOption(
    //     110,
    //     selectedFilters['device'] != null
    //         ? selectedFilters['device']['children']
    //         : LanguageManager.getText(114),
    //     "brand",
    //     message: LanguageManager.getText(114)));
    // items.add(getFilterOption(
    //     111,
    //     selectedFilters['brand'] != null
    //         ? selectedFilters['brand']['children']
    //         : LanguageManager.getText(115),
    //     "model",
    //     message: LanguageManager.getText(115)));

   // items.add(Expanded(child: Container()));
    return items;
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
          Container(
            decoration: BoxDecoration(
                color: Converter.hexToColor("#F2F2F2"),
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
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
                        hintTextDirection: LanguageManager.getTextDirection(),
                        border: InputBorder.none,
                        hintText: LanguageManager.getText(102)), // ابحث هنا
                    onChanged: (value) {
                      filters['word_search'] = value;
                      if(value.length == 0)
                        applyFilter = false;
                      else
                        timerLoadLock();
                      print('here_value: $value');
                    },
                    onSubmitted: (value) {
                      print("here_search $value");
                      applyFilter = value.length == 0 ? false : true;
                      load();
                    },
                  ),
                ),
                InkWell(
                  onTap: load,
                  child: Icon(
                      FlutterIcons.magnifier_sli, // search icon
                      color: Colors.grey,
                      size: 20,
                    ),
                )
              ],
            ),
          ),
          Container(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LanguageManager.getText(104), // جميع النتائج
                  style: TextStyle(
                      fontSize: 14, color: Converter.hexToColor("#707070")),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isFilterOpen = true;
                    });
                  },
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      SvgPicture.asset(
                        "assets/icons/filter.svg",
                        width: 18,
                        height: 18,
                      ),
                      Text(
                        LanguageManager.getText(103), // تصفية النتائج
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
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
                              .map((e) => e["name"])
                              .toList()
                              .join(" , ")
                          ,
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedFilters = {};
                            filters = {};
                            applyFilter = false;
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
              : Container() ,
                Container(height: 5,),
                Container(height: 1, color: Colors.black.withAlpha(12),),
                Container(height: 1, color: Colors.black.withAlpha(6),),
                Container(height: 1, color: Colors.black.withAlpha(3),),
        ],
      ),
    );
  }

  Widget getEngineersList() {
    // print('here_getEngineersList: ${data[0].length}');
    if(data[0].length == 0 && !applyFilter){
      return Column(children: [
        Expanded(
          flex: 10,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/soon.png"))),
          ),
        ),
        Spacer(flex: 1,),
        Expanded(
          flex: 9,
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
            child: Text(
              LanguageManager.getText(293), // قريباً...
              textDirection: LanguageManager.getTextDirection(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Converter.hexToColor("#303030")),
            ),
          ),
        )

      ],);
    }
    List<Widget> items = [];

    for (var page in data.keys) {
      for (var item in data[page]) {
        items.add(getEngineerUi(item));
      }
    }
    // if(items.length == 1)
    // items.add(getEngineerUi({
    //   "id": "2",
    //   "name": "\u0645\u0632\u0648\u062f \u062e\u062f\u0645\u0629",
    //   "image": "https:\/\/server.drtechapp.com\/storage\/images\/610fb357ecdf7.jpg",
    //   "service_name": "\u0627\u0635\u0644\u0627\u062d \u0627\u0644\u062c\u0648\u0644\u0627\u062a",
    //   "city_id": "8363",
    //   "street_id": "633",
    //   "phone":"+966573284334",
    //   "rating": 5,
    //   "city_name": " جدة",
    //   "street_name": "المدينة المنورة",
    //   "verified": true,
    //   "available": true
    // }));

    // widget.target == '2' || widget.target == '3'?Center(child: Text('قريبا...', textDirection: TextDirection.rtl,)):
    return Recycler(
      onScrollDown: null,
      children: items,);
  }

  String getCCT(List cct, item){
    if(cct[0] == 1){
      print('here: cct[0] == 1');
      return Converter.getRealText(324); // في جميع فروعنا العالمية لدكتورتك
    } else if(cct[1] == 1){
      print('here: cct[1] == 1');
      return Converter.getRealText(325) + ' ' + item['country_name']; // في جميع أنحاء
    } else if(cct[2] == 1){
      print('here: cct[2] == 1: ${Converter.getRealText(325)}');
      return (Converter.getRealText(325) + ' ' + item['city_name']); // في جميع أنحاء
    }
    return '';
  }


  String getSpecializ(List cssss, item){
    // if(item['specializ_from'] == 0) return '';
    // for(int i = 0; i< cssss.length;i++){
    //   if(cssss[i] == 1 && (item['specializ_from'] - 2) == i)
    //     return Converter.getRealText(326); // عام
    // }
    return Converter.getRealText(326); // return '';
  }

  String getBrand(List cssss, item){
    // if(item['brand_from'] == 0) return '';

    // for(int i = 0; i< cssss.length;i++){
    //   if(cssss[i] == 1 && (item['brand_from'] - 2) == i)
    //     return Converter.getRealText(112);//الكل
    // }
    return Converter.getRealText(112); // return '';
  }

  String getServices(List cssss, item){ // الخدمات
    if(item['title_from'] == 0) return '';
    for(int i = 0; i< cssss.length;i++){
      if(cssss[i] == 1 && (item['title_from'] - 2) == i)
        return Converter.getRealText(327) + ' ' + widget.title; //جميع خدمات
    }
    return Converter.getRealText(327) + ' ' + widget.title; // return '';
  }

  Widget getEngineerUi(item) {

    List cct   =
        (item != null && (item as Map).isNotEmpty && (item as Map).containsKey('country_city_street') && item['country_city_street'] != null)
        ? item['country_city_street']           .split('-').map(int.parse).toList()
        : [0,0,0];
    List cssss =
        (item != null && (item as Map).isNotEmpty && (item as Map).containsKey('cat_subcat_sub1_sub2_sub3_sub4') && item['cat_subcat_sub1_sub2_sub3_sub4'] != null)
        ? item['cat_subcat_sub1_sub2_sub3_sub4'].split('-').map(int.parse).toList()
        : [0,0,0,0,0];


    print('here_cct: $cct, cssss: $cssss');

    return Container(
      padding: EdgeInsets.all(7),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(15), spreadRadius: 2, blurRadius: 2)
      ], borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServicePage(item['id']))); // EngineerPage(item['id'], widget.target)
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: 90,
              margin: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    alignment: !LanguageManager.getDirection()
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft,
                    child: item['profile_verified'] == true
                        ? Container(
                            width: 20,
                            height: 20,
                            child: Icon(
                              FlutterIcons.check_fea,
                              color: Colors.white,
                              size: 15,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                          )
                        : Container(),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(Globals.correctLink(item['thumbnail']))),
                        borderRadius: BorderRadius.circular(10),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    height: 15,
                  ),
                  item['active'] == true
                      ? Text(
                          LanguageManager.getText(100) ,//+ '/' + item['id'].toString() + '/' + item['Country_name'] + '/' + item['service_id'].toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.normal),
                        )
                      : Text(
                          LanguageManager.getText(101) ,//+ '/' + item['id'].toString() + '/' + item['Country_name'] + '/' + item['service_id'].toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.normal),
                        )
                ],
              ),
            ),
            Container(
              width: 10,
            ),
            Expanded(
                child: Column(
              textDirection: LanguageManager.getTextDirection(),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Expanded(
                        child: Text(
                      item['provider_name'].toString(),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#2094CD"),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold),
                    )),
                    InkWell(
                      onTap: () {
                        ShareManager.shearEngineer(
                            item['id'], item['provider_name'], item['provider_services_title']);
                      },
                      child: Container(
                        // margin: EdgeInsets.only(top: 10),
                        child: Icon(
                          FlutterIcons.share_2_fea,
                          color: Converter.hexToColor("#344F64"),
                        ),
                      ),
                    )
                  ],
                ),

                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    RateStars(
                      12,
                      stars: item['stars'].toInt(),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        Converter.format(item['stars']),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Container(height: 5),

                // Globals.checkNullOrEmpty(item['specializ']) || Globals.checkNullOrEmpty(getSpecializ(cssss, item)) ?
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Icon(
                      FlutterIcons.md_person_ion,
                      color: Colors.grey,
                      size: 15,
                    ),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          LanguageManager.getText(270) +
                              " :  " +
                              (Globals.checkNullOrEmpty(item['specializ'].toString())
                                  ? item['specializ'].toString()
                                  : getSpecializ(cssss, item)),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                )
                    // : Container()
                ,

                // Globals.checkNullOrEmpty(item['brand']) || Globals.checkNullOrEmpty(getBrand(cssss, item))  ?
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(
                      margin: LanguageManager.getDirection()? EdgeInsets.only(right: 2, left: 5) : EdgeInsets.only(right: 6, left: 0),
                      child: SvgPicture.asset(
                        "assets/icons/services.svg",
                        width: 13,
                        height: 13,
                        color: Colors.grey,
                      ),
                    ),

                    Expanded(
                      child: Container(
                        child: Text(
                          LanguageManager.getText(310) +
                              " :  " +
                              (Globals.checkNullOrEmpty(item['brand'].toString())
                                  ? item['brand'].toString()
                                  : getBrand(cssss, item)),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ) ,
                    // : Container(),

                // Globals.checkNullOrEmpty(item['provider_services_title']) || Globals.checkNullOrEmpty(getServices(cssss, item)) ?
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Icon(
                      FlutterIcons.md_cog_ion,
                      color: Colors.grey,
                      size: 15,
                    ),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          (
                              (Globals.checkNullOrEmpty(item['provider_services_title'].toString())
                                ? LanguageManager.getText(309) + " :  " + item['provider_services_title'].toString()
                                :getServices(cssss, item))
                          ),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                )
                    // : Container()
                ,
                Globals.checkNullOrEmpty(item['city_name']) ||
                Globals.checkNullOrEmpty(item['country_name']) ||
                    Globals.checkNullOrEmpty(getCCT(cct, item))?
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Icon(
                      FlutterIcons.location_oct,
                      size: 15,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(

                          Globals.checkNullOrEmpty(getCCT(cct, item))
                              ? getCCT(cct, item)

                              : Globals.checkNullOrEmpty(item['city_name'])
                                ? item['street_name'].toString().isEmpty
                                        ? (Globals.checkNullOrEmpty(getCCT([0,0,1], item)) ? getCCT([0,0,1], item) : "")
                                        : (item['city_name'].toString()  + "  -  " + item['street_name'].toString())

                                   : Globals.checkNullOrEmpty( item['country_name'].toString())
                                        ? getCCT([0,1,0] , {'country_name': item['country_name'].toString()})
                                        : getCCT([0,1,0] , {'country_name': item['country_name'].toString()})
                          ,
                                textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ) : Container(),
                Container(
                  height: 10,
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    // Expanded(
                    //   child: InkWell(
                    //     onTap: () {},
                    //     child: Container(
                    //       height: 40,
                    //       alignment: Alignment.center,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         textDirection: LanguageManager.getTextDirection(),
                    //         children: [
                    //           Icon(
                    //             FlutterIcons.phone_faw,
                    //             color: Colors.white,
                    //           ),
                    //           Container(
                    //             width: 5,
                    //           ),
                    //           Text(
                    //             LanguageManager.getText(96),
                    //             style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.w600),
                    //           ),
                    //         ],
                    //       ),
                    //       decoration: BoxDecoration(
                    //           boxShadow: [
                    //             BoxShadow(
                    //                 color: Colors.black.withAlpha(15),
                    //                 spreadRadius: 2,
                    //                 blurRadius: 2)],
                    //           borderRadius: BorderRadius.circular(12),
                    //           color: Converter.hexToColor("#344f64")
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   width: 10,
                    // ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          startNewConversation(item['provider_id']);
                        },
                        child: Container(
                          height: 40,
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
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
              ],
            )),
            Container(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget getFilterOption(title, options, key, {message, String keyId}) {
    print('op=: ${options.runtimeType}');
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        textDirection: LanguageManager.getTextDirection(),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LanguageManager.getText(title),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Container(
            height: 2,
          ),
          InkWell(
            onTap: () {
              if (options.runtimeType == String) {
                if (selectedFilters[options] != null &&
                    selectedFilters[options]['street'] != null) {
                  Alert.show(context, options, type: AlertType.SELECT);
                } else {
                  Alert.show(context, message);
                }
              } else {
                var tmpList = options as List;
               // print('tmp: ${tmpList.isEmpty}, ${tmpList.first != {'name': 'الكل'}}, ${(tmpList.isEmpty || tmpList.first != {'name': 'الكل'})}, ${tmpList.first.runtimeType}, ${{'name': 'الكل'}.runtimeType}');
               //  Map<String, dynamic> s= {'name': 'الكل'};
               //  if(tmpList.isEmpty || (!mapEquals(tmpList.first, s)))
               //      tmpList.insert(0, {'name': 'الكل'});

                Alert.show(context,tmpList,
                    type: AlertType.SELECT, onSelected: (item) {
                  setState(() {
                    print('here_item: $key, $item');

                    switch (key) {
                      case 'countries':
                        filters.remove('city_id');
                        selectedFilters.remove('city');
                        filters.remove('street_id');
                        selectedFilters.remove('street');
                        break;
                      case 'city':
                        filters.remove('street_id');
                        selectedFilters.remove('street');
                        break;
                      case 'Categories':
                        selectOptions['subcategories'] = item['subcategories'];
                        setNullSO(3);
                        break;
                      case 'subcategories':
                        selectOptions['service_sub_2'] = item['service_sub_2'];
                        setNullSO(2);
                        break;
                      case 'service_sub_2':
                        selectOptions['service_sub_3'] = item['service_sub_3'];
                        setNullSO(1);
                        break;
                      case 'service_sub_3':
                        selectOptions['service_sub_4'] = item['service_sub_4'];
                        setNullSO(0);
                        break;
                      default:
                        print('------------->>>> $key');
                    }


                    if((item as Map) != null && (item as Map).isNotEmpty && (item as Map).containsKey('id')
                        && (item['id'] == null || (item['id'] != null && item['id'].toString().toLowerCase() == 'null'))) {
                      print('here_selectedFilters:* $selectedFilters');
                      print('here_filters:* , $filters');
                      if(selectedFilters.containsKey(key))
                        selectedFilters.remove(key);
                      if(filters.containsKey(keyId))
                        filters.remove(keyId);
                      return;
                    }

                    selectedFilters[key] = item;
                    filters[keyId] = item['id'].toString();
                    print('here_selectedFilters:* ${selectedFilters.keys}');
                    print('here_filters:* , $filters');
                  });
                });
              }
            },
            child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Converter.hexToColor("#F2F2F2")),
                child: Row(
                  textDirection: LanguageManager.getTextDirection(),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      selectedFilters[key] == null
                          ? LanguageManager.getText(112)
                          : selectedFilters[key]["name"],
                      textDirection: LanguageManager.getTextDirection(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    )),
                    Icon(FlutterIcons.chevron_down_fea,
                        size: 20, color: Colors.grey),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void setNullSO(int i) {
    // print('here_selectedFilters: $selectedFilters');
    // print('here_filters: i: $i, $filters');
    if(i != 0) {
      i--;
      selectOptions['service_sub_4'] = null;
      selectedFilters.remove('service_sub_3');
      filters.remove('sub3_id');
    }
    if(i != 0) {
      i--;
      selectOptions['service_sub_3'] = null;
      selectedFilters.remove('service_sub_2');
      filters.remove('sub2_id');
    }
    if(i != 0) {
      i--;
      selectOptions['service_sub_2'] = null;
      selectedFilters.remove('subcategories');
      filters.remove('service_subcategories_id');
    }
    if(i != 0) {
      i--;
      selectOptions['subcategories'] = null;
    }
    if(i == 0) {
      selectedFilters.remove('service_sub_4');
      filters.remove('sub4_id');
    }

    // print('here_selectedFilters: $selectedFilters');
    // print('here_filters: i: $i, $filters');
  }

  getSelectedOptions(String s, {String keyId}) {
    print('here_selectOptions_map : ${selectOptions[s]}');
    var isNullOrEmptySO = selectOptions[s]!=null && (selectOptions[s] as List).isNotEmpty;
    // if(isNullOrEmptySO){
    //   selectOptions[s]
    // }
    return isNullOrEmptySO? getFilterOption(256, selectOptions[s], s, keyId: keyId): Container();
  }

  var timerLock = false;
  void timerLoadLock() {
    if(!timerLock)
      Timer(Duration(seconds: 3), () {
        timerLock = true;
        applyFilter = true;
        load();
      });
  }

}
