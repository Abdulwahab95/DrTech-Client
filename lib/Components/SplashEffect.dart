import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SplashEffect extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final double margin;
  final double radius;
  final EdgeInsets fullMargin;
  final EdgeInsets padding;
  final Color color;
  final bool showShadow;
  final bool borderRadius;
  final List<BoxShadow> boxShadow;


  const SplashEffect(
      {Key key,
        this.child,
        this.onTap,
        this.margin = 0,
        this.radius,
        this.padding = const EdgeInsets.all(0),
        this.fullMargin,
        this.color = Colors.transparent,
        this.showShadow = true,
        this.boxShadow = const [const BoxShadow(
            offset: Offset(.5, 1),
            color: const Color(0x32000000),
            spreadRadius: 2,
            blurRadius: 2)
        ],
        this.borderRadius = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: LanguageManager.getTextDirection(),
      children: [
        Container(
          margin: fullMargin != null? fullMargin : EdgeInsets.all(margin),
          padding: padding,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius? (radius != null? radius : 999) : 0),
              color: color,
              boxShadow: !showShadow? [] : boxShadow),
          child: child,
        ),
        new Positioned.fill(
            child: new Material(
                color: Colors.transparent,
                child: new InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius? (radius != null? radius : 999) : 0)),
                  splashColor: Colors.white70,
                  onTap: onTap,
                ))),
      ],
    );
  }
}
