import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:flutter/material.dart';

class SubscriptionSlider extends StatefulWidget {
  final slider;
  const SubscriptionSlider(this.slider);
  @override
  _SubscriptionSliderState createState() => _SubscriptionSliderState();
}

class _SubscriptionSliderState extends State<SubscriptionSlider> {
  ScrollController controller = ScrollController();
  @override
  void initState() {
    tick();
    super.initState();
  }

  void tick() {
    var slides = widget.slider;
    if (slides == "") return;
    Timer(Duration(seconds: 5), () {
      if (!mounted) return;
      var current = controller.offset;
      if (current == controller.position.maxScrollExtent) {
        controller.animateTo(0,
            duration: Duration(milliseconds: 450), curve: Curves.easeInOut);
      } else {
        controller.animateTo(current + MediaQuery.of(context).size.width,
            duration: Duration(milliseconds: 450), curve: Curves.easeInOut);
      }
      tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return getSlider();
  }

  Widget getSlider() {
    var width = MediaQuery.of(context).size.width;
    var height = width * 0.45;
    List<Widget> items = [];
    var slides = widget.slider;
    if (slides != "")
      for (var item in slides) {
        items.add(Container(
          width: width - 10,
          height: height,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
        ));
      }
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView(
          controller: controller,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          children: items,
        ),
      ),
    );
  }
}
