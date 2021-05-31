import 'dart:async';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/login_screen.dart';
import 'package:spo_balaesang/screen/on_boarding_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoggedIn = false;
  bool _isFirstSeen;

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

  Future<void> checkIsFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefsSeenKey)) {
      setState(() {
        _isFirstSeen = true;
      });
    } else {
      prefs.setBool(prefsSeenKey, true);
      setState(() {
        _isFirstSeen = false;
      });
    }
  }

  Future<void> _checkIfLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(prefsTokenKey);
    if (token != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  void navigationPage() {
    final Widget _page = _isLoggedIn ? BottomNavScreen() : LoginScreen();
    if (_isFirstSeen) {
      Get.off<Widget>(() => _page,
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 500));
    } else {
      Get.off<Widget>(() => OnBoardingScreen(page: _page));
    }
  }

  Future<Timer> _loadWidget() async {
    const Duration _duration = Duration(seconds: 5);
    return Timer(_duration, navigationPage);
  }

  Future<void> _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      Get.defaultDialog(
        title: 'Perhatian',
        content: const Center(
          child: Text(
            'Tidak dapat mendeteksi lokasi saat ini! Pastikan GPS sudah aktif dan coba lagi!',
            textAlign: TextAlign.center,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final _serviceEnabled =
                  await location.Location().requestService();
              if (!_serviceEnabled) {
                const AndroidIntent intent = AndroidIntent(
                    action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                intent.launch();
              }
              Get.back();
            },
            child: const Text('OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                )),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('TIDAK',
                style: TextStyle(
                  color: Colors.blueAccent,
                )),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    _checkIfLoggedIn();
    checkIsFirstSeen();
    super.initState();
    _askPermission();
    _checkGps();
    _loadWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
        Color(0xFF6B8EEF),
        Color(0xFF0C2979),
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/launcher/icon.png',
                    width: Get.width * 0.3,
                  ),
                  sizedBoxH4,
                  const Text(
                    'SiAP Balaesang',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const SpinKitFadingCircle(
                    color: Colors.white,
                    size: 35.0,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const <Widget>[
                      Spacer(),
                      Text('SiAP Balaesang',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 2.0),
                      Text('v5.0.3', style: TextStyle(color: Colors.white)),
                      Spacer()
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: Get.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Spacer(),
                          Image.asset(
                            'assets/logo/banuacoders.png',
                            width: Get.width * 0.25,
                            fit: BoxFit.fitHeight,
                          ),
                          const Spacer(),
                          verticalDiv,
                          const Spacer(),
                          Image.asset(
                            'assets/logo/balaesang.png',
                            width: Get.width * 0.25,
                            fit: BoxFit.scaleDown,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
