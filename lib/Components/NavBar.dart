import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class NavBar extends StatefulWidget {
  final onUpdate;
  final page;
  const NavBar({this.onUpdate,this.page});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  Color activeColor;
  int iSelectedIndex = 0;
  double homeIconSize;

  int countNotSeen = UserManager.currentUser('not_seen').isNotEmpty? int.parse(UserManager.currentUser('not_seen')) : 0;
  int countChatNotSeen = UserManager.currentUser('chat_not_seen').isNotEmpty? int.parse(UserManager.currentUser('chat_not_seen')) : 0;

  @override
  void initState() {
    activeColor = Converter.hexToColor("#2094CD");
    if(widget.page != null) iSelectedIndex = widget.page;
    Globals.updateBottomBarNotificationCount = ()
    {
      if(mounted)
        setState(() {
          countNotSeen = UserManager.currentUser('not_seen').isNotEmpty? int.parse(UserManager.currentUser('not_seen')) : 0;
          countChatNotSeen = UserManager.currentUser('chat_not_seen').isNotEmpty? int.parse(UserManager.currentUser('chat_not_seen')) : 0;
        });
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    homeIconSize = MediaQuery.of(context).size.width * 0.35;
    if (homeIconSize > 160) homeIconSize = 160;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: homeIconSize * 0.5,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(10),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, -1))
          ]),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          height: homeIconSize * 0.5,
          color: Colors.transparent,
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Home
              createIcon("home", 43, () {setState(() {iSelectedIndex = 0;});
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 0, isBig: true),
              createIcon("services", 35, () {setState(() {iSelectedIndex = 1;});
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 1, count: countChatNotSeen),
              if(Globals.getSetting('show_store') == 'true')
                createIcon("store", 451, () {setState(() {iSelectedIndex = 2;});
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 2, count: countChatNotSeen),
              createIcon("bell", 45, () {
                goToNotification();
              }, iSelectedIndex == 3, count: countNotSeen),
              createIcon("menu", 46, () {setState(() {iSelectedIndex = 4;});
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget createIcon(icon, text, onTap, isActive, {isBig = false, count = 0}) {
    if (!isBig)
      return InkWell(
          onTap: onTap,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                    padding: count >0 ? EdgeInsets.only(top: 2): EdgeInsets.zero,
                    width: homeIconSize * (text != 45? 0.15: 0.20), // 20.2
                    height: homeIconSize * (text != 45? 0.15: 0.16), // 17.7
                    child: SvgPicture.asset(
                      "assets/icons/$icon.svg",
                      color: isActive ? activeColor : Colors.grey,
                      fit: BoxFit.contain,
                    )),
                  count >0
                    ? Container(
                  alignment: Alignment.center,
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.red),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(fontSize: 6, color: Colors.white,fontWeight: FontWeight.w900 ),
                    textAlign: TextAlign.center,),
                )
                    : Container(),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                LanguageManager.getText(text),
                style: TextStyle(
                    color: isActive ? activeColor : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            )
          ]));
    return InkWell(
      onTap: onTap,
      child: Container(
        // width: homeIconSize,
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: homeIconSize * 0.04),
              width: homeIconSize * 0.45,
              height: homeIconSize * 0.45,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                "assets/icons/$icon.svg",
                width: homeIconSize * 0.25,
                height: homeIconSize * 0.25,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.grey,
                  borderRadius: BorderRadius.circular(homeIconSize)),
            ),
            Container(
              width: 5,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                LanguageManager.getText(text),
                style: TextStyle(
                    color: isActive ? activeColor : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }


   goToNotification(){
    setState(() {iSelectedIndex = 3;});
    widget.onUpdate(iSelectedIndex);
  }

}
