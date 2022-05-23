import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';

import '../Components/Alert.dart';
import '../Components/CustomSwitchStateless.dart';
import '../Components/PhoneCall.dart';
import '../Components/RateStarsStateless.dart';
import '../Components/SplashEffect.dart';
import '../Models/ShareManager.dart';
import 'Offers.dart';
import 'Orders.dart';
import 'ProviderProfile.dart';
import 'ServicePage.dart';

class UserFavoriteServices extends StatefulWidget {
  @override
  _UserFavoriteServicesState createState() => _UserFavoriteServicesState();
}

class _UserFavoriteServicesState extends State<UserFavoriteServices> {
  List data = [];
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
    NetworkManager.httpPost(Globals.baseUrl + "services/my/favourite", context, (r) {// product/load?page=$page&type=favorit
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
        });
      }
    },body: {'user_id':UserManager.currentUser('id')});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TitleBar(() {Navigator.pop(context);}, 39),
          Expanded(
            child: getServices(),
          )
        ],
      ),
    );
  }

  Widget getServices() {
    List<Widget> items = [];
      for (var i = 0; i < data.length; i++) {
        var item = data[i];
        if(item['service_id'] != 6)
          items.add(createServiceItem(item));
        else
          items.add(createServiceItemOnline(item));
    }

    if (items.length == 0 && isLoading) {
      return Container(
        alignment: Alignment.center,
        child: CustomLoading(),
      );
    } else if (items.length == 0 && data.length == 0 && !isLoading) {
      return EmptyPage("Loving", 449);
    }

    return Recycler(
      children: items,
      onScrollDown: () {
        // if (!isLoading) {
        //   if (data.length > 0 && data.length == 0) return;
        //   load();
        // }
      },
    );
  }

  Widget createServiceItem(item) {

    List cct   =
    (item != null && (item as Map).isNotEmpty && (item as Map).containsKey('country_city_street') && item['country_city_street'] != null)
        ? item['country_city_street']           .split('-').map(int.parse).toList()
        : [0,0,0];
    List cssss =
    (item != null && (item as Map).isNotEmpty && (item as Map).containsKey('cat_subcat_sub1_sub2_sub3_sub4') && item['cat_subcat_sub1_sub2_sub3_sub4'] != null)
        ? item['cat_subcat_sub1_sub2_sub3_sub4'].split('-').map(int.parse).toList()
        : [0,0,0,0,0];

    //print('here_cct: $cct, cssss: $cssss');

    return Container(
      padding: EdgeInsets.only(top:4, right: 4, left: 4, bottom: 4),
      margin:  EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Colors.black.withAlpha(15), spreadRadius: 2, blurRadius: 2)
      ], borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: InkWell(
        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => ServicePage(item['id'], serviceId: item['service_id']))),
        child: Column(
          children: [
            Container(
                width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                color: Converter.hexToColor('#218BB8'),
              ),
              child: Text(
                item['service_name'],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                textDirection: LanguageManager.getTextDirection(),
              ),
            ),
            Container(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(
                  width: 125,
                  height: 150,
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
                          image: CachedNetworkImageProvider(
                              Globals.correctLink(item['thumbnail']))),
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
                              child: SplashEffect(
                                onTap: ()=> goToProviderProfilePage(item),
                                showShadow: false,
                                child: Text(
                                  item['provider_just_name'].toString(),
                                  textDirection: LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      color: Converter.hexToColor("#2094CD"),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(.25),
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                          spreadRadius: 2,
                                        ),
                                      ]),
                                ),
                              ),
                            ),
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
                                style: TextStyle(
                                    fontWeight: FontWeight.normal, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        // specializ
                        createItemSvgText('person', 19, 18, LanguageManager.getText(270) + ":  " +
                            (Globals.checkNullOrEmpty(item['specializ'].toString()) ? item['specializ'].toString() : Converter.getRealText(326)),),
                        // brand
                        createItemSvgText('dynamic_feed', 15, 14, LanguageManager.getText(310) + ":  " +
                            (Globals.checkNullOrEmpty(item['brand'].toString()) ? item['brand'].toString() : Converter.getRealText(112)),),
                        // Service type
                        createItemSvgText('build', 15, 15, LanguageManager.getText(200) + ":  " +
                            (
                                Globals.checkNullOrEmpty(item['type'].toString())
                                    ? item['type'].toString()
                                    :
                                Globals.checkNullOrEmpty(item['provider_services_title'].toString())
                                    ? item['provider_services_title'].toString()
                                    : getServiceName(cssss, item)),
                        ),
                        // location
                        Globals.checkNullOrEmpty(item['city_name']) || Globals.checkNullOrEmpty(item['country_name']) || Globals.checkNullOrEmpty(getCCT(cct, item)) ?
                        createItemSvgText('pin_drop', 13, 16, LanguageManager.getText(244) + ":  ",
                            secondTextColored: getLocationText(item, cct))
                            : Container(),
                        Container(height: 2),
                        // go to profile
                        SplashEffect(
                          onTap: ()=> goToProviderProfilePage(item),
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
                      }) : Container(),
                ]),
              ],
            ),
            Container(height: 15),
            Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(width: 16),
                item['phone'].toString().isEmpty || item['phone'].toString().toLowerCase() == 'null' ? Container()
                    : Expanded(
                  child: InkWell(
                    onTap: () => PhoneCall.call(item['phone'], context,
                        showDirectOrderButton: true, onTapDirect: () {
                          createDirectOrder(item);
                        }),
                    // child: Column(
                    //   children: [
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
                    //     Text(
                    //       LanguageManager.getText(isSubscribe ? 358 : 348),
                    //       style: TextStyle(
                    //           color: isSubscribe ? Colors.green : Colors.black,
                    //           fontSize: 10,
                    //           fontWeight: FontWeight.w600),
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
                item['phone'].toString().isEmpty || item['phone'].toString().toLowerCase() == 'null' ? Container() : Container(width: 5),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      createDirectOrder(item);
                    },
                    //onTap: () => Globals.startNewConversation(item['provider_id'], context, active: item['active'].toString()),
                    // child: Column(
                    //   children: [
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
                            LanguageManager.getText(404), //117
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
                    //     Text(
                    //       LanguageManager.getText(348),
                    //       style: TextStyle(
                    //           color: Colors.transparent,
                    //           fontSize: 10,
                    //           fontWeight: FontWeight.w600),
                    //     ),
                    //   ],
                    // ),
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
    // ? Container(
    //   width: 85,
    //   height: 125,
    //   margin: !LanguageManager.getDirection()? EdgeInsets.only(left: 22, top: 145) : EdgeInsets.only(right: 22, top: 145),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Container(
    //         padding: EdgeInsets.all(1),
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(5),
    //             color:  Converter.hexToColor("#ffffff"),
    //             boxShadow: [
    //             BoxShadow(
    //                 color: Colors.black.withAlpha(45),
    //                 spreadRadius: 1,
    //                 blurRadius: 7)
    //           ]),
    //            child: Stack(
    //              children: [
    //                CachedNetworkImage(imageUrl:Globals.correctLink(item['quick_offer']['image'])),
    //                new Positioned.fill(
    //                    child: new Material(
    //                        color: Colors.transparent,
    //                        child: new InkWell(
    //                          splashColor: Colors.white70,
    //                          onTap: () => showAlertQuickOffer(item['quick_offer'], item['provider_id'], item['active'], item),
    //                        ))),
    //              ],
    //            ),
    //       ),
    //
    //     ],
    //   ),
    // ): Container(),
  }

  Widget createServiceItemOnline(item) {
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
      padding: EdgeInsets.only(top: 4, right: 4, left: 4, bottom: 4),
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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                color: Converter.hexToColor('#218BB8'),
              ),
              child: Text(
                item['service_name'],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                textDirection: LanguageManager.getTextDirection(),
              ),
            ),
            Container(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(
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
                                      ?item['provider_services_title'].toString() : getServiceName(cssss, item)),
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

  goToProviderProfilePage(item) {
    if (item['provider_id'] == null) return;
    Navigator.push(context, MaterialPageRoute(
        settings: RouteSettings(name: 'ProviderProfile'),
        builder: (_) => ProviderProfile(
          item['provider_id'].toString(),
          providerServiceId: item['id'].toString(),
          serviceId: item['service_id'].toString(),
          active: item['active'].toString(),
        )));
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

  String getServiceName(List cssss, item){ // الخدمات
    if(item['title_from'] == 0) return '';
    for(int i = 0; i< cssss.length;i++){
      if(cssss[i] == 1 && (item['title_from'] - 2) == i)
        return Converter.getRealText(327) + ' ' + item['service_name']; //جميع خدمات
    }
    return Converter.getRealText(327) + ' ' + item['service_name']; // return '';
  }

  getLocationText(item, cct) {
    return (Globals.checkNullOrEmpty(getCCT(cct, item))
        ? getCCT(cct, item)

        : Globals.checkNullOrEmpty(item['city_name'])
        ? item['street_name'].toString().isEmpty
        ? (Globals.checkNullOrEmpty(getCCT([0,0,1], item)) ? getCCT([0,0,1], item) : "")
        : (item['city_name'].toString()  + "  -  " + item['street_name'].toString())

        : Globals.checkNullOrEmpty( item['country_name'].toString())
        ? getCCT([0,1,0] , {'country_name': item['country_name'].toString()})
        : getCCT([0,1,0] , {'country_name': item['country_name'].toString()}));
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
    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "services/${isLiked? 'delete': 'add'}/favourite",context, (r) { // orders/set
      if (r['state'] == true) {
        Alert.endLoading(context2: context);
        // if(!isLiked)
        //   Alert.show(context, Converter.getRealText(448),
        //       onYesShowSecondBtn: false,
        //       premieryText: Converter.getRealText(300),
        //       onYes: () {
        //         Navigator.of(context).pop(true);
        //         Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'UserFavoriteServices'), builder: (_) => UserFavoriteServices()));
        //       });
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

  void createDirectOrder(item, {bool isQuickOffer = false}) {
    Alert.show(context, LanguageManager.getText(422),// شكرا على ثقتك بي\nأكد طلبك لاتمكن من خدمتك
        premieryText: LanguageManager.getText(21), // تأكيد
        secondaryText: LanguageManager.getText(172), // تراجع
        onYes: () {
          Navigator.pop(context);
          Map<String, String> body = {
            "provider_id"           : item['provider_id'].toString(),
            "service_id"            : item['service_id'].toString(),
            "provider_service_id"   : item['id'].toString()
          };
          if(isQuickOffer){
            body['quick_offer_id'] = item['quick_offer']['id'].toString();
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
