import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/RateStarsStateless.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Components/PhoneCall.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'FeatureSubscribe.dart';
import 'Login.dart';
import 'OpenImage.dart';
import 'Orders.dart';

class ProviderProfile extends StatefulWidget {
  final String  providerId;
  final String  serviceId;
  final String  providerServiceId;
  final String  active;
  const ProviderProfile(this.providerId, {this.serviceId = '0' , this.providerServiceId = '0', this.active = 'false'});

  @override
  _ProviderProfileState createState() => _ProviderProfileState();
}

class _ProviderProfileState extends State<ProviderProfile> with WidgetsBindingObserver {
  Map data = {}, social = {}, rate = {};
  List skills = [];
  bool isIncrement = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
        load();
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('here_resumed_from: ProviderProfile');
      load();
    }
  }

  void load() {
    NetworkManager.httpGet(Globals.baseUrl + "provider/profile/${widget.providerId}", context, (r) {
      if (r['state'] == true) {
        setState(() {
          data = r['data']['user'] ?? {};
          rate = r['data']['rate'] ?? {};
          skills = r['data']['skills'] ?? [];

          if(r['data']['user']['social_media_links'].runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>')
            social = r['data']['user']['social_media_links'] ?? {};
          else
            social = json.decode(r['data']['user']['social_media_links']) ?? {};

        });
        if(!isIncrement) {
          isIncrement = true;
          incrementViewer();
        }
      }
    }, cashable: true);
  }
  void incrementViewer() {
    NetworkManager.httpGet(Globals.baseUrl + "provider/increment/${widget.providerId}", context, (r) {}, cashable: false);
  }

  @override
  Widget build(BuildContext context) {
    if(data.isEmpty) return SafeArea(child: Scaffold(body: Center(child: CustomLoading())));
    return SafeArea(
      child: Scaffold(
          body: Column(
              textDirection: LanguageManager.getTextDirection(),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Expanded(
                child: ScrollConfiguration(
              behavior: CustomBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Row(
                      textDirection: LanguageManager.getTextDirection(),
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            margin: EdgeInsets.all(20),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Converter.hexToColor(data['active'] == 1? '#00A85F' : '#FF0000'),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              LanguageManager.getText(data['active'] == 1 ? 100 : 101),
                              style: TextStyle(
                                color: Converter.hexToColor(data['active'] == 1? '#00A85F' : '#FF0000'),
                              ),
                            )),
                      ],
                    ),
                    SplashEffect(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OpenImage(url: (data['avatar'] as String)))),
                      showShadow: false,
                      borderRadius: false,
                      child: Container(
                        width: 143,
                        height: 143,
                        alignment: LanguageManager.getDirection()
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Converter.hexToColor('#2094CD'),
                            width: 3,
                          ),
                          image: DecorationImage(image: CachedNetworkImageProvider(Globals.correctLink(data['avatar']))),
                        ),
                        child:
                        data['verified'] == true || data['verified'] == 1
                        ?
                        Container(
                          width: 28,
                          height: 28,
                          margin: EdgeInsets.all(5),
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
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.all(16),
                        child: Text(
                          data['username'] ?? '',
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                            color: Converter.hexToColor('#344F64'),
                            fontSize: 20,
                          ),
                        ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .15),
                        child: Text(
                          data['about'] ?? '',
                          textDirection: LanguageManager.getTextDirection(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Converter.hexToColor('#707070'),
                            fontSize: 12,
                          ),
                        ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: LanguageManager.getTextDirection(),
                        children: [
                          SplashEffect(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 23, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                textDirection: LanguageManager.getTextDirection(),
                                children: [
                                  Icon(
                                    FlutterIcons.phone_faw,
                                    size: 18,
                                  ),
                                  Container(width: 5),
                                  Text(
                                    LanguageManager.getText(423), //اتصل بالمزود
                                    textDirection: LanguageManager.getTextDirection(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            onTap: ()=> PhoneCall.call(data['number_phone'], context,
                                isOnlineService: widget.serviceId == '0',
                              showDirectOrderButton: widget.serviceId != '0',
                              onTapDirect: (){createDirectOrder();}
                            ),
                            color: Converter.hexToColor('#00F8BD'),
                          ),
                          Container(width: 21),
                          SplashEffect(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 29, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                textDirection: LanguageManager.getTextDirection(),
                                children: [
                                  Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  Container(width: 5),
                                  Text(
                                    LanguageManager.getText(widget.serviceId == '0'? 117 : 404),
                                    textDirection: LanguageManager.getTextDirection(),
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if(widget.serviceId == '0')
                                Globals.startNewConversation(widget.providerId, context, active: widget.active);
                              else
                                createDirectOrder();},
                            color: Converter.hexToColor('#2094CD'),
                          ),
                        ],
                      ),
                    ),
                    // social['instagram'] == null && social['twitter'] == null && social['facebook'] == null && social['telegram'] == null ?
                    // Container():
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 25),
                      child: Row(
                        textDirection: LanguageManager.getReversTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // social['instagram'] == null ? Container() :
                          SplashEffect(
                            margin: 5,
                            showShadow: false,
                            onTap: () async { await _launchURL('instagram');},
                            child: Icon(
                              FlutterIcons.instagram_ant,
                              color: Converter.hexToColor(social['instagram'] != null? '#F56040' : '#74767E'),
                              size: 28,
                            ),
                          ),
                          // social['instagram'] == null ? Container() :
                          Container(width: 36),
                          // social['twitter'] == null ? Container() :
                          SplashEffect(
                            margin: 5,
                            showShadow: false,
                            onTap: () async{ await _launchURL('twitter');},
                            child: Icon(
                              FlutterIcons.twitter_ant,
                              color: Converter.hexToColor(social['twitter'] != null? '#1DA1F2' : '#74767E'),
                              size: 28,
                            ),
                          ),
                          // social['twitter'] == null ? Container() :
                          Container(width: 36),
                          // social['facebook'] == null ? Container() :
                          SplashEffect(
                            margin: 5,
                            showShadow: false,
                            color: Converter.hexToColor(social['facebook'] != null? '#4267B2' : '#74767E'),
                            padding: EdgeInsets.only(top:28, right: 8.5,left: 8.5),
                            onTap: () async{ await _launchURL('facebook');},
                            child: Text('f', style: TextStyle(color: Colors.white, fontSize: 30, height: 0.01, fontWeight: FontWeight.bold),),
                          ),
                          // social['facebook'] == null ? Container() :
                          Container(width: 36),
                          // social['telegram'] == null ? Container() :
                          SplashEffect(
                            margin: 5,
                            showShadow: false,
                            onTap: () async{ await _launchURL('telegram');},
                            child: Icon(
                              FontAwesome5Brands.telegram_plane,
                              color: Converter.hexToColor(social['telegram'] != null? '#229ED9' : '#74767E'),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // social['instagram'] == null && social['twitter'] == null && social['facebook'] == null && social['telegram'] == null ?
                    // Container() :
                    Container(height: 20),
                    createTwoTextInRow(393, rate['total'].toString() ?? '', widget:
                        RateStarsStateless(11, stars: rate['stars'] ?? 5, spacing: .5, height: 13), // التقييمات
                    ), createUnderLine(),
                    createTwoTextInRow(394, data['services_count'].toString() ?? '0'), createUnderLine(), // الخدمات المنشورة
                    createTwoTextInRow(395, data['orders_completed'].toString() ?? '0'), createUnderLine(), // طلبات مكتملة
                    createTwoTextInRow(396, data['orders_pending'].toString() ?? '0'), createUnderLine(), // طلبات جاري تنفيذها
                    createTwoTextInRow(397, data['created_at'].toString().split(' ')[0] ?? ''), createUnderLine(), // تاريخ التسجيل
                    createTwoTextInRow(398, data['country_name'] ?? ''), // الدولة

                    skills.isEmpty ? Container() :
                    Container(
                      height: 1,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 35,right: 25, top: 30, bottom: 20),
                      color: Converter.hexToColor('#dfdfdf'),
                    ),
                    skills.isEmpty ? Container() :
                    Row(
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Container(width: 32),
                        Text(
                            LanguageManager.getText(401),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(fontSize: 20, color: Converter.hexToColor('#2094CD'))),
                      ],
                    ),
                    skills.isEmpty ? Container() :
                    Container(height: 10),
                    skills.isEmpty ? Container() :
                    Wrap(
                        textDirection: LanguageManager.getTextDirection(),
                        children: List<Widget>.generate(skills.length, (index) {
                          return createItemSkill(skills[index][LanguageManager.getDirection() ? 'name' : 'name_en']);
                        })
                    ),


                    Container(
                      height: 1,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 35,right: 25, top: 30, bottom: 20),
                      color: Converter.hexToColor('#dfdfdf'),
                    ),
                    Row(
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Container(width: 32),
                        Text(
                            LanguageManager.getText(399),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(fontSize: 20, color: Converter.hexToColor('#2094CD'))),
                      ],
                    ),
                    Container(height: 10),
                    createItemIsTrust(195, data['email_verified']),Container(height: 5),
                    createItemIsTrust(6  , data['phone_verified']),Container(height: 5),
                    createItemIsTrust(400, data['identity_verified']),Container(height: 5),

                    Container(height: 50)
                  ],
                ),
              ),
            )),
          ])),
    );
  }

  createTwoTextInRow(int textIndex, String str2, {Widget widget}) {
    return Row(
      textDirection: LanguageManager.getTextDirection(),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 42),
        Text(
            LanguageManager.getText(textIndex),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(fontSize: 17, color: Converter.hexToColor('#707070'))),
        Expanded(child: Container()),
        widget == null ?
        Text(
            str2,
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(fontSize: 17, color: Converter.hexToColor('#707070'))) :
        Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            widget,
            Container(width: 7),
            Text(
                str2,
                textDirection: LanguageManager.getTextDirection(),
                style: TextStyle(fontSize: 17, color: Converter.hexToColor('#707070'))),
              ]),
        Container(width: 42),
      ],
    );

  }

  createUnderLine() {
    return Container(
      height: 1,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      color: Converter.hexToColor('#efefef'),
    );
  }

  createItemIsTrust(int textIndex, isTrust) {
    return Row(
      textDirection: LanguageManager.getTextDirection(),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 32),
        Text(
            LanguageManager.getText(textIndex),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(fontSize: 17, color: Converter.hexToColor('#707070'))),
        Expanded(child: Container()),
        isTrust == 1 || isTrust == true
        ? Icon(Foundation.check, color: Converter.hexToColor('#52B035'), size: 17,)
        : Icon(Feather.x, color: Colors.red, size: 17,),
        Container(width: 37),
      ],
    );
  }

  createItemSkill(String str) {
    return Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Converter.hexToColor('#707070'),
            width: 1,
          ),
        ),
        child: Text(str, style: TextStyle(color: Colors.black, fontSize: 14),
        ));
  }

  Future<void> _launchURL(String str) async {
    if(social.isEmpty || (social.isNotEmpty && social[str] == null)){
      Alert.show(context, LanguageManager.getText(402));
      return;
    }

    if(UserManager.currentUser("id").isEmpty) {
      Alert.show(context, LanguageManager.getText(298), // عليك تسجيل الدخول أولاً
          premieryText: LanguageManager.getText(30), onYes: () {//تسجيل الدخول
            Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
          }, onYesShowSecondBtn: false);
      return;
    }

    if (!UserManager.isSubscribe()){
      Alert.show(context, LanguageManager.getText(415), //خدمة الحصول على حسابات التواصل الإجتماعي للمزودين مخصصة للمشتركين فقط, يمكنك الإشتراك بالتطبيق
          premieryText: LanguageManager.getText(75), onYes: () { //الإشتراك بالتطبيق
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => FeatureSubscribe()));
          }, onYesShowSecondBtn: false);
      return;
    }

     launch(Uri.encodeFull(social[str]));
  }

  void createDirectOrder() {
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
            "provider_id"           : widget.providerId,
            "service_id"            : widget.serviceId,
            "provider_service_id"   : widget.providerServiceId
          };
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
