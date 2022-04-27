import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:math' as math; // import this

class RateStarsStateless extends StatelessWidget {
  final double size, spacing, height;
  final Function onUpdate;
  var stars;
  RateStarsStateless(this.size, {this.spacing = 0.1, this.onUpdate, this.stars, this.height});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: (5 + (spacing * 4)) * size,
      child: Row(
        children: [
          getStarAt(4),
          Container(
            width: size * spacing,
          ),
          getStarAt(3),
          Container(
            width: size * spacing,
          ),
          getStarAt(2),
          Container(
            width: size * spacing,
          ),
          getStarAt(1),
          Container(
            width: size * spacing,
          ),
          getStarAt(0),
        ],
      ),
    );
  }

  Widget getStarAt(index) {
    return Container(
      width: size,
      height: height == null? size : height,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: Icon(
          (index + 1) <= (stars ?? 0)
              ? FlutterIcons.star_faw5s
              : (((index + .5) <= (stars??0) || (index + .3) <= (stars??0))
                  ? FlutterIcons.star_half_alt_faw5s
                  : FlutterIcons.star_faw5),
          size: height == null? size : height,
          color: Colors.orange,
        ),
      ),
    );
  }
}
