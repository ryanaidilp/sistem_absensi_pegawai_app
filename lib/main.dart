import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/network/api.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/home_screen.dart';
import 'package:spo_balaesang/screen/login_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';

import 'network/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          title: 'SPO Balaesang',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              backgroundColor: Colors.white,
              scaffoldBackgroundColor: Colors.white),
          home: FutureBuilder<bool>(
            future: _isFirstSeen,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data) {
                  return  _isLoggedIn ? HomeScreen() : LoginScreen();
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
                              builder: (_) =>
                                  _isLoggedIn ? HomeScreen() : LoginScreen()),
                          (route) => false);
                    },
                    done: const Text("Selesai",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    onDone: () {
                      print('done');
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              _isLoggedIn ? HomeScreen() : LoginScreen()),
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
