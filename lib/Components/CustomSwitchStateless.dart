import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';

class CustomSwitchStateless extends StatelessWidget {
  final bool isActive;
  final Color activeColor;
  final Color notActiveColor;
  final String activeText;
  final String notActiveText;

  CustomSwitchStateless({Key key, this.isActive, this.activeColor,
    this.notActiveColor = Colors.grey, this.activeText = 'On', this.notActiveText = 'Off'});



  @override
  Widget build(BuildContext context) {
    return  Container(
          width: isActive? (LanguageManager.getDirection()? 55.0 : 71.0): 60.0,
          height: 20.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: isActive ? activeColor : notActiveColor
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 2.0, left: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: LanguageManager.getTextDirection() ,
              children: <Widget>[
                !isActive ? Container() :
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: Text(
                    activeText,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.0),
                  ),
                ),
                Align(
                  alignment: isActive? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: 15.0,
                    height: 15.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                  ),
                ),
                isActive ? Container() :
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 5.0),
                  child: FittedBox(
                    child: Text(
                      notActiveText,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .001,
                          fontSize: 9.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
