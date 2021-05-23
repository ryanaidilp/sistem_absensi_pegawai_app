import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/network/api.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'network/api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  Intl.defaultLocale = 'id_ID';
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setLocationShared(true);
  OneSignal.shared.init(FlutterConfig.get("ONE_SIGNAL_APP_ID").toString(),
      iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: false
      });
  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  const initializedSettingsAndroid =
      AndroidInitializationSettings('ic_stat_onesignal_default');
  const initializationSettings =
      InitializationSettings(android: initializedSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => DataRepository(apiService: ApiService(api: API())),
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SIAP Balaesang',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              backgroundColor: Colors.white,
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: const AppBarTheme(
                brightness: Brightness.dark,
              )),
          home: SplashScreen()),
    );
  }
}

Future<void> scheduleAlarm(
    DateTime scheduledNotificationDateTime, String body) async {
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_id', 'alarm_id', 'Channel alarm',
      icon: 'ic_stat_onesignal_default',
      enableLights: true,
      priority: Priority.high,
      importance: Importance.max,
      vibrationPattern: Int64List.fromList([0, 1000, 5000, 2000]));

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Makassar'));

  final scheduleTime = tz.TZDateTime.from(
      scheduledNotificationDateTime, tz.getLocation('Asia/Makassar'));

  final platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    Random().nextInt(int.parse(pow(2, 31).toString())),
    'Pengingat',
    body,
    scheduleTime,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidAllowWhileIdle: true,
  );
}
