import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'LocalNotifications.dart';
import 'UserManager.dart';


class MessageHandler extends StatefulWidget {
  final Widget child;
  MessageHandler({this.child});
  @override
  State createState() => MessageHandlerState();
}


class MessageHandlerState extends State<MessageHandler> {

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Globals.logNotification('onMessage', message);
      this.parse(message.data, message.notification);
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) { // onReusem
      Globals.logNotification('onMessageOpenedApp', message);

      if(message.data != null && message.data['screen'] != null){
        if(message.data['screen'] == 'LiveChat'){
          Globals.currentConversationId = message.data["conversation_id"];
          Globals.isLiveChatOpenFromNotification = true;
          Navigator.of(LocalNotifications.reminderScreenNavigatorKey.currentState.context).pushNamed("LiveChat");
        } else if(message.data['screen'] == 'Notifications'){
          Globals.isNotificationOpenFromNotification = true;
          Navigator.of(LocalNotifications.reminderScreenNavigatorKey.currentState.context).pushNamed("Notifications");
        } else{
          Navigator.of(LocalNotifications.reminderScreenNavigatorKey.currentState.context).pushNamed("WelcomePage");
        }
      }
    });


    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) { // onOpen
      Globals.logNotification('getInitialMessage', message);
      if(message != null) {
        String screen = message.data['screen']; print(screen);
        if (screen.contains("LiveChat")) {
          print('heree: LiveChat');
          Globals.isLiveChatOpenFromNotification = true;
          Globals.currentConversationId = message.data["conversation_id"];
          // Navigator.of(context).pushNamed("LiveChat");
        } else if(screen.contains("Notifications")){
          print('heree: Notifications');
          Globals.isNotificationOpenFromNotification = true;
        }
      }
    });

    // Timer(Duration(seconds: 2), () {
    //   print('here_timer: 15');
    //   RemoteMessage message =RemoteMessage.fromMap({
    //     "to": "cGWIGoTDRlunHuhL-UTBRb:APA91bGoDrjEsT8uLq8AqGfCNWfpy2SBsFaiWjKwZrcanQVZWwiNVSPKVfySvsAH10wIBPpO7dFK1sPma9w71Lzbb3MLC8Sm-gyCII4pZjlNitGwoSnU5HRZwb1iasQ0VrFuCFm-xrJm",
    //     "priority": "high",
    //     // "url": "",
    //     // "title": "title",
    //     // "body": "body",
    //     // "message": null,
    //     // "type": "NOTIC",
    //     // "data": {
    //     //   "title": "message",
    //     //   "message_txt": "",
    //     //   "payload_target": "info",
    //     //   "priority": "high",
    //     //   "screen": "LiveChat",
    //     //   "content_available": true,
    //     //   "click_action": "FLUTTER_NOTIFICATION_CLICK",
    //     //   "conversation_id": "3",
    //     //   "payload": {
    //     //     "type": "seen"
    //     //   }
    //     // },
    //     "notification" : {
    //       "body" : "Test Notification9",
    //       "title": "Custom sound9",
    //       "sound": "special.caf",
    //       "color": "#ff0099",
    //       "badge": "9"
    //     }
    //   });
    //   this.parse(message.data, message.notification);
    //   // UserManager.updateSp('not_seen', 0);
    //   // Globals.updateNotificationCount();
    //
    //   // Timer(Duration(seconds: 4), () {
    //   //   print('here_timer: ');
    //   //   UserManager.updateSp('not_seen', 1);
    //   //   Globals.updateNotificationCount();
    //   // });
    //
    // });
  }

  void parse(Map<String, dynamic> data, RemoteNotification notification) {
    print('here_timer: data: $data');
    Map payload = data['payload'].runtimeType == String? json.decode(data['payload']) : data['payload'];
    if (data["conversation_id"] != null && data["conversation_id"] != '') {
      print('here_timer: if 1 , conversation_id: ${data["conversation_id"]}, ');
      if (LiveChat.currentConversationId == data["conversation_id"].toString()) {
        print('here_timer: if 2');
        if (LiveChat.callback != null) {
          print('here_timer: if 3');
          if (data['payload'].runtimeType == String)
            LiveChat.callback(data['payload_target'], jsonDecode(data['payload']));
          else
            LiveChat.callback(data['payload_target'], data['payload']);
        }
      } else if (data != null && payload != null && payload['text'] != null && payload['text'] == 'USER_TYPING'){ // USER_TYPING
        // USER_TYPING and user not on screen liveChat => don't show notification
      } else if (data != null && payload != null && payload['type'] != null && payload['type'] == 'seen'){ // seen
        // seen and user not on screen liveChat => don't show notification
      } else if (data != null) {
        if (UserManager.currentUser("chat_not_seen").isNotEmpty && data['screen'] == 'LiveChat') {
          print('here_timer: chat if');
          UserManager.updateSp("chat_not_seen", (int.parse(UserManager.currentUser("chat_not_seen")) + 1));
        } else if (UserManager.currentUser("not_seen").isNotEmpty && data['screen'] == 'Notifications') {
          print('here_timer: not_seen');
          UserManager.updateSp("not_seen", (int.parse(UserManager.currentUser("not_seen")) + 1));
        }
        print('here_timer: else 2');
        LocalNotifications.send(data['title'],data['message_txt'], payload);
      }
    } else {
      print('here_timer: else 1');
      if(data['payload_target'] == 'order') {
        Globals.reloadPageOrder();
        Globals.reloadPageOrderDetails();
      }
      LocalNotifications.send(notification.title, notification.body, payload);
    }

    Globals.updateChatCount();
    Globals.updateConversationCount();
    Globals.updateTitleBarNotificationCount();
    Globals.updateBottomBarNotificationCount();
    Globals.reloadPageNotificationLive();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

}


class FirebaseClass {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseClass(callBack) {
    LocalNotifications.init();
    Globals.isLocal? callBack(): firebaseCloudMessagingListeners(callBack);
  }

  void firebaseCloudMessagingListeners(Function callBack) {

    _firebaseMessaging.getToken().then((token) {
      Globals.deviceToken = token;
    });

    if (Platform.isIOS)
      iosPermission(callBack);
    else {
      callBack();
    }
  }


  Future<void> iosPermission(Function callback) async {
    NotificationSettings settings =  await  _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
    callback();

  }


}




// class Firebase {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   Firebase(callBack) {
//     firebaseCloudMessagingListeners(callBack);
//   }
//   void firebaseCloudMessagingListeners(Function callBack) {
//     _firebaseMessaging.getToken().then((token) {
//       Globals.deviceToken = token;
//     });
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('herer: ${message.data}');
//       this.parse(message.data);
//     });
//     // _firebaseMessaging.configure(
//     //   onMessage: (Map<String, dynamic> message) async {
//     //     this.parse(message);
//     //   },
//     //   onResume: (Map<String, dynamic> message) async {
//     //     UserManager.refrashUserInfo();
//     //   },
//     //   onLaunch: (Map<String, dynamic> message) async {
//     //     UserManager.refrashUserInfo();
//     //   },
//     // );
//
//     if (Platform.isIOS)
//       iosPermission(callBack);
//     else
//       callBack();
//   }
//
//   Future<void> iosPermission(Function callback) async {
//     NotificationSettings settings =  await  _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
//       print('User granted provisional permission');
//     } else {
//       print('User declined or has not accepted permission');
//     }
//     callback();
//
//     // _firebaseMessaging.onIosSettingsRegistered
//     //     .listen((IosNotificationSettings settings) {
//     //   callback();
//     // });
//   }
//
//   void parse(Map<String, dynamic> paylaod) {
//     var data = paylaod;
//     if (data["conversation_id"] != null) {
//       if (LiveChat.currentConversationId == data["conversation_id"]) {
//         if (LiveChat.callback != null) {
//           if (data['payload'].runtimeType == String)
//             LiveChat.callback(
//                 data['payload_target'], jsonDecode(data['payload']));
//           else
//             LiveChat.callback(data['payload_target'], data['payload']);
//         }
//       }
//     }
//   }
// }
