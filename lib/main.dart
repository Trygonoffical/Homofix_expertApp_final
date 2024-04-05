import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homofix_expert/Login/loginScreen.dart';
import 'New_Booking/newBookingOrderlist.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add this line
  AndroidInitializationSettings androidSetting =
      const AndroidInitializationSettings("@mipmap/ic_launcher");
  DarwinInitializationSettings iosSetting = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true);

  InitializationSettings initializationSettings = InitializationSettings(
    android: androidSetting,
    iOS: iosSetting,
  );
  bool? initialized = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings, onDidReceiveNotificationResponse: (response) {
    log(response.payload.toString());
    // if (response.payload != null) {
    //   int bookingId = int.parse(response.payload.toString());
    // Navigate to the OrderScreen with the bookingId
    Navigator.push(
      GlobalKey<NavigatorState>().currentState!.context,
      MaterialPageRoute(
        builder: (context) => const ProductScreenView(
          expertId: '',
          expertname: '',
        ),
      ),
    );
    //  }
  });
  log("Notification: $initialized");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? newBookingTimer;
  BuildContext? appContext;
  // void startNewBookingTimer() {
  //   newBookingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
  //     checkForNewBooking();
  //     print("__________________Hello__");
  //   });
  // }

  void stopNewBookingTimer() {
    newBookingTimer?.cancel();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // startNewBookingTimer();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            color: Colors.blue,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white)),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
        brightness: Brightness.light,
        primarySwatch: const MaterialColor(
          0xffFFFFFF,
          {
            50: Color(0xffFFFFFF),
            100: Color(0xffFFFFFF),
            200: Color(0xffFFFFFF),
            300: Color(0xffFFFFFF),
            400: Color(0xffFFFFFF),
            500: Color(0xffFFFFFF),
            600: Color(0xffFFFFFF),
            700: Color(0xffFFFFFF),
            800: Color(0xffFFFFFF),
            900: Color(0xffFFFFFF),
          },
        ),
      ),
      home: const Login(),
    );
  }
}
