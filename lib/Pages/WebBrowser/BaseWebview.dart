import 'dart:async';
import 'dart:convert';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BaseWebview extends State<WebBrowser> {
  bool loading = true;
  @override
  void initState() {
    print(widget.url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            widget.title.isNotEmpty? Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              height: 56,
              color: Colors.white,
              child: Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      textDirection: LanguageManager.getTextDirection(),
                      size: 26,
                    ),
                  ),
                  Text(widget.title, style: Theme.of(context).textTheme.headline6),
                  Container(
                    width: 24,
                  )
                ],
              ),
            ): Container(),
            Expanded(
                child: Container(
              child: Stack(
                children: <Widget>[
                  WebView(
                    onPageFinished: (a) {
                      print('here_WebView_onPageFinished: $a');
                      setState(() {
                        loading = false;
                      });
                      if(a.toString().contains('success'))
                        Timer(Duration(seconds: 1), () {
                          Navigator.of(context).pop('success');
                        });
                    },
                    javascriptChannels: <JavascriptChannel>[
                      JavascriptChannel(
                          name: "MitdoneApp",
                          onMessageReceived: (JavascriptMessage e) {
                            try {
                              var reponce = json.decode(e.message);
                              print('here_WebView_onMessageReceived: $reponce');
                              Navigator.of(context).pop(reponce);
                            } catch (er) {
                              Alert.show(context, er.toString());
                            }
                          })
                    ].toSet(),
                    navigationDelegate: (n) {
                      setState(() {
                        loading = true;
                      });
                      return NavigationDecision.navigate;
                    },
                    initialUrl: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                  ),
                  loading
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            width: 50,
                            height: 50,
                            child: CustomLoading(),
                          ),
                        )
                      : Container(),
                ],
              ),
              padding: EdgeInsets.only(left: 7, right: 7),
            ))
          ],
        ),
      ),
    );
  }
}
