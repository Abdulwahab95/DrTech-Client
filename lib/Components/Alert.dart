import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class Alert extends StatefulWidget {
  static Function publicClose;
  static bool currentLoader = false;
  static BuildContext currentLoaderContext;
  final type,
      content,
      onSelected,
      onYes,
      premieryText,
      secondaryText,
      isDismissible;
  const Alert(this.content, this.onSelected, this.onYes, this.premieryText,
      this.secondaryText, this.type, this.isDismissible);

  @override
  _AlertState createState() => _AlertState();

  static void show(context, content,
      {onSelected,
      onYes,
      premieryText,
      secondaryText,
      type = AlertType.TEXT,
      isDismissible: true}) {
    showDialog(
        context: context,
        builder: (c) => Alert(content, onSelected, onYes, premieryText,
            secondaryText, type, isDismissible));
  }

  static void startLoading(context) {
    if (currentLoaderContext != null && currentLoader == true) return;
    currentLoaderContext = context;
    currentLoader = true;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/loader.gif"))),
                    ),
                  ),
                ),
              ));
        }).then((value) {
      currentLoader = false;
      publicClose = null;
    });
  }

  static void endLoading() {
    if (!currentLoader) return;

    currentLoader = false;
    Navigator.pop(currentLoaderContext);
  }
}

class _AlertState extends State<Alert> {
  ScrollController controller = ScrollController();
  bool visible = false;
  @override
  void initState() {
    Alert.publicClose = close;
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          this.visible = visible;
          Timer(Duration(milliseconds: 250), () {
            if (!mounted) return;
            setState(() {
              controller.animateTo(controller.position.maxScrollExtent,
                  duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
            });
          });
        });
      },
    );

    Timer(Duration(milliseconds: 1), () {
      setState(() {
        controller.animateTo(controller.position.maxScrollExtent,
            duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: Colors.transparent,
      body: ScrollConfiguration(
        behavior: CustomBehavior(),
        child: Container(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            controller: controller,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
              ),
              getAlertBody()
            ],
          ),
        ),
      ),
    );
    if (widget.isDismissible)
      return GestureDetector(
        onTap: close,
        child: content,
      );

    return content;
  }

  Widget getAlertBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(10),
        child: getContent(),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: true
                ? BorderRadius.only(
                    topLeft: Radius.circular(15), topRight: Radius.circular(15))
                : BorderRadius.circular(15)),
      ),
    );
  }

  Widget getContent() {
    if (widget.type == AlertType.SELECT) {
      return ScrollConfiguration(
        behavior: CustomBehavior(),
        child: Container(
          height: widget.content.length > 10 ? 350 : null,
          child: ListView(
            shrinkWrap: true,
            children: getListOptions(),
          ),
        ),
      );
    }
    if (widget.type == AlertType.WIDGET) return widget.content;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkWell(
                onTap: close,
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
            widget.content.toString(),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
                    onTap: widget.onYes != null ? widget.onYes : close,
                    child: Container(
                      width: 90,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        widget.premieryText != null
                            ? widget.premieryText
                            : LanguageManager.getText(22),
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
                Container(
                  width: 10,
                ),
                Expanded(
                    child: widget.onYes != null
                        ? InkWell(
                            onTap: close,
                            child: Container(
                              width: 90,
                              height: 45,
                              alignment: Alignment.center,
                              child: Text(
                                LanguageManager.getText(21),
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
                          )
                        : Container())
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getListOptions() {
    List<Widget> contents = [];
    for (var item in widget.content) {
      contents.add(InkWell(
        onTap: () {
          if (widget.onSelected != null) widget.onSelected(item);
          close();
        },
        child: Container(
          height: 40,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black.withAlpha(5),
          ),
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              item['icon'] != null
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.contain,
                              image: CachedNetworkImageProvider(item['icon']))),
                    )
                  : Container(),
              Container(
                width: 15,
              ),
              Text(
                Converter.getRealText(
                    item['name'] != null ? item['name'] : item['text']),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              )
            ],
          ),
        ),
      ));
    }

    return contents;
  }

  void close() {
    Timer(Duration(milliseconds: 250), () {
      Navigator.pop(context);
    });
    controller.animateTo(0,
        duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
  }
}

enum AlertType { SELECT, TEXT, WIDGET }