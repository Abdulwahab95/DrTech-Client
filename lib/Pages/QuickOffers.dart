import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../Components/Alert.dart';
import '../Components/SoonWidget.dart';
import 'Login.dart';
import 'Orders.dart';


class QuickOffers extends StatefulWidget {
  final String serviceId;
  final bool isOnlineServices;
  QuickOffers(this.serviceId, {this.isOnlineServices = false});

  @override
  _QuickOffersState createState() =>
      _QuickOffersState();
}

class _QuickOffersState extends State<QuickOffers> {
  Map<String, String> filters = {};
  Map data = {}, selectedCity = {};
  bool isLoading = false, visibleCities = false;
  bool isSubscribe = UserManager.isSubscribe();

  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    if(filters.isEmpty && UserManager.currentUser('country_id').isNotEmpty)
      filters['country_id_with_null'] = UserManager.currentUser('country_id');

    if(widget.isOnlineServices)
      filters['isOnline'] = 'true';

    setState(() {
      isLoading = true;
    });

    NetworkManager.httpPost(Globals.baseUrl + "quick/offers/${widget.serviceId}",  context, (r) { // user/service?id=${widget.id}
      setState(() {isLoading = false;});
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
          if(selectedCity.isEmpty) selectedCity = data['cities'][0]?? {};
          filters = {};
        });
      }
    },body: filters);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Stack(
          alignment : AlignmentDirectional.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              textDirection: LanguageManager.getTextDirection(),
              children: [
                TitleBar((){Navigator.pop(context);}, LanguageManager.getText(354), withoutBell: true), // عروض هذه الخدمة
                showFilterCity()? Container() : Container(height: 20),
                showFilterCity()? Container() :
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(width: 16),
                    Text(
                        LanguageManager.getText(447),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Converter.hexToColor('#4D8AF0')),
                      ),
                  ],
                ),
                showFilterCity()? Container() :
                GestureDetector(
                  onTap: ()=> setState(() {visibleCities = !visibleCities;}),
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    padding: EdgeInsets.only(left: 7, right: 7),
                    decoration: BoxDecoration(
                        color: Converter.hexToColor("#F2F2F2"),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Expanded(
                            child: Text(
                              selectedCity['name'] ?? '',
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: selectedCity['name'] != 'الكل' ? Colors.black : Colors.grey),
                            )),
                        Icon(
                          FlutterIcons.chevron_down_fea,
                          color: Converter.hexToColor("#727272"),
                          size: 22,
                        )
                      ],
                    ),
                  ),
                ),
                isLoading
                    ? Expanded(child: Center(child: CustomLoading()))
                    : Expanded(child: Container(child: getBodyContents())),
              ],
            ),
            visibleCities ? InkWell(
              onTap: ()=> setState(() {visibleCities = !visibleCities;}),
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .28, right: 20, left: 20), //238
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(20),
                                spreadRadius: 5,
                                blurRadius: 5)
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: getListOptions(),
                      ),
                    ),
                  ],
                ),
              ),
            ) : Container(height: 1),
          ],
        ));
  }

  Widget getBodyContents() {
    List<Widget> items = [];

    if(data['quick_offers'].length == 0 && (selectedCity.isEmpty || selectedCity['id'].toString() == '0')){
      return SoonWidget();
    }

    int i = 0;
    for (var item in data['quick_offers']) {
      items.add(createItem(item, ++i));
    }

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 5),
      children: items,
    );
  }

  Widget createItem(item, int i) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [BoxShadow(
            color: Colors.black.withAlpha(15),
            spreadRadius: 2,
            blurRadius: 2)],
      ),
      child: Column(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              '${item['provider_name']?? ''}' + (item['show_location'].toString() == 'true' ? '  (${getLocationText(item)})' : ''),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  fontSize: 16,
                  color: Converter.hexToColor("#2094CD"),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 160,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(
                        Globals.correctLink(item['image']))),
                borderRadius: BorderRadius.circular(10),
                color: Converter.hexToColor("#F2F2F2"),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10,right: 10, left: 10 ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item['body'] ?? '',
                    textDirection: LanguageManager.getTextDirection(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 15),
          SplashEffect(
            onTap: ()=> createDirectOrder(item, isQuickOffer: true),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              LanguageManager.getText(446), // اطلب العرض
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            color: Converter.hexToColor("#344f64"),
            boxShadow: [BoxShadow(
                color: Colors.black.withAlpha(15),
                spreadRadius: 2,
                blurRadius: 2)],
            borderRadius: true,
            radius: 8,
          ),
          Container(height: 15),
        ],
      ),
    );
  }

  getLocationText(item) {
    List cct   =
    (item != null && (item as Map).isNotEmpty && (item as Map).containsKey('country_city_street') && item['country_city_street'] != null)
        ? item['country_city_street'].split('-').map(int.parse).toList()
        : [0,0,0];

    return (Globals.checkNullOrEmpty(getCCT(cct, item))
        ? getCCT(cct, item)

        : Globals.checkNullOrEmpty(item['city'])
        ? item['street'].toString().isEmpty
        ? (Globals.checkNullOrEmpty(getCCT([0,0,1], item)) ? getCCT([0,0,1], item) : "")
        : (item['city'].toString()  + "  -  " + item['street'].toString())

        : Globals.checkNullOrEmpty( item['country'].toString())
        ? getCCT([0,1,0] , {'country': item['country'].toString()})
        : getCCT([0,1,0] , {'country': item['country'].toString()}));
  }

  String getCCT(List cct, item){
    if(cct[0] == 1){
      print('here: cct[0] == 1');
      return Converter.getRealText(324); // في جميع فروعنا العالمية لدكتورتك
    } else if(cct[1] == 1){
      print('here: cct[1] == 1');
      return Converter.getRealText(325) + ' ' + item['country']; // في جميع أنحاء
    } else if(cct[2] == 1){
      print('here: cct[2] == 1: ${Converter.getRealText(325)}');
      return (Converter.getRealText(325) + ' ' + item['city']); // في جميع أنحاء
    }
    return '';
  }

  showFilterCity() {
    return isLoading && !data.containsKey('cities') || (data.containsKey('cities') && (data['cities'] as List).length <= 1);
  }

  List<Widget> getListOptions() {
    List<Widget> contents = [];

    for (var item in data['cities']) {
      contents.add(InkWell(
        onTap: () {
          filters = {};
          setState(() {
            visibleCities = false;
          });

          // print('here_Alert_selected_text: ${item.runtimeType}, ${selectedCity.runtimeType}, ${selectedCity == item}');
          if(selectedCity['id'].toString() == item['id'].toString())
            return;

          // print('here_Alert_selected_text: $item, $selectedCity, $filters');
          selectedCity = item;
          if(item['id'].toString() != '0') {
            filters['city_id'] = item['id'].toString();
            // print('here_Alert_selected_text: $item, $selectedCity, $filters');
            load();
          }else{
            load();
          }
        },
        child: Container(
          height: 40,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black.withAlpha(5),
          ),
          child: Text(
            Converter.getRealText(item['name']),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ),
      ));
    }

    return contents;
  }

  void createDirectOrder(item, {bool isQuickOffer = false}) {
    if (!UserManager.checkLogin()) {
      Alert.show(context, LanguageManager.getText(298),
          premieryText: LanguageManager.getText(30),
          onYes: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
          }, onYesShowSecondBtn: false);
      return;
    }

    Alert.show(context, LanguageManager.getText(422),// شكرا على ثقتك بي\nأكد طلبك لاتمكن من خدمتك
        premieryText: LanguageManager.getText(21), // تأكيد
        secondaryText: LanguageManager.getText(172), // تراجع
        onYes: () {
          Navigator.pop(context);
          Map<String, String> body = {
            "provider_id"           : item['provider_id'].toString(),
            "service_id"            : widget.serviceId.toString(),
            "provider_service_id"   : item['provider_service_id'].toString()
          };
          if(widget.isOnlineServices) {
            body['is_online_services'] = 'true';
            body['service_categories_id'] = item['service_categories_id'].toString();
          }
      if(isQuickOffer){
            body['quick_offer_id'] = item['quick_offer_id'].toString();
          }
          Alert.startLoading(context);
          NetworkManager.httpPost(Globals.baseUrl + "orders/create/direct",context, (r) { // orders/set
            if (r['state'] == true) {
              Alert.endLoading(context2: context);
              Alert.show(context, Converter.getRealText(r['data'] is int? r['data'] : 299),
                  onYesShowSecondBtn: false,
                  premieryText: Converter.getRealText(300),
                  onYes: () {
                    Navigator.of(context).pop(true);
                    Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'Orders'), builder: (_) => Orders()));
                  });
            }
          }, body: body);
        }, onClickSecond: (){
          Navigator.pop(context);
        });
  }

}
