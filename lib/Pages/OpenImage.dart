import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../Config/Globals.dart';
import '../Models/LanguageManager.dart';

class OpenImage extends StatefulWidget {

  final String url;
  OpenImage({this.url = ''});

  @override
  _OpenImageState createState() => _OpenImageState();
}

class _OpenImageState extends State<OpenImage>  with TickerProviderStateMixin {
  TabController controller ;
  String index = '';

  @override
  void initState() {
    controller = new TabController(length: widget.url.split('||').length , vsync: this);
    super.initState();
    index = '${controller.index + 1}/${'||'.allMatches(widget.url).length + 1}';
    controller.addListener(() {
      setState(() {
        index = '${controller.index + 1}/${'||'.allMatches(widget.url).length + 1}';
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            InteractiveViewer(
                child: getServiceInfo()//CachedNetworkImage(imageUrl: widget.url, height: double.infinity,  width: double.infinity,),
            ),
            Container(
              padding: EdgeInsets.all(5),
              color: Colors.black.withOpacity(.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(index, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getServiceInfo() {
    double size = MediaQuery.of(context).size.width;
    return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: size,
              alignment: Alignment.center,
              child: TabBarView(
                  controller: controller,
                  children: widget.url.split('||')
                      .map<Widget>((String url) => Container(
                    width: size - 20,
                    height: size * 0.5 - 10,
                    decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(Globals.correctLink(url)))),
                  ))
                      .toList()),
            ),
          ],
        ));
  }
}
