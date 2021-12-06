import 'dart:convert';

import 'package:dr_tech/Config/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> reminderScreenNavigatorKey = GlobalKey();


  static void init() {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectReminderNotification);
  }

  static void send(title, message, Map<String, dynamic> paylaod) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "NOTIC", "NOTIC", channelDescription: "NOTIC",
        importance: Importance.max, priority: Priority.high, ticker: 'ticker',
        sound: RawResourceAndroidNotificationSound('special'), playSound: true);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(sound: 'special.caf');
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, message, platformChannelSpecifics, payload: json.encode(paylaod));
  }

  static Future<dynamic> onSelectReminderNotification([String payload]) async {
    print('heree: _onSelectNotification $payload');
    print('heree: reminderScreenNavigatorKey ${reminderScreenNavigatorKey.currentState}');

    Map valueMap = json.decode(payload);

    if(valueMap['screen'] != null && valueMap['screen'] == 'LiveChat') {
      Globals.currentConversationId = valueMap['send_by'].toString();
      Globals.isLiveChatOpenFromNotification = true;
      Navigator.of(reminderScreenNavigatorKey.currentState.context).pushNamed("LiveChat");
    }else if(valueMap['screen'] != null && valueMap['screen'] == 'Notifications'){
      Navigator.of(reminderScreenNavigatorKey.currentState.context).pushNamed("Notifications");
      Globals.isNotificationOpenFromNotification = true;
    }else{
      Navigator.of(reminderScreenNavigatorKey.currentState.context).pushNamed("WelcomePage");
    }

  }

  static Future<dynamic> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: reminderScreenNavigatorKey.currentState.context,
      builder: (BuildContext context) =>
          CupertinoAlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  // await Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => SecondScreen(payload),
                  //   ),
                  // );
                },
              )
            ],
          ),
    );
  }

}
