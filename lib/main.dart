import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/network/api.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/login_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';
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
  OneSignal.shared.init(FlutterConfig.get("ONE_SIGNAL_APP_ID"), iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: false
  });
  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  var initializedSettingsAndroid =
      AndroidInitializationSettings('ic_stat_onesignal_default');
  var initializationSettings =
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
  bool _isLoggedIn = false;
  Future<bool> _isFirstSeen;

  Future<void> _askPermission() async {
    try {
      final PermissionStatus locationPerms =
          await Permission.locationWhenInUse.status;
      if (locationPerms != PermissionStatus.granted) {
        await Permission.locationWhenInUse.request();
      }

      final PermissionStatus cameraPerms = await Permission.camera.status;
      if (cameraPerms != PermissionStatus.granted) {
        await Permission.camera.request();
      }

      final PermissionStatus storagePerms = await Permission.storage.status;
      if (storagePerms != PermissionStatus.granted) {
        await Permission.storage.request();
      }

      final PermissionStatus phonePerms = await Permission.phone.status;
      if (phonePerms != PermissionStatus.granted) {
        await Permission.phone.request();
      }

      final PermissionStatus notificationPerms =
          await Permission.notification.status;
      if (notificationPerms != PermissionStatus.granted) {
        await Permission.notification.request();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> checkIsFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('seen')) {
      return true;
    } else {
      prefs.setBool('seen', true);
      return false;
    }
  }

  Future<void> _checkIfLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    if (token != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      showDialog<Widget>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Tidak dapat mendeteksi lokasi saat ini!'),
              content: const Text('Pastikan GPS sudah aktif dan coba lagi!'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    const AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(_).pop();
                  },
                  child: const Text('Ok'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(_).pop();
                  },
                  child: const Text('Tidak'),
                ),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
    _askPermission();
    _checkGps();
    _isFirstSeen = checkIsFirstSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => DataRepository(apiService: ApiService(api: API())),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SIAP Balaesang',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              backgroundColor: Colors.white,
              scaffoldBackgroundColor: Colors.grey[100]),
          home: FutureBuilder<bool>(
            future: _isFirstSeen,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data) {
                  return _isLoggedIn ? BottomNavScreen() : LoginScreen();
                } else {
                  return IntroductionScreen(
                    pages: onBoardingScreens,
                    showSkipButton: true,
                    skip: const Text("Skip"),
                    onSkip: () {
                      print('skip');
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _isLoggedIn
                                  ? BottomNavScreen()
                                  : LoginScreen()),
                          (route) => false);
                    },
                    done: const Text("Selesai",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    onDone: () {
                      print('done');
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _isLoggedIn
                                  ? BottomNavScreen()
                                  : LoginScreen()),
                          (route) => false);
                    },
                  );
                }
              } else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          )),
    );
  }
}

void scheduleAlarm(DateTime scheduledNotificationDateTime, String body) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'alarm_id',
    'alarm_id',
    'Channel alarm',
    icon: 'ic_stat_onesignal_default',
  );

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Makassar'));

  var scheduleTime = tz.TZDateTime.from(
      scheduledNotificationDateTime, tz.getLocation('Asia/Makassar'));

  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
      0, 'Pengingat', body, scheduleTime, platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true);
}
