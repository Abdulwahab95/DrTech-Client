import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OpenImage extends StatefulWidget {

  final String url;
  OpenImage({this.url = ''});


  @override
  _OpenImageState createState() => _OpenImageState();
}

class _OpenImageState extends State<OpenImage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: widget.url, height: double.infinity,  width: double.infinity,),
        ),
      ),
    );
  }
}
