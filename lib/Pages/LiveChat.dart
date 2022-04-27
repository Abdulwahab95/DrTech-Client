import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/BrokenPage.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/PaymentOptions.dart';
import 'package:dr_tech/Components/PhoneCall.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Conversations.dart';
import 'OpenImage.dart';

class LiveChat extends StatefulWidget {
  final String id;
  final String openSendMessage;
  LiveChat(this.id, {this.openSendMessage = ''}) {
    LiveChat.currentConversationId = this.id;
  }

  @override
  _LiveChatState createState() => _LiveChatState();

  static String currentConversationId;
  static Function callback;
}

class _LiveChatState extends State<LiveChat>  with WidgetsBindingObserver {
  Map user = {}, data = {}, body = {}, offer = {};
  Map<int, Uint8List> images = {};
  Map<int, bool> files = {};
  String promoCode = "";
  bool isLoading = false,
      visibleoptions = false,
      isOpenPicks = false,
      isTyping = false,
      typingNotifyer = false;
  Timer timer;
  Widget ui;
  int page = 0;
  TextEditingController controller = TextEditingController();
  ScrollController scroller = ScrollController();
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    LiveChat.callback = onReciveNotic;
    load();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LiveChat.currentConversationId = null;
    LiveChat.callback = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      load();
    }
  }

  void onReciveNotic(payloadTarget, paylaod) {
    // Globals.printTel('here_timer: onReciveNotic');
    if (payloadTarget == null) return;
    switch (payloadTarget) {
      case "chat":
        // Globals.printTel('here_timer: case chat');
        chatDataNotic(paylaod);
        break;
      case "info":
        // Globals.printTel('here_timer: case infor');
        infoDataNotic(paylaod);
        break;
      default:
    }
  }

  void infoDataNotic(payload) {

    print('here_timer: type: ${payload['type']}, payload: $payload');
    switch (payload['type']) {
      case "offer":
        print('here_timer: case offer');

        for (var page in data.keys) {
          for (var i = 0; i < data[page].length; i++) {
            //print('here_timer_id_payload: ${data[page][i]["id"].toString()}, ${payload["message_id"]}');
            if (data[page][i]["id"].toString() == payload["message_id"].toString()) {
              if (data[page][i]["message"].runtimeType != String)
                setState(() {
                  data[page][i]["message"]['status'] = payload["status"];
                });
              break;
            }
          }
        }
        break;
      case "seen":
        // if (payload['id'] == "all") {
          for (var i = 0; i < data[data.keys.last].length; i++) {
            // if (data[data.keys.last][i]["send_by"].toString() == UserManager.currentUser("id").toString()) {
              setState(() {
                data[data.keys.last][i]["seen"] = 1;
              });
            // }
          }
        // } else
        //   for (var i = 0; i < data[data.keys.last].length; i++) {
        //     if (data[data.keys.last][i]["id"].toString() ==
        //         payload['id'].toString()) {
        //       setState(() {
        //         data[data.keys.last][i]["seen"] = 1;
        //       });
        //       break;
        //     }
        //   }
        break;
      default:
    }
  }

  void chatDataNotic(payload) {
    // Globals.printTel('here_timer: chatDataNotic $payload');
    if (payload['text'] == 'USER_TYPING') {
      // Globals.printTel('here_timer: USER_TYPING');
      setState(() {
        isTyping = true;
      });
      if (timer != null) timer.cancel();
      timer = Timer(Duration(seconds: 5), () {
        if (!mounted) return;
        setState(() {
          isTyping = false;
        });
      });
      return;
    }

    AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/received.mp3"));
    setState(() {
      isTyping = false;
      data.values.last.add(payload);
      scrollDown();
      sendSeenFlag();// sendSeenFlag(paylaod['id'].toString());
    });
  }

  void scrollDown() {
    if (scroller.offset < 100)
      scroller.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpPost(Globals.baseUrl + "convertation", context ,(r) { // "chat/load?conversation_id=" + widget.id.toString() + "&page=" + page.toString()
      try {
        if (r["state"] == true) {
          setState(() {
            isLoading = false;

            data['0'] = r['data']['convertation']; // r['page']
            user = r['data']['with'];

          });
          sendSeenFlag();
        } else {
          setState(() {
            ui = BrokenPage(load);
          });
        }
      } catch (e) {
        setState(() {
          ui = BrokenPage(load);
        });
      }
    }, cachable: true, body: {"user_id":UserManager.currentUser('id'),"provider_id":widget.id.toString() });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _close,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Column(children: [
                Container(
                    decoration: BoxDecoration(color: Converter.hexToColor("#2094cd")),
                    padding:
                        EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            left: LanguageManager.getDirection()?25:0,
                            right: LanguageManager.getDirection()?0:25,
                            bottom: 10, top: 15),
                        child: Row(
                          textDirection: LanguageManager.getTextDirection(),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: _close,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: LanguageManager.getDirection()?0:25,
                                    right: LanguageManager.getDirection()?25:0,
                                  ),
                                  child: Icon(
                                    LanguageManager.getDirection()
                                        ? FlutterIcons.chevron_right_fea
                                        : FlutterIcons.chevron_left_fea,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )),
                            Container(width: 25),
                            Expanded(
                              child: Text(
                                isTyping
                                    ? LanguageManager.getText(84)
                                    : user.isNotEmpty
                                        ? user["username"]??''
                                        : "",
                                textDirection: LanguageManager.getTextDirection(),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Row(
                              textDirection: LanguageManager.getTextDirection(),
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: ()=> PhoneCall.call(user['country']['country_code'] + user['number_phone'], context),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        FlutterIcons.phone_faw,
                                        size: 24,
                                        color: Colors.white,
                                        // color: Colors.transparent,
                                        textDirection: LanguageManager.getTextDirection(),
                                      ),
                                    ),
                                  ),
                                ),
                                // Container(
                                //   width: 10,
                                // ),
                                // InkWell(
                                //   // onTap: showOptions,
                                //   child: Container(
                                //     width: 20,
                                //     child: Icon(
                                //       FlutterIcons.dots_vertical_mco,
                                //       size: 28,
                                //       // color: Colors.white,
                                //       color: Colors.transparent,
                                //       textDirection: LanguageManager.getTextDirection(),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ))),
                Expanded(
                    child: ScrollConfiguration(
                        behavior: CustomBehavior(),
                        child: ListView(
                          reverse: true,
                          controller: scroller,
                          children: getChatMessages(),
                        ))),
                getChatInput()
              ]),
              visibleoptions
                  ? InkWell(
                      onTap: showOptions,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 30),
                          alignment: !LanguageManager.getDirection()
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      spreadRadius: 5,
                                      blurRadius: 5)
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            margin: EdgeInsets.all(30),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              textDirection: LanguageManager.getTextDirection(),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      LanguageManager.getText(76),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      LanguageManager.getText(77),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      LanguageManager.getText(78),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                    )
                  : Container(),
            ],
          )),
    );
  }

  List<Widget> getChatMessages() {
    List<Widget> chat = [];
    for (var page in data.keys) {
      for (var i = 0; i < data[page].length; i++) {
        bool isFromSender = data[page][i]["send_by"].toString() == user["id"].toString();
        // TextDirection direction =
        // isFromSender ? TextDirection.ltr : TextDirection.rtl;
        chat.insert(0, getChatMessageUI(data[page][i], page, i));
      }
    }
    chat.add(getWarningMessage());
    return chat;
  }

  bool isSetOpenSendMessage = true;

  Widget getChatInput() {

    if(widget.openSendMessage.isNotEmpty && isSetOpenSendMessage) {
      isSetOpenSendMessage = false;
      controller.text = widget.openSendMessage;
      body['text'] = widget.openSendMessage;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /*  AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: isTyping ? 60 : 0,
          child: ScrollConfiguration(
            behavior: CustomBehavior(),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  textDirection: LanguageManager.getTextDirection(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Container()),
                    Container(
                      height: 35,
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      child: Text(
                        LanguageManager.getText(84),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Converter.hexToColor("#4e4e4e"),
                            fontSize: 12),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Converter.hexToColor("#F2F2F2")),
                    ),
                    Container(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),*/
        AnimatedContainer(
          color: Converter.hexToColor("#344F64"),
          duration: Duration(milliseconds: 150),
          height: isOpenPicks ? 100 : 0,
          child: ScrollConfiguration(
            behavior: CustomBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 2,
                    width: 70,
                    margin: EdgeInsets.only(top: 5, bottom: 10),
                    decoration: BoxDecoration(color: Colors.white),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      textDirection: LanguageManager.getTextDirection(),
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            print('here_tap on camera');
                            pickImage(ImageSource.camera);
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  padding: EdgeInsets.all(3),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      color: Converter.hexToColor("#344F64"),
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Converter.hexToColor("#344F64"),
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.white),
                                  ),
                                ),
                                Text(
                                  LanguageManager.getText(335),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                        // pick image
                        InkWell(
                          onTap: () {
                            print('here_tap on gallery');
                            pickImage(ImageSource.gallery);
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  padding: EdgeInsets.all(3),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      color: Converter.hexToColor("#344F64"),
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.image,
                                      color: Converter.hexToColor("#344F64"),
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.white),
                                  ),
                                ),
                                Text(
                                  LanguageManager.getText(83),
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                      // InkWell(
                      //           onTap: addPromoCode,
                      //           child: Container(
                      //             child: Column(
                      //               children: [
                      //                 Container(
                      //                   width: 50,
                      //                   height: 50,
                      //                   padding: EdgeInsets.all(3),
                      //                   alignment: Alignment.center,
                      //                   decoration: BoxDecoration(
                      //                       border: Border.all(
                      //                           color: Colors.white, width: 2),
                      //                       color:
                      //                           Converter.hexToColor("#344F64"),
                      //                       borderRadius:
                      //                           BorderRadius.circular(40)),
                      //                   child: Container(
                      //                     width: 40,
                      //                     height: 40,
                      //                     child: Icon(
                      //                       FlutterIcons.tag_ant,
                      //                       color:
                      //                           Converter.hexToColor("#344F64"),
                      //                     ),
                      //                     decoration: BoxDecoration(
                      //                         borderRadius:
                      //                             BorderRadius.circular(40),
                      //                         color: Colors.white),
                      //                   ),
                      //                 ),
                      //                 Text(
                      //                   LanguageManager.getText(82),
                      //                   style: TextStyle(color: Colors.white),
                      //                 )
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                        // File
                        InkWell(
                          onTap: () {
                            pickFile();
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  padding: EdgeInsets.all(3),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      color: Converter.hexToColor("#344F64"),
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      FlutterIcons.file_text_faw,
                                      color: Converter.hexToColor("#344F64"),
                                      size: 20,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.white),
                                  ),
                                ),
                                Text(
                                  LanguageManager.getText(81),
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Location
                        // Container(
                        //   child: Column(
                        //     children: [
                        //       Container(
                        //         width: 50,
                        //         height: 50,
                        //         padding: EdgeInsets.all(3),
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(
                        //             border: Border.all(
                        //                 color: Colors.white, width: 2),
                        //             color: Converter.hexToColor("#344F64"),
                        //             borderRadius: BorderRadius.circular(40)),
                        //         child: Container(
                        //           width: 40,
                        //           height: 40,
                        //           child: Icon(
                        //             Icons.location_pin,
                        //             color: Converter.hexToColor("#344F64"),
                        //           ),
                        //           decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(40),
                        //               color: Colors.white),
                        //         ),
                        //       ),
                        //       Text(
                        //         LanguageManager.getText(80),
                        //         style: TextStyle(color: Colors.white),
                        //       )
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          color: Converter.hexToColor("#F3F3F3"),
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 40,
                height: 50,
                alignment: Alignment.center,
                child: InkWell(
                  onTap: send,
                  child: Container(
                    width: 40,
                    height: 40,
                    padding:
                        EdgeInsets.only(left: 8, right: 5, top: 7, bottom: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Converter.hexToColor("#344F64"),
                    ),
                    child: Icon(
                      FlutterIcons.send_mco,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white),
                  child: TextField(
                    onChanged: (v) {
                      if (!typingNotifyer) {
                        sendTypingNotifyer();
                      }
                      typingNotifyer = v.isNotEmpty;
                      body['text'] = v;
                    },
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    minLines: 1,
                    textDirection: LanguageManager.getTextDirection(),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 5)),
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 50,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isOpenPicks = !isOpenPicks;
                    });
                  },
                  child: Icon(
                    FlutterIcons.plus_circle_fea,
                    color: isOpenPicks
                        ? Converter.hexToColor("#2094CD")
                        : Converter.hexToColor("#344F64"),
                    size: 36,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget getWarningMessage() {
    double width = MediaQuery.of(context).size.width * 0.9;
    width = width > 400 ? 400 : width;
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: width,
        padding: EdgeInsets.all(15),
        color: Converter.hexToColor("#FEF4C5"),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: 30,
              margin: EdgeInsets.only(top: 5),
              child: Icon(
                FlutterIcons.lock_faw,
                color: Converter.hexToColor("#707070"),
              ),
            ),
            Container(
              width: 10,
            ),
            Expanded(
              child: Text(
                LanguageManager.getText(79),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Converter.hexToColor("#707070"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getChatMessageUI(item, page, index) {
    // print('here_getChatMessageUI: item: $item, page: $page, index: $index');
    if(item['type'] == 'offer' && item['message'] == null) {
      item['type'] = 'TEXT';
    }

    if(item.toString().length>0)
    switch (item["type"].toString().toUpperCase()) {
      case "TEXT":
        return getChatTextMessageUI(item);
        break;
      case "IMAGE_UPLOAD":
        return getChatImageUploadMessageUI(item);
        break;
      case "FILE_UPLOAD":
        return getChatFileUploadMessageUI(item);
        break;
      case "IMAGE":
        return getChatImageMessageUI(item);
        break;
      case "FILE":
        return getChatFileMessageUI(item);
        break;
      case "OFFER":
        return getChatOfferMessageUi(item, page, index);
        break;
      default:
    }
    return Container();
  }

  Widget getChatFileUploadMessageUI(item) {
    print('here_getChatFileUploadMessageUI: item: $item');
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                Globals.correctLink(UserManager.currentUser("avatar")))),
                        borderRadius: BorderRadius.circular(50),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    width: 4,
                  ),
                  Expanded(
                    child: Column(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 40),
                            child: Container(
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.black.withAlpha(15)),
                                      alignment: Alignment.center,
                                      child: CustomLoading()),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        item["name"],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Converter.hexToColor("#03a9f4")),
                            ),
                          ),
                        ),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/double_check.svg",
                              color: Colors.grey,
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(Converter.getRealTime(item['created_at'],
                                timeOnly: true,
                                noDelay: true,
                                formatterPattron: "HH:mm"))
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget getChatOfferMessageUi(item, page, index) {
    bool isFromSender = item["send_by"].toString() == user["id"].toString();
    TextDirection direction =
        isFromSender ? TextDirection.ltr : TextDirection.rtl;
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: direction,
        children: [
          Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: direction,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(Globals.correctLink(isFromSender
                                ? user["avatar"]
                                : UserManager.currentUser("avatar")))),
                        borderRadius: BorderRadius.circular(50),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    width: 4,
                  ),
                  Expanded(
                    child: preventContain(item["review"], // Offer
                    Column(
                      textDirection: direction,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: direction == TextDirection.rtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 40),
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
                                    child: Column(
                                      textDirection: LanguageManager.getTextDirection(),
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          textDirection: LanguageManager.getTextDirection(),
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "",
                                                textDirection: LanguageManager.getTextDirection(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Converter.hexToColor("#344F64")),
                                              ),
                                            ),
                                            Text(
                                              item['message']['price'].toString(),
                                              textDirection: LanguageManager.getTextDirection(),
                                              style: TextStyle(
                                                  decoration: item["message"]["status"] == "REJECTED"
                                                      ? TextDecoration.lineThrough
                                                      : TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Converter.hexToColor("#344F64")),
                                            ),
                                            Container(width:5),
                                            Text(
                                              Globals.getUnit(isUsd: item["message"]["target"]),
                                              textDirection: LanguageManager.getTextDirection(),
                                              style: TextStyle(
                                                  decoration: item["message"]["status"] == "REJECTED"
                                                      ? TextDecoration.lineThrough
                                                      : TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: item["message"]["target"] == "online_services" ? 17 : 14,
                                                  color: Converter.hexToColor("#344F64")),
                                            )
                                          ],
                                        ),
                                        Text(
                                          item['message']['description'].toString(),
                                          textDirection: LanguageManager.getTextDirection(),
                                          style: TextStyle(
                                              decoration: item["message"]["status"] == "REJECTED"
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                  getOfferOptions(item, page, index, isFromSender)
                                ],
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Converter.hexToColor("#F2F2F2")),
                            ),
                          ),
                        ),
                        Row(
                          textDirection: direction,
                          children: [
                            !isFromSender
                                ? SvgPicture.asset(
                                    "assets/icons/double_check.svg",
                                    color: item["seen"] == 1
                                        ? Colors.blue
                                        : Colors.grey,
                                  )
                                : Container(),
                            Container(
                              width: 5,
                            ),
                            Text(Converter.getRealTime(item['created_at'],
                                timeOnly: true,
                                noDelay: true,
                                formatterPattron: "HH:mm"))
                          ],
                        )
                      ],
                    )),
                  ),
                ],
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget getOfferOptions(item, page, index, isFromSender) {
    if (item["message"]["status"] == "ACCEPTED")
      return Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(137),
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );
    if (item["message"]["status"] == "REJECTED")
      return Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(127),
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );
    if (item["message"]["status"] == "CANCELED")
      return Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(131),
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );
    if (item["message"]["status"] == "LOADING")
      return Container(
        height: 40,
        alignment: Alignment.center,
        child: CustomLoading(),
      );
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
                rejectOffer(item["id"], item["message"]['id'], page, index);
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: Text(
                LanguageManager.getText(isFromSender ? 124 : 132),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              decoration: BoxDecoration(
                  color: Converter.hexToColor(
                      isFromSender ? "#2094CD" : "#f44336"),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(isFromSender ? 0 : 10))),
            ),
          ),
        ),
        !isFromSender
            ? Container()
            : Expanded(
                child: InkWell(
                  onTap: () {
                    print('here_onTap_ok: $item');
                    Alert.show(context,
                        PaymentOptions(item , context),
                        type: AlertType.WIDGET, isDismissible: false);
                  },
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      LanguageManager.getText(123),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    decoration: BoxDecoration(
                        color: Converter.hexToColor("#344F64"),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10))),
                  ),
                ),
              ),
      ],
    );
  }

  Widget getChatFileMessageUI(item) {
    // print('here_getChatFileMessageUI: $item');
    bool isFromSender = item["send_by"].toString() == user["id"].toString();
    TextDirection direction =
        isFromSender ? TextDirection.ltr : TextDirection.rtl;
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: direction,
        children: [
          Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: direction,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(Globals.correctLink(isFromSender
                                ? user["avatar"]
                                : UserManager.currentUser("avatar")))),
                        borderRadius: BorderRadius.circular(50),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    width: 4,
                  ),
                  Expanded(
                    child: preventContain(item["review"], // File
                      Column(
                      textDirection: direction,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: direction == TextDirection.rtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 40),
                            child: Container(
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        launch(item["message"]);
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.black.withAlpha(15)),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          FlutterIcons.download_fea,
                                          color: isFromSender
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      )),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        item["message"].toString().split('file/')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isFromSender
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isFromSender
                                      ? Converter.hexToColor("#F2F2F2")
                                      : Converter.hexToColor("#03a9f4")),
                            ),
                          ),
                        ),
                        Row(
                          textDirection: direction,
                          children: [
                            !isFromSender
                                ? SvgPicture.asset(
                                    "assets/icons/double_check.svg",
                                    color: item["seen"] == 1
                                        ? Colors.blue
                                        : Colors.grey,
                                  )
                                : Container(),
                            Container(
                              width: 5,
                            ),
                            Text(Converter.getRealTime(item['created_at'],
                                timeOnly: true,
                                noDelay: true,
                                formatterPattron: "HH:mm"))
                          ],
                        )
                      ],
                    )),
                  ),
                ],
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget getChatImageUploadMessageUI(item) {
    print('here_getChatImageUploadMessageUI: item: $item, images: $images');
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                Globals.correctLink(UserManager.currentUser("avatar")))),
                        borderRadius: BorderRadius.circular(50),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    width: 4,
                  ),
                  Expanded(
                    child: Column(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 40),
                            child: Container(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.memory(images[item["source"]]),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(150),
                                        borderRadius: BorderRadius.circular(5)),
                                    alignment: Alignment.center,
                                    child: CustomLoading(),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Converter.hexToColor("#03a9f4")),
                            ),
                          ),
                        ),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/double_check.svg",
                              color: Colors.grey,
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(Converter.getRealTime(item['created_at'],
                                timeOnly: true,
                                noDelay: true,
                                formatterPattron: "HH:mm"))
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget getChatImageMessageUI(item) {
    // print('here_getChatImageUploadMessageUI: item: $item, images: $images');
    bool isFromSender = item["send_by"].toString() == user["id"].toString();
    TextDirection direction =
        isFromSender ? TextDirection.ltr : TextDirection.rtl;
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: direction,
        children: [
          Expanded(
            child: Container(
              child:InkWell(
                onTap : (){ Navigator.push(context, MaterialPageRoute(builder: (_) => OpenImage(url: item['message'].toString(),)));},
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: direction,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(Globals.correctLink(isFromSender
                                  ? user["avatar"]
                                  : UserManager.currentUser("avatar")))),
                          borderRadius: BorderRadius.circular(50),
                          color: Converter.hexToColor("#F2F2F2")),
                    ),
                    Container(
                      width: 4,
                    ),
                    Expanded(
                      child: preventContain(item["review"], // Image
                        Column(
                        textDirection: direction,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: direction == TextDirection.rtl
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 40),
                              child: Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(
                                      imageUrl: item['message'].toString()),
                                ),
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isFromSender
                                        ? Converter.hexToColor("#F2F2F2")
                                        : Converter.hexToColor("#03a9f4")),
                              ),
                            ),
                          ),
                          Row(
                            textDirection: direction,
                            children: [
                              !isFromSender
                                  ? SvgPicture.asset(
                                      "assets/icons/double_check.svg",
                                      color: item["seen"] == 1
                                          ? Colors.blue
                                          : Colors.grey,
                                    )
                                  : Container(),
                              Container(
                                width: 5,
                              ),
                              Text(Converter.getRealTime(item['created_at'],
                                  timeOnly: true,
                                  noDelay: true,
                                  formatterPattron: "HH:mm"))
                            ],
                          )
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget getChatTextMessageUI(item) {
    bool isFromSender = item["send_by"].toString() == user["id"].toString();
    TextDirection direction =
        isFromSender ? TextDirection.ltr : TextDirection.rtl;
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: direction,
        children: [
          Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: direction,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(Globals.correctLink(isFromSender
                                ? user["avatar"]
                                : UserManager.currentUser("avatar")))),
                        borderRadius: BorderRadius.circular(50),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    width: 4,
                  ),
                  Expanded(
                    child: preventContain(item["review"], // Text
                      Column(
                      textDirection: direction,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Container(
                          alignment: direction == TextDirection.rtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 40),
                            child: Container(
                              child: Text(
                                item['message'].toString(),
                                textDirection:
                                    LanguageManager.getTextDirection(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isFromSender
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isFromSender
                                      ? Converter.hexToColor("#F2F2F2")
                                      : Converter.hexToColor("#03a9f4")),
                            ),
                          ),
                        ),
                        Row(
                          textDirection: direction,
                          children: [
                            !isFromSender
                                ? SvgPicture.asset(
                                    "assets/icons/double_check.svg",
                                    color: item["seen"] == 1
                                        ? Colors.blue
                                        : Colors.grey,
                                  )
                                : Container(),
                            Container(
                              width: 5,
                            ),
                            Text(Converter.getRealTime(item['created_at'],
                                timeOnly: true,
                                noDelay: true,
                                formatterPattron: "HH:mm"))
                          ],
                        )
                      ],
                    )),
                  ),
                ],
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  void showOptions() {
    setState(() {
      visibleoptions = !visibleoptions;
    });
  }



  void sendTypingNotifyer() {
    typingNotifyer = true;
    Map<String, String> body = {};

    body['message'] = "USER_TYPING";
    body['type'] = "TEXT";
    body['id'] = widget.id.toString();

    body['send_to'] = widget.id.toString();
    body['send_by'] = UserManager.currentUser("id").toString();

    NetworkManager.httpPost(Globals.baseUrl + "convertation/typing",  context, (r) {}, body: body);
  }

  void sendSeenFlag() { // id
    Map<String, String> body = {};
    // body['message_id'] = id;
    // body['id'] = widget.id.toString();
    body['provider_id'] = widget.id.toString();
    body['user_id'] = UserManager.currentUser("id").toString();
    NetworkManager.httpPost(Globals.baseUrl + "convertation/seen", context ,(r) {}, body: body); // chat/seen
  }

  void sendFile(PlatformFile fileData) {
    File file = File(fileData.path);
    if (file == null) return;
    int id = files.length;
    String page = data.keys.last;
    int index = data[data.keys.last].length;
    files[id] = false;
    setState(() {
      data[data.keys.last]
          .add({"type": "FILE_UPLOAD", "source": id, "name": fileData.name});
    });
    scrollDown();

    AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/sent.mp3"));
    NetworkManager().fileUpload( Globals.baseUrl + "convertation/create", // chat/file
        [
          {
            "name": "file",
            "file": file.readAsBytesSync(),
            "type_name": "file",
            "file_type": "any",
            "file_name": fileData.name//"aplication"
          }
        ],
        (p) {}, (r) {
      if (r["state"] == true) {
        setState(() {
          //data[page][index] = r['data'][0];
          data.values.last.add(r['data'][0]);
          int tempId = id;
          files[tempId] = null;
        });
      } else {
        setState(() {
          data[page][index]["error"] = true;
        });
      }
    }, body: {
      "id": widget.id,
      "index": index.toString(),
      "page": page,
      "file_name": fileData.name,
      "temp_id": id.toString(),
      'type': "FILE".toLowerCase(),
      'provider_id': widget.id.toString(),
      'user_id': UserManager.currentUser("id").toString(),
      'send_by': UserManager.currentUser("id").toString(),
    });
  }

  void sendImage(PickedFile imageFile) {
    if (imageFile == null) return;
    setState(() {
      isOpenPicks = false;
    });

    int id = images.length;
    String page = '0';//data.keys.last;
    int index = data[data.keys.last].length;
    images[id] = File(imageFile.path).readAsBytesSync();
    setState(() {
      data[data.keys.last].add({"type": "IMAGE_UPLOAD", "source": id, "prograss": 0});
    });

    scrollDown();

    AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/sent.mp3"));
    NetworkManager().fileUpload(Globals.baseUrl + "convertation/create", [ // chat/image
      {
        "name": "image",
        "file": images[id],
        "type_name": "image",
        "file_type": "png",
        "file_name": "${DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '').replaceAll('-', '')}.png"
      }
    ], (p) {
      setState(() {});
    }, (r) {
      if (r["state"] == true) {
        setState(() {
          //data[page][index] = r['data'][0];//r["message"];
          data.values.last.add(r['data'][0]);
          int tempId = id;//int.parse(r["temp_id"]);
          images[tempId] = null;
        });
      } else {
        print('here_ r["state"] else');
        setState(() {
          data[page][index]["error"] = true;
        });
      }
    }, body: {
      "id": widget.id,
      "index": index.toString(),
      "page": page,
      "temp_id": id.toString(),
      'type': "IMAGE".toLowerCase(),
      'provider_id': widget.id.toString(),
      'user_id': UserManager.currentUser("id").toString(),
      'send_by': UserManager.currentUser("id").toString(),
    });
  }

  void sendPromoCode() {
    if (promoCode.isEmpty) return;
    Map<String, String> body = {"code": promoCode};
    NetworkManager.httpPost(Globals.baseUrl + "chat/promo", context ,(r) {
      if (r['state'] == true) {
        setState(() {
          data.values.last.add(r['message']);
        });
      }
    }, body: body);

    AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/sent.mp3"));
  }

  void sendOffer() {
    Alert.publicClose();
    if (offer.isEmpty || offer["price"] == null) return;
    offer['id'] = widget.id;
    NetworkManager.httpPost(Globals.baseUrl + "chat/offer", context ,(r) {
      if (r['state'] == true) {
        setState(() {
          data.values.last.add(r['message']);
        });
      }
    }, body: offer);

    AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/sent.mp3"));
  }

  void send() {
    if(replaceArabicNumber(body['text'].toString()).replaceAll(new RegExp(r'[^0-9]'),'').length<7) {
      typingNotifyer = false;
      if (body.keys.length == 0) return;
      AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/sent.mp3"));
      body['type'] = "TEXT".toLowerCase();
      body['provider_id'] = widget.id.toString();
      body['user_id'] = UserManager.currentUser("id").toString();
      body['send_by'] = UserManager.currentUser("id").toString();
      NetworkManager.httpPost(
          Globals.baseUrl + "convertation/create", context, (r) { // chat/send
        if (r['state'] == true) {
          // ifNotSeenSendNotifi();
          setState(() {
            data.values.last.add(r['data'][0]);
          });
        }
      }, body: body);
      setState(() {
        controller.text = "";
      });
      body = {};
    }else{
      Alert.show(context, 320);
    }
  }


  void rejectOffer(messageId, id, page, index) {
    setState(() {
      data[page][index]["message"]["status"] = "LOADING";
    });
    Map body = {
      "id": id.toString(),
      "page": page.toString(),
      "index": index.toString(),
      "message_id": messageId.toString(),
      "status": "REJECTED",
      'send_to' : widget.id.toString()
    };
    NetworkManager.httpPost(Globals.baseUrl + "offer/status/$id", context ,(r) { // chat/rejectOffer
      if (r['state'] == true) {
        setState(() {
          data[body['page']][index]["message"]["status"] = r['data']['status'];
        });
      }
    }, body: body);
  }

  void pickFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      // allowedExtensions: ['jpg', 'mp4', 'pdf', 'doc', 'zip'],
    );
    if (result != null) {
      setState(() {
        isOpenPicks = false;
      });

      sendFile(result.files.single);
    } else {
      // User canceled the picker
    }
  }

  void pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.getImage(source: source);
      if (pickedFile == null) return;
      sendImage(pickedFile);
    } catch (e) {
      // error
      print('here_pickImage: $e');
    }
  }

  void addPromoCode() {
    setState(() {
      isOpenPicks = false;
    });
    Alert.show(
        context,
        Container(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Container(),
                  Text(
                    LanguageManager.getText(85),
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    child: InkWell(
                        onTap: () {
                          if (Alert.publicClose != null)
                            Alert.publicClose();
                          else
                            Navigator.pop(context);
                        },
                        child: Icon(FlutterIcons.close_ant)),
                  ),
                ],
              ),
            ),
            Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Text(
                  LanguageManager.getText(86),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                Container(
                  width: 10,
                ),
                Text(
                  LanguageManager.getText(87),
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Converter.hexToColor("#F2F2F2"),
              ),
              child: TextField(
                decoration: InputDecoration(border: InputBorder.none),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 10,
            ),
            InkWell(
              onTap: sendPromoCode,
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(70),
                  style: TextStyle(
                    color: Colors.white,
                  ),
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
            Container(
              height: 10,
            ),
          ],
        )),
        type: AlertType.WIDGET);
  }


  Future<bool> _close() async{
    UserManager.refrashUserInfo();
    if(Navigator.canPop(context)) {
      Navigator.pop(context, true);
      return true;
    } else
      return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Conversations()), (Route<dynamic> route) => false);
  }

  String replaceArabicNumber(String offerNum) {
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    for (int i = 0; i< en.length; i++){
      offerNum = offerNum.replaceAll(ar[i], en[i]);
    }
    return    offerNum;
  }

  preventContain(Map review, Widget widget) {
    var isPrevent = review == null;
    if(isPrevent) return widget;
    return InkWell(
      onTap: (){},
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red.withAlpha(10),
        ),
        child: Column(children: [
          Stack(
            children: [
              widget,
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.only(bottom: 25),
                  child: SvgPicture.asset(
                    "assets/icons/prevent.svg",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned.fill(
                  child: Center(
                      child: Container(
                          color: Colors.black.withAlpha(190),
                          margin: EdgeInsets.only(bottom: 25),
                          width: double.infinity,
                          child: Text(
                            LanguageManager.getText(375), // هذا المحتوى مخالف
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )))),
            ],
          ),
          Container(
            padding: EdgeInsets.only(right: 5, left: 5, bottom: 10),
            alignment: Alignment.center,
            child: Center(
              child: Text(
                review['review'],
                textAlign: TextAlign.center,
                textDirection: LanguageManager.getTextDirection(),
                textWidthBasis: TextWidthBasis.longestLine,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
