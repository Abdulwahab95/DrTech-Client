import 'package:dr_tech/Components/NotificationIcon.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class TitleBar extends StatefulWidget {
  final Function onTap;
  final title;
  final bool withoutBell;
  final bool withoutBack;
  const TitleBar(this.onTap, this.title, {this.withoutBell = true, this.withoutBack = false, });

  @override
  _TitleBarState createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
        BoxDecoration(color: Converter.hexToColor("#2094cd")),
        padding:
        EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
                left: LanguageManager.getDirection() ? 25 :0,
                right: LanguageManager.getDirection() ? 0 : 25,
                bottom: 10, top: 18),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: widget.onTap,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: LanguageManager.getDirection()?0:25,
                        right: LanguageManager.getDirection()?25:0,
                      ),
                      child: Icon(
                        LanguageManager.getDirection()
                            ? FlutterIcons.chevron_right_fea
                            : FlutterIcons.chevron_left_fea,
                        color: widget.withoutBack ? Colors.transparent : Colors.white,
                        size: 26,
                      ),
                    )),
                Text(
                  Converter.getRealText(widget.title),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                widget.withoutBell ? Container():NotificationIcon(),
              ],
            )));
  }
}
