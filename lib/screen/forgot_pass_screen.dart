import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPassScreen extends StatelessWidget {
  double getSmallDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 2 / 3;

  double getBigDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 7 / 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: -getSmallDiameter(context) / 3,
            top: -getSmallDiameter(context) / 3,
            child: Container(
              width: getSmallDiameter(context),
              height: getSmallDiameter(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Colors.lightBlue[200], Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
          ),
          Positioned(
            left: -getBigDiameter(context) / 4,
            top: -getBigDiameter(context) / 4,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'SPO',
                    style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Text(
                    'Sistem Presensi Online',
                    style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                ],
              ),
              width: getBigDiameter(context),
              height: getBigDiameter(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Colors.blueAccent[700], Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListView(
              children: <Widget>[
                ClipRRect(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.0, 350, 5.0, 10),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 25),
                    child: Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Tekan tombol dibawah untuk menghubungi administrator sistem dan melaporkan masalah anda',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            SizedBox(height: 15.0),
                            SizedBox(
                              height: 30.0,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: RaisedButton(
                                onPressed: () {
                                  launch('tel:ADMIN_PHONE_NUMBER');
                                },
                                color: Colors.blueAccent,
                                textColor: Colors.white,
                                child: Text('Hubungi'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
