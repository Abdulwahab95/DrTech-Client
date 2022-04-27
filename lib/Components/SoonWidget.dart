import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SoonWidget extends StatefulWidget {
  const SoonWidget({
    Key key,
  }) : super(key: key);

  @override
  _SoonWidgetState createState() => _SoonWidgetState();
}

class _SoonWidgetState extends State<SoonWidget> {

  @override
  Widget build(BuildContext context) {
    print('here: SoonWidget hi');
    return Column(children: [
      Expanded(
        flex: 10,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      "assets/images/soon.png"))),
        ),
      ),
      Spacer(
        flex: 1,
      ),
      Expanded(
        flex: 9,
        child: Container(
          padding: EdgeInsets.only(
              left: 10, right: 10, top: 5, bottom: 0),
          child: Text(
            LanguageManager.getText(293), // قريباً...
            textDirection:
            LanguageManager.getTextDirection(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                Converter.hexToColor("#303030")),
          ),
        ),
      )
    ],
    );
  }
}