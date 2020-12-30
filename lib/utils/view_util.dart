import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

Future showAlertDialog(
    String type, String title, String content, bool dismissible) async {
  final List<Widget> actions = type == 'success'
      ? []
      : [
          FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
          )
        ];
  final color = type == 'success' ? Colors.green : Colors.red;
  final icon = type == 'success' ? Icons.check_circle : Icons.dangerous;
  return Get.defaultDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 72,
          ),
          const SizedBox(height: 10.0),
          Center(
              child: Text(
            content,
            textAlign: TextAlign.center,
          )),
        ],
      ),
      actions: actions,
      barrierDismissible: dismissible);
}

Future showErrorDialog(Map<String, dynamic> json) {
  return Get.defaultDialog(
    title: 'Gagal',
    content: Column(
      children: <Widget>[
        const Icon(
          Icons.dangerous,
          color: Colors.red,
          size: 72.0,
        ),
        const SizedBox(height: 10.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              json['message'],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Column(
                children: (json['errors'] as Map<String, dynamic>)
                    .entries
                    .map((e) => Text(e.value[0]))
                    .toList()),
          ],
        ),
      ],
    ),
    cancel: FlatButton(
      onPressed: () {
        Get.back();
      },
      child: Text(
        'OK',
        style: TextStyle(
          color: Colors.blueAccent,
        ),
      ),
    ),
  );
}

List<PageViewModel> onBoardingScreens = [
  PageViewModel(
    title: "QR Code",
    body: "Lakukan presensi cukup dengan scan QR Code",
    image: Center(
        child: Container(
      child: FlareActor(
        'assets/flare/qrcode.flr',
        fit: BoxFit.contain,
        animation: 'scan',
        alignment: Alignment.center,
      ),
    )),
    decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent),
        bodyTextStyle:
            TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal)),
  ),
  PageViewModel(
    title: "Izin Absen & Dinas Luar",
    body: "Ajukan izin absen dan dinas luar melalui aplikasi.",
    image: Center(
        child: Container(
      child: FlareActor(
        'assets/flare/documents.flr',
        fit: BoxFit.contain,
        animation: 'document',
        alignment: Alignment.center,
      ),
    )),
    decoration: const PageDecoration(
        titleTextStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent),
        bodyTextStyle:
            TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal)),
  )
];
