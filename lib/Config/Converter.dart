import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as a;

class Converter {
  static String intToTime(time, {String format: "hh:mm:ss"}) {
    var b = time % 3600;
    double h = (time - b) / 3600;
    double m = (b - (b % 60)) / 60;
    double s = b - (m * 60);

    return format
        .replaceAll(
            "hh", h > 9 ? h.toInt().toString() : "0" + h.toInt().toString())
        .replaceAll(
            "mm", m > 9 ? m.toInt().toString() : "0" + m.toInt().toString())
        .replaceAll(
            "ss", s > 9 ? s.toInt().toString() : "0" + s.toInt().toString());
  }

  static String intToTimeWithText(time, {String format: "hh:mm:ss"}) {
    var b = time % 3600;
    double h = (time - b) / 3600;
    double m = (b - (b % 60)) / 60;
    double s = b - (m * 60);

    return format
        .replaceAll(
        "hh", (h > 9 ? h.toInt().toString() : "0" + h.toInt().toString()) + ' ' + LanguageManager.getText((h < 11 && h > 2)? 57 : 345))
        .replaceAll(
        "mm", (m > 9 ? m.toInt().toString() : "0" + m.toInt().toString()) + ' ' + LanguageManager.getText((m < 11 && m > 2)? 56 : 344))
        .replaceAll(
        "ss", s > 9 ? s.toInt().toString() : "0" + s.toInt().toString());
  }

  static Color hexToColor(String code) {
    try {
      if (code.length == 9) {
        return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000)
            .withAlpha(int.parse(code.substring(7, 9), radix: 16));
      }

      return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.white;
    }
  }

  static ImageProvider<dynamic> urlImage(url) {
    return NetworkImage(url.toString());
  }

  static String timeTolocal(String v) {
    if (v == null || v.isEmpty) return LanguageManager.getText(12);

    a.DateFormat server = new a.DateFormat('yyyy-MM-dd HH:mm:ss');
    a.DateFormat formater =
        a.DateFormat('yyyy MMMM dd', LanguageManager.getLocalStr());
    DateTime time = server.parse(v, true);
    return formater.format(time.toLocal());
  }

  static String getRealTime(time,
      {bool timeOnly: false,
      bool noDelay: false,
      String formatterPattron: "HH:mm:ss"}) {
    if (time == null) return "";

    time = time.toString().replaceAll('T', ' ');
    time = time.toString().replaceAll('.000000Z', ' ');

    a.DateFormat server = new a.DateFormat('yyyy-MM-dd HH:mm:ss');
    a.DateFormat formatter =
        new a.DateFormat('yyyy MMMM dd', LanguageManager.getLocalStr());
    DateTime dateTime = server.parse(time, true);
    DateTime now = DateTime.now();

    int delay =
        ((now.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch) / 1000)
            .round();
    if (!noDelay) {
      if (delay < 60) return "$delay " + LanguageManager.getText(55);

      if (delay < 60 * 60)
        return "${delay ~/ 60} " + LanguageManager.getText(56);

      if (delay < 60 * 60 * 24)
        return "${delay ~/ (60 * 60)} " + LanguageManager.getText(57);

      if (delay < 60 * 60 * 24 * 30)
        return "${delay ~/ (60 * 60 * 24)} " + LanguageManager.getText(58);
    }
    if (timeOnly) {
      a.DateFormat formatter =
          new a.DateFormat(formatterPattron, LanguageManager.getLocalStr());
      return formatter.format(dateTime.toLocal());
    }
    return formatter.format(dateTime.toLocal());
  }

  static Widget getStars(length, color, {size: 30.0}) {
    Widget getPlase(position) {
      var active = true;
      var icon = Icons.star;
      if (length < position + 1 && length >= (position + 0.5))
        icon = Icons.star_half;

      if (length >= position)
        active = true;
      else
        icon = Icons.star;

      return Icon(
        icon,
        size: size,
        color: active ? color : Colors.grey.withAlpha(50),
        textDirection: LanguageManager.getDirection()
            ? TextDirection.ltr
            : TextDirection.ltr,
      );
    }

    return Container(
      child: Row(children: [
        getPlase(4),
        getPlase(3),
        getPlase(2),
        getPlase(1),
        getPlase(0),
      ]),
    );
  }

  static String getRealText(item) {
    if (item.runtimeType == String && !item.toString().contains(" "))
      item = int.tryParse(item) ?? item;
    if (item.toString().startsWith("PERIOD:")) {
      return Converter.getRealTime(item.toString().replaceAll("PERIOD:", ""));
    }
    if (item.toString().startsWith("DATE:")) {
      return Converter.timeTolocal(item.toString().replaceAll("DATE:", ""));
    }
    RegExp regExp = new RegExp(
      r'(?<={)(.*)(?=})',
      caseSensitive: false,
      multiLine: true,
    );
    var matches = regExp.allMatches(item.toString());
    if (matches.length > 0) {
      for (var match in matches) {
        String key = match.group(0);
        item = item.toString().replaceAll('{' + key + '}', getRealText(key));
      }
    }

    return item.runtimeType == int && item.toString().length < 6
        ? LanguageManager.getText(item)
        : item.toString() ?? "";
  }

  static String format(d, {numAfterComma = 2}){
    if(d.toString().contains('.') && d.toString().length > (d.toString().indexOf('.') + numAfterComma))
      return d.toString().substring(0, d.toString().indexOf('.') + numAfterComma );
    else if(!d.toString().contains('.'))
      return d.toString() + '.0';
    else
      return d.toString();
  }

  static String replaceValue(String text, String to) {
    return text.replaceFirst('%s', to);
  }

  static String replaceArabicNumber(String offerNum) {
    print('here_num_ar_before: $offerNum');
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    for (int i = 0; i< en.length; i++){
      offerNum = offerNum.replaceAll(ar[i], en[i]);
    }
    print('here_num_ar_after: $offerNum');
    return    offerNum;
  }

}
