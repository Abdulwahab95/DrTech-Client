import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/PhoneCall.dart';
import 'package:dr_tech/Components/RateStarsStateless.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/SoonWidget.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/ShareManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Components/CustomSwitchStateless.dart';
import 'FeatureSubscribe.dart';
import 'Login.dart';
import 'Offers.dart';
import 'OpenImage.dart';
import 'ProviderProfile.dart';
import 'QuickOffers.dart';
import 'ServicePage.dart';
import 'UserFavoritServices.dart';

class OnlineEngineerServices extends StatefulWidget {
  final target, title;
  const OnlineEngineerServices(this.target, this.title);

  @override
  _OnlineEngineerServicesState createState() => _OnlineEngineerServicesState();
}

class _OnlineEngineerServicesState extends State<OnlineEngineerServices> with WidgetsBindingObserver{
  Map<String, String> filters = {};
  Map selectOptions = {};
  Map<String, dynamic> selectedFilters = {};
  Map<String, dynamic> configFilters;
  int page = 0;
  Map<int, List> data = {};
  bool isLoading = false, isFilterOpen = false, applyFilter = false,
      showSelectCountry = false, showSelectCity    = false, showSelectStreet  = false;
  bool isSubscribe = UserManager.isSubscribe();

  ScrollController controller = ScrollController();
  TextEditingController textEditingController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getConfig();
    load();
    super.initState();
    textEditingController = TextEditingController(text: filters['word_search']??'');
    textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('here_resumed_from: OnlineEngineerServices');
      load();
    }
  }

  void getConfig() {
    NetworkManager.httpPost(
        Globals.baseUrl + "services/filters/online", context, (r) { // ?target=${widget.target}
      if (r['state'] == true) {
        setState(() {
          configFilters = r['data'];
          List CCS= (r['data']['is_country_city_street'] as String).split('-').toList();
          showSelectCountry = CCS[0] == '1'?   true : false;
          showSelectCity    = CCS[1] == '1'?   true : false;
          showSelectStreet  = CCS[2] == '1'?   true : false;
        });
      }
    }, cachable: true, body: {'service_id': '6', 'service_categories_id' : widget.target.toString()}); // //widget.target.toString()
  }

  void load() {
    print('here_apply_filter: $applyFilter');
    timerLock = false;

    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    if(filters.isEmpty && UserManager.currentUser('country_id').isNotEmpty)
      filters['country_id_with_null'] = UserManager.currentUser('country_id');
    filters['service_categories_id'] = widget.target.toString();
    filters['target'] = 'online_services';
    filters['user_id'] = UserManager.currentUser('id');


    NetworkManager.httpPost(Globals.baseUrl + "services/details/6", context, (r) {// services/load?target=${widget.target}&page$page
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
    textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
    print('id: ${widget.target}');
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              TitleBar(() {Navigator.pop(context);}, widget.title),
              data.isNotEmpty && data[0].length != 0 || applyFilter
                  ? getSearchAndFilter()
                  : Container(),
              Expanded(
                  child: isLoading
                      ? Center(child: CustomLoading())
                      : data.isNotEmpty && data[0].length != 0
                          ? getEngineersList()
                          : SoonWidget())
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
                                textDirection:
                                    LanguageManager.getTextDirection(),
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      controller: textEditingController,
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
                                    LanguageManager.getText(
                                        116), // تطبيق الفلتر
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

    if(showSelectCountry || (UserManager.currentUser('country_id').isEmpty && (showSelectCity || showSelectStreet)))
      items.add(getFilterOption(312, configFilters['countries'], "countries", keyId: 'country_id'));
    else
      (configFilters['countries'] as List<dynamic>).forEach((element) {
        if((element as Map)['id'].toString() == UserManager.currentUser('country_id')) {
          configFilters['city'] = element['cities'] as List<dynamic>;
        }
      });

    if(!showSelectCountry && showSelectCity && UserManager.currentUser('country_id').isNotEmpty){
      print('here_getFilterOption: else');
      items.add(getFilterOption(107, configFilters['city'], "city", keyId: 'city_id'));
    }
    else if(showSelectCity || (UserManager.currentUser('country_id').isEmpty && showSelectStreet)){
      print('here_getFilterOption: if');
      items.add(getFilterOption(107, selectedFilters['countries'] != null
          ? selectedFilters['countries']['cities']
          : LanguageManager.getText(113),
          "city", keyId: 'city_id', message: LanguageManager.getText(311)));
    } // configFilters['city']


    if(showSelectStreet)
      items.add(getFilterOption(108, selectedFilters['city'] != null
          ? selectedFilters['city']['street']
          : LanguageManager.getText(113),
          "street", keyId:'street_id',
          message: LanguageManager.getText(113))); // يرجي اختيار المدينة اولا قبل اختيار الحي

    items.add(getFilterOption(283, configFilters['subcategories'], "subcategories", keyId: 'service_subcategories_id'));
    items.add(getSelectedOptions('service_sub_2',  keyId: 'sub2_id'));
    items.add(getSelectedOptions('service_sub_3',  keyId: 'sub3_id'));
    items.add(getSelectedOptions('service_sub_4',  keyId: 'sub4_id'));
    items.add(getFilterOption(275, configFilters['ratings'], "ratings",  keyId: 'ratings'));
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

  // Widget getSearchAndFilter() {
  //   return Container(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       textDirection: LanguageManager.getTextDirection(),
  //       children: [
  //         Container(
  //           height: 10,
  //         ),
  //         Container(
  //           decoration: BoxDecoration(
  //               color: Converter.hexToColor("#F2F2F2"),
  //               borderRadius: BorderRadius.circular(10)),
  //           margin: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
  //           padding: EdgeInsets.only(left: 14, right: 14),
  //           child: Row(
  //             textDirection: LanguageManager.getTextDirection(),
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   textInputAction: TextInputAction.search,
  //                   textDirection: LanguageManager.getTextDirection(),
  //                   keyboardType: TextInputType.text,
  //                   decoration: InputDecoration(
  //                       hintTextDirection: LanguageManager.getTextDirection(),
  //                       border: InputBorder.none,
  //                       hintText: LanguageManager.getText(102)), // ابحث هنا
  //                   onChanged: (value) {
  //                     filters['word_search'] = value;
  //                     if(value.length == 0)
  //                       applyFilter = false;
  //                     else
  //                       timerLoadLock();
  //                     print('here_value: $value');
  //                   },
  //                   onSubmitted: (value) {
  //                     print("here_search $value");
  //                     applyFilter = value.length == 0 ? false : true;
  //                     load();
  //                   },
  //                 ),
  //               ),
  //               InkWell(
  //                 onTap: load,
  //                 child: Icon(
  //                   FlutterIcons.magnifier_sli, // search icon
  //                   color: Colors.grey,
  //                   size: 20,
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         Container(
  //           height: 10,
  //         ),
  //         Container(
  //           padding: EdgeInsets.only(left: 15, right: 15),
  //           child: Row(
  //             textDirection: LanguageManager.getTextDirection(),
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 LanguageManager.getText(104), // جميع النتائج
  //                 style: TextStyle(
  //                     fontSize: 14, color: Converter.hexToColor("#707070")),
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   setState(() {
  //                     isFilterOpen = true;
  //                   });
  //                 },
  //                 child: Row(
  //                   textDirection: LanguageManager.getTextDirection(),
  //                   children: [
  //                     SvgPicture.asset(
  //                       "assets/icons/filter.svg",
  //                       width: 18,
  //                       height: 18,
  //                     ),
  //                     Text(
  //                       LanguageManager.getText(103), // البحث المتقدم
  //                       style: TextStyle(fontSize: 14, color: Colors.blue),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         selectedFilters.keys.length > 0
  //             ? Container(
  //             margin: EdgeInsets.only(top: 5),
  //             padding: EdgeInsets.only(left: 10, right: 10),
  //             child: Row(
  //               textDirection: LanguageManager.getTextDirection(),
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     selectedFilters.values
  //                         .map((e) => e["name"])
  //                         .toList()
  //                         .join(" , ")
  //                     ,
  //                     textDirection: LanguageManager.getTextDirection(),
  //                     style: TextStyle(
  //                         color: Colors.blue,
  //                         fontWeight: FontWeight.normal),
  //                   ),
  //                 ),
  //                 InkWell(
  //                   onTap: () {
  //                     setState(() {
  //                       selectedFilters = {};
  //                       filters = {};
  //                       applyFilter = false;
  //                       load();
  //                     });
  //                   },
  //                   child: Icon(
  //                     FlutterIcons.close_ant,
  //                     color: Colors.red,
  //                   ),
  //                 )
  //               ],
  //             ))
  //             : Container() ,
  //         Container(height: 5,),
  //         Container(height: 1, color: Colors.black.withAlpha(12),),
  //         Container(height: 1, color: Colors.black.withAlpha(6),),
  //         Container(height: 1, color: Colors.black.withAlpha(3),),
  //       ],
  //     ),
  //   );
  // }

  Widget getSearchAndFilter() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 18),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SplashEffect(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickOffers(widget.target.toString(), isOnlineServices: true))),
                  borderRadius: false,
                  showShadow: false,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  color: Converter.hexToColor("#344F64"),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      SvgPicture.asset(
                        "assets/icons/offers.svg",
                        width: 18,
                        height: 18,
                        color: Colors.white,
                      ),
                      Container(width: 1),
                      Text(
                        LanguageManager.getText(443), // عروض المزودين
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(width: 10,),
                SplashEffect(
                  onTap: () => setState(() {isFilterOpen = true;}),
                  borderRadius: false,
                  showShadow: false,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  border: Border.all(color: Converter.hexToColor("#344F64")),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      SvgPicture.asset(
                          "assets/icons/filter.svg",
                          width: 18,
                          height: 18,
                          color: Converter.hexToColor('#344F64')
                      ),
                      Container(width: 10),
                      Text(
                        LanguageManager.getText(103), // البحث المتقدم
                        style: TextStyle(fontSize: 14, color: Converter.hexToColor('#344F64')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getEngineersList() {
    if(data[0].length == 0 && !applyFilter){
      return SoonWidget();
    }
    List<Widget> items = [];

    for (var page in data.keys) {
      for (var item in data[page]) {
        items.add(getEngineerUi(item));
      }
    }

    return Recycler(
      onScrollDown: null,
      children: items,);
  }

  String getCCT(List cct, item){
    if(cct[0] == 1){
      return Converter.getRealText(324); // في جميع فروعنا العالمية لدكتورتك
    } else if(cct[1] == 1){
      return Converter.getRealText(325) + ' ' + item['country_name']; // في جميع أنحاء
    } else if(cct[2] == 1){
      return (Converter.getRealText(325) + ' ' + item['city_name']); // في جميع أنحاء
    }
    return '';
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
    List skills = [];
    if(( item['provider_skills'] ?? []).isEmpty)
      skills.add(LanguageManager.getText(437));
    else{
      (item['provider_skills'] as List<dynamic>).forEach((element) {
          skills.add(element[LanguageManager.getDirection() ? 'name' : 'name_en']);
      });
    }

    List cssss =
    (item != null && (item as Map).isNotEmpty && (item as Map).containsKey('cat_subcat_sub1_sub2_sub3_sub4') && item['cat_subcat_sub1_sub2_sub3_sub4'] != null)
        ? item['cat_subcat_sub1_sub2_sub3_sub4'].split('-').map(int.parse).toList()
        : [0,0,0,0,0];


    //print('here_cct: $cct, cssss: $cssss');

    return Container(
      padding: EdgeInsets.only(top: 7, right: 4, left: 4, bottom: 4),
      margin:  EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(15), spreadRadius: 2, blurRadius: 2)
      ], borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServicePage(item['id'], isOnlineService: true))); // EngineerPage(item['id'], widget.target)
        },
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: LanguageManager.getTextDirection(),
              children: [
                SplashEffect(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OpenImage(url: (item['thumbnail'] as String)))),
                  showShadow: false,
                  borderRadius: false,
                  child: Container(
                    width: 125,
                    height: 140,
                    margin: LanguageManager.getDirection()
                        ? EdgeInsets.only(top: 5, right: 5, left: 0)
                        : EdgeInsets.only(top: 5, right: 0, left: 5),
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
                        color: Converter.hexToColor("#F2F2F2"),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 6,
                              spreadRadius: 0,
                              offset: Offset(0, 3),
                              color: Converter.hexToColor('#218BB8'))
                        ]),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                                child: Text(
                                  (Globals.checkNullOrEmpty(item['provider_services_title'].toString())
                                  ?item['provider_services_title'].toString() : getServices(cssss, item)),
                                  textDirection: LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      color: Converter.hexToColor("#2094CD"),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold),
                                )),
                            CustomSwitchStateless(
                              activeText: LanguageManager.getText(100),
                              notActiveText: LanguageManager.getText(101),
                              activeColor: Converter.hexToColor('#00710B'),
                              notActiveColor: Converter.hexToColor('#B90404'),
                              isActive: item['active'] ?? true,
                            ),
                          ],
                        ),
                        // Stars
                        Row(
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            RateStarsStateless(
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
                        Container(height: 1),
                        // provider name
                        createItemSvgText('person', 19, 18, LanguageManager.getText(366) + ":  " +
                            (Globals.checkNullOrEmpty(item['provider_name'].toString()) ? item['provider_name'].toString() : Converter.getRealText(437)),),
                        Container(height: 1),
                        // skills
                        createItemSvgText('dynamic_feed', 15, 14, LanguageManager.getText(401) + ":  " +
                            (skills.isNotEmpty?  skills.join(', ') + '.' : Converter.getRealText(112)),),
                        Container(height: 1),
                        // location
                        createItemSvgText('pin_drop', 13, 16, LanguageManager.getText(398) + ":  ",
                          secondTextColored: (Globals.checkNullOrEmpty(item['provider_country'].toString()) ? item['provider_country'].toString() : Converter.getRealText(437)),),

                        Container(height: 2),
                        // go to profile
                        SplashEffect(
                          onTap: (){
                            if(item['provider_id'] == null) return;
                            Navigator.push(context, MaterialPageRoute(
                                settings: RouteSettings(name: 'ProviderProfile'),
                                builder: (_) => ProviderProfile(item['provider_id'].toString(),
                                  active: item['active'].toString(),
                                )
                            ));
                          },
                          showShadow: false,
                          child: createItemSvgText('directions_run', 14, 18, LanguageManager.getText(407), colorText: Converter.hexToColor('#B90404'), height: 1.1),
                        ),
                        SvgPicture.asset("assets/icons/line_point.svg", width: 140),
                      ],
                    )),
                Column(children: [
                  Container(height: 35),
                  createCircleSvgButton((item['is_i_Liked'] ?? false)? 'liked' : 'like', (item['favourites'].toString() ?? 0), () {
                    addDeleteFavourite(item, isLiked: (item['is_i_Liked'] ?? false));
                  }),
                  createCircleSvgButton('outline-share', LanguageManager.getText(442), () {
                    ShareManager.shearEngineer(item['id'],
                        item['provider_name'], item['provider_services_title']);
                  }),
                  item['offers'].toString() != 'false' ?
                  createCircleSvgButton('offers', LanguageManager.getText(353),
                          () {Navigator.push(context, MaterialPageRoute(
                          builder: (_) => Offers(item['id'].toString(),
                              item['phone'], item['active'].toString())));
                      }) : Container(height: 42, width: 42,),
                ]),
              ],
            ),
            // Container(height: 15),
            Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(width: 16),
                item['phone'].toString().isEmpty || item['phone'].toString().toLowerCase() == 'null' ? Container()
                    : Expanded(
                        child: InkWell(
                          onTap: () => PhoneCall.call(item['phone'], context, isOnlineService: true),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection:
                              LanguageManager.getTextDirection(),
                              children: [
                                Icon(
                                  FlutterIcons.phone_faw,
                                  color: Colors.white,
                                ),
                                Container(
                                  width: 5,
                                ),
                                Text(
                                  LanguageManager.getText(444),
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
                                borderRadius: BorderRadius.circular(19),
                                color: Converter.hexToColor("#218BB8")),
                          ),
                        ),
                ),
                item['phone'].toString().isEmpty || item['phone'].toString().toLowerCase() == 'null' ? Container() : Container(width: 5),
                Expanded(
                  child: InkWell(
                    onTap: () => Globals.startNewConversation(item['provider_id'], context, active: item['active'].toString()),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: LanguageManager.getTextDirection(),
                        children: [
                          Icon(
                            Icons.chat,
                            color: Converter.hexToColor("#218BB8"),
                            size: 20,
                          ),
                          Container(
                            width: 5,
                          ),
                          Text(
                            LanguageManager.getText(117),
                            style: TextStyle(
                                color: Converter.hexToColor("#218BB8"),
                                fontSize: 15,
                                height: 1.2,
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
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                              color: Converter.hexToColor("#218BB8"))),
                    ),
                  ),
                ),
                Container(width: 25),
              ],
            ),
            Container(height: 15),
          ],
        ),
      ),
    );
    // item['quick_offer'].toString() != 'null'
    //     ? Container(
    //   width: 85,
    //   height: 130,
    //   margin: !LanguageManager.getDirection()? EdgeInsets.only(left: 22, top: 140) : EdgeInsets.only(right: 22, top: 140),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: [
    //       Container(height: 6),
    //       Container(
    //         padding: EdgeInsets.all(1),
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(5),
    //             color:  Converter.hexToColor("#ffffff"),
    //             boxShadow: [
    //               BoxShadow(
    //                   color: Colors.black.withAlpha(45),
    //                   spreadRadius: 1,
    //                   blurRadius: 7)
    //             ]),
    //         child: Stack(
    //           children: [
    //             CachedNetworkImage(imageUrl:Globals.correctLink(item['quick_offer']['image'])),
    //             new Positioned.fill(
    //                 child: new Material(
    //                     color: Colors.transparent,
    //                     child: new InkWell(
    //                       splashColor: Colors.white70,
    //                       onTap: () => showAlertQuickOffer(item['quick_offer'], item['provider_id'], item['active']),
    //                     ))),
    //           ],
    //         ),
    //       ),
    //
    //     ],
    //   ),
    // )
    //     : item['offers'].toString() != 'false'
    //     ? Container(
    //   width: 85,
    //   margin: !LanguageManager.getDirection() ? EdgeInsets.only(left: 21, top: 150) : EdgeInsets.only(right: 21, top: 150),
    //   child: Column(
    //     // mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Container(
    //         padding: EdgeInsets.symmetric(horizontal: 5),
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(12),
    //             border: Border.all(color: Converter.hexToColor("#344f64")),
    //             color:  Converter.hexToColor("#ffffff"),
    //             boxShadow: [
    //               BoxShadow(
    //                   color: Colors.black.withAlpha(20),
    //                   spreadRadius: 1,
    //                   blurRadius: 7)
    //             ]),
    //         child: Stack(
    //           children: [
    //             Row(
    //               textDirection: LanguageManager.getTextDirection(),
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(
    //                   FlutterIcons.tag_ant,
    //                   color: Converter.hexToColor("#344f64"),
    //                   size: 18,
    //                 ),
    //                 Container(padding: EdgeInsets.symmetric( horizontal: 4),child: Text(LanguageManager.getText(353), textDirection: LanguageManager.getTextDirection(), style: TextStyle(color: Converter.hexToColor("#344f64"), fontWeight: FontWeight.bold),)),
    //               ],
    //             ) ,
    //             new Positioned.fill(
    //                 child: new Material(
    //                     color: Colors.transparent,
    //                     child: new InkWell(
    //                       splashColor: Colors.white70,
    //                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (
    //                           _) => Offers(item['id'].toString(),item['phone'], item['active'].toString() ))),
    //                     ))),
    //           ],
    //         ),
    //       ),
    //
    //     ],
    //   ),
    // )
    //     : Container(),
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

  showAlertQuickOffer(quickOffer, providerId, active) {
    Alert.show(context, Wrap(
      children: [
        Column(
          children: [
            Row(
              children: [
                InkWell(
                  highlightColor: Colors.green,
                  onTap: () => Navigator.pop(context),
                  child: Icon(FlutterIcons.close_ant,size: 24),
                )
              ],
            ),
            Text(
              Converter.getRealText(quickOffer[LanguageManager.getDirection() ? 'title' : 'title_en']),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Converter.hexToColor("#F5A623")),
              textAlign: TextAlign.center,
            ),
            Container(height: 15),
            Container(padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:  Converter.hexToColor("#F2F2F2"),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(45),
                          spreadRadius: 1,
                          blurRadius: 7)
                    ]),child: CachedNetworkImage(imageUrl:Globals.correctLink(quickOffer['image']))),
            Container(height: 15),
            Text(quickOffer[LanguageManager.getDirection() ? 'body' : 'body_en'],
              textDirection: LanguageManager.getTextDirection(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 15),
              child: Row(
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 90,
                        height: 45,
                        alignment: Alignment.center,
                        child: Text(
                          Converter.getRealText(132),
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Converter.hexToColor("#F5A623"),
                                  spreadRadius: 1,
                                  blurRadius: 1)
                            ],
                            borderRadius: BorderRadius.circular(8),
                            color: Converter.hexToColor("#ffffff")),
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Expanded(
                      child: InkWell(
                        onTap: () {
                          if(active.toString() == 'false') {
                            Alert.show(context, 349);
                            return;
                          }
                          if(UserManager.currentUser("id").isEmpty) {
                            Alert.show(context, LanguageManager.getText(298), // عليك تسجيل الدخول أولا
                                premieryText: LanguageManager.getText(30),
                                onYes: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => Login()));
                                }, onYesShowSecondBtn: false);
                            return;
                          }
                          if(!UserManager.isSubscribe()){
                            showAlertSubscribe();
                            return;
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (
                              _) => LiveChat(providerId.toString(),
                            openSendMessage: Converter.replaceValue(LanguageManager.getText(351), quickOffer['body'])
                            ,)));
                        },
                        child: Container(
                          width: 90,
                          height: 45,
                          alignment: Alignment.center,
                          child: Text(
                            Converter.getRealText(350), // اطلبها
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    spreadRadius: 2,
                                    blurRadius: 2)
                              ],
                              borderRadius: BorderRadius.circular(8),
                              color: Converter.hexToColor("#F5A623")),
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ],), type: AlertType.WIDGET, isDismissible: false);
  }

  void showAlertSubscribe() {
    Alert.show(
        context,
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (Alert.publicClose != null)
                        Alert.publicClose();
                      else
                        Navigator.pop(context);
                    },
                    child: Icon(
                      FlutterIcons.close_ant,
                      size: 24,
                    ),
                  )
                ],
              ),
              Container(
                height: 10,
              ),
              Text(
                LanguageManager.getText(357),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Container(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 15),
                child: Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => FeatureSubscribe()));
                        },
                        child: Container(
                          width: 90,
                          height: 45,
                          alignment: Alignment.center,
                          child: Text(
                            LanguageManager.getText(75),
                            style: TextStyle(color: Colors.white),
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
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  createItemSkill(String str, int index, int length) {

    return Container(
        // margin: EdgeInsets.all(5),
        // padding: EdgeInsets.symmetric(horizontal: 14),
        // decoration: BoxDecoration(
        //   color: Colors.transparent,
        //   borderRadius: BorderRadius.circular(999),
        //   border: Border.all(
        //     color: Converter.hexToColor('#707070'),
        //     width: 1,
        //   ),
        // ),
    child: Text(
      str + (index == length - 1? '.' : ', '),
      style: TextStyle(color: Colors.black, fontSize: 12),
      textDirection: LanguageManager.getTextDirection(),
    ));
  }

  createItemSvgText(String name, double w, double h, String text, {secondTextColored, colorText, double height}) {
    return Row(
      textDirection: LanguageManager.getTextDirection(),
      children: [
        SvgPicture.asset(
            "assets/icons/$name.svg",
            width: w,
            height: h),
        Container(width: secondTextColored == null && colorText == null? 5 : 5.5),
        secondTextColored == null ?
        Expanded(
          child: Text(text,
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                height: height == null? 1.8 : height,
                fontWeight: FontWeight.normal,
                fontSize: 11.5,
                color: colorText == null? Colors.black : colorText),
          ),
        )
        : Expanded(
          child: RichText(
            textDirection:
            LanguageManager.getTextDirection(),
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: text, style: TextStyle(fontSize: 13.5, color: Colors.black)),
                TextSpan(text: secondTextColored,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Converter.hexToColor('#4D8AF0'),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  createCircleSvgButton(String svgName, String text, onTap, ) {
    return SplashEffect(
      onTap: onTap,
      color: Converter.hexToColor('#D7D7E6'),
      showShadow: false,
      fullMargin: EdgeInsets.only(bottom: 7, left: 5),
      child: Container(
        height: 35,
        width: 35,
        alignment: Alignment.center,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 3),
              SvgPicture.asset("assets/icons/$svgName.svg",width: 16, height: 16,),
              Text(text, style: TextStyle(fontSize: svgName == 'like'? 8 :7 , color: Converter.hexToColor('#218BB8'), height: 1.5, fontWeight: FontWeight.bold)),
              svgName.toString().contains('like')? Container() : Container(height: 5),
            ]),
      ),
    );
  }

  void addDeleteFavourite(item, {bool isLiked = false}) {

    if (!UserManager.checkLogin()) {
      Alert.show(context, LanguageManager.getText(298),
          premieryText: LanguageManager.getText(30),
          onYes: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
          }, onYesShowSecondBtn: false);
      return;
    }

    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "services/${isLiked? 'delete': 'add'}/favourite",context, (r) { // orders/set
      if (r['state'] == true) {
        Alert.endLoading(context2: context);
        if(!isLiked)
          Alert.show(context, Converter.getRealText(448),
              onYesShowSecondBtn: false,
              premieryText: Converter.getRealText(300),
              onYes: () {
                Navigator.of(context).pop(true);
                Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'UserFavoriteServices'), builder: (_) => UserFavoriteServices()));
              });
        setState(() {
          item['is_i_Liked'] = !isLiked;
          item['favourites'] = r['data']['count_liked'].toString() ?? 0;
        });
      }
    }, body: {
      'user_id' : UserManager.currentUser('id'),
      'provider_service_id' : item['id'].toString(),
    });

  }

}
