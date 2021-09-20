import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';

class ContactUs extends StatefulWidget {
  const ContactUs();

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  Map errors = {}, body = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 70,
          title: Container(
            margin: EdgeInsets.only(top: 15),
            child: Text(
              LanguageManager.getText(63),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 1.5,
          backgroundColor: Converter.hexToColor("#2094cd"),
        ),
        body: getBodyContents());
  }

  Widget getBodyContents() {
    List<Widget> items = [];
    items.add(Container(
      margin: EdgeInsets.all(15),
      child: Text(
        LanguageManager.getText(242),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(
            fontSize: 16,
            color: Converter.hexToColor("#2094CD"),
            fontWeight: FontWeight.bold),
      ),
    ));
    //
    items.add(createInput("name", 243));
    items.add(createInput("address", 244));
    items.add(createInput("phone", 245));
    items.add(createInput("email", 246));
    items.add(createInput("description", 247, maxInput: 250, maxLines: 4));

    items.add(Container(
      padding: EdgeInsets.all(7),
      child: InkWell(
        onTap: send,
        child: Container(
          margin: EdgeInsets.all(10),
          height: 50,
          alignment: Alignment.center,
          child: Text(
            LanguageManager.getText(70),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(15),
                    spreadRadius: 2,
                    blurRadius: 2)
              ],
              borderRadius: BorderRadius.circular(8),
              color: Converter.hexToColor("#344f64")),
        ),
      ),
    ));
    return ListView(
      children: items,
    );
  }

  Widget createInput(key, titel,
      {maxInput, TextInputType textType: TextInputType.text, maxLines}) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: EdgeInsets.only(left: 7, right: 7),
      decoration: BoxDecoration(
          color:
              Converter.hexToColor(errors[key] != null ? "#E9B3B3" : "#F2F2F2"),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        onChanged: (t) {
          setState(() {
            body[key] = t;
            errors.remove(key);
          });
        },
        keyboardType: textType,
        maxLength: maxInput,
        maxLines: maxLines,
        textDirection: LanguageManager.getTextDirection(),
        decoration: InputDecoration(
            hintText: LanguageManager.getText(titel),
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            hintTextDirection: LanguageManager.getTextDirection(),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
      ),
    );
  }

  void send() {
    List validateKeys = ["name", "address", "phone", "email", "description"];

    for (var key in validateKeys) {
      if (body[key] == null || body[key].isEmpty)
        setState(() {
          errors[key] = "_";
        });
    }

    if (errors.keys.length > 0) return;

    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "information/contact", (r) {
      Alert.endLoading();
      if (r['status'] == true) Navigator.pop(context);
      if (r["message"] != null) {
        Alert.show(context, Converter.getRealText(r['message']));
      }
    }, body: body);
  }
}