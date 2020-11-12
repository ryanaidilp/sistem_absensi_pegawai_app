import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

Future showAlertDialog(String type, String title, String content,
    BuildContext context, bool dismissible) async {
  return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) {
        List<Widget> actions = type == 'success'
            ? []
            : [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'))
              ];
        var color = type == 'success' ? Colors.green : Colors.red;
        var icon = type == 'success' ? Icons.check_circle : Icons.dangerous;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 72,
              ),
              Text(content),
            ],
          ),
          actions: actions,
        );
      });
}

Future showErrorDialog(BuildContext context, Map<String, dynamic> json) {
  return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Column(
            children: const <Widget>[
              Icon(
                Icons.dangerous,
                color: Colors.red,
                size: 72.0,
              ),
              Text('Gagal')
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(json['message']),
              SizedBox(height: 10.0),
              Column(
                  children: (json['errors'] as Map<String, dynamic>)
                      .entries
                      .map((e) => Text(e.value[0]))
                      .toList()),
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Ok'))
          ],
        );
      });
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
    title: "Izin Absen",
    body: "Ajukan izin absen melalui aplikasi.",
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
