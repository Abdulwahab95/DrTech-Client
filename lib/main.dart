
import 'dart:async';
import 'dart:io';

import 'package:dr_tech/Config/initialization.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/Welcome.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Config/Globals.dart';
import 'Models/Firebase.dart';
import 'Models/LocalNotifications.dart';
import 'Pages/Home.dart';
import 'Pages/LiveChat.dart';
import 'Pages/ProviderProfile.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  Globals.logNotification('onBackgroundMessage', message);
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  //FirebaseCrashlytics.instance.crash();


  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: true,
    sound: true,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
    ledColor: Colors.blue,
    enableVibration: true,
    enableLights: true,
    sound: RawResourceAndroidNotificationSound('special'),
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  HttpOverrides.global = MyHttpOverrides();

  Initialization(() {
    // UserManager.refrashUserInfo();
    runApp(App());
  });

  runApp(MaterialApp(debugShowCheckedModeBanner: false,home: Loading()));

}

class App extends StatelessWidget {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Cario", primarySwatch: Colors.blue,),
      navigatorKey: LocalNotifications.reminderScreenNavigatorKey,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics),],
      routes: {
        "WelcomePage": (context) => MessageHandler(child: Welcome()),
        "LiveChat": (context) => LiveChat(Globals.currentConversationId),
        "Notifications": (context) => Home(page: Globals.getSetting('show_store') == 'true'? 3 : 2),
      },
      initialRoute: "WelcomePage",
    );
  }
}

class Loading extends StatefulWidget {
  const Loading();

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  double opacity = 0.2;

  @override
  void initState() {
    animationTimer();
    super.initState();
  }

  void animationTimer() {
    Timer(Duration(milliseconds: 250), () {
      setState(() {
        opacity = 1;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: LanguageManager.getSupportedLocales(),
        locale: LanguageManager.getLocal(),
        home: Scaffold(
          backgroundColor: Colors.white,
            body: Stack(
              children: [
                getLogoPage(),
                // Center(child: CustomLoading()),
              ],
            )));
  }

  Widget getLogoPage() {
    double size = MediaQuery.of(context).size.width * 0.5;
    return Center(
        child: Container(
            width: size,
            height: size,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: Duration(milliseconds: 750),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"))),
              ),
            )));
  }

}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
