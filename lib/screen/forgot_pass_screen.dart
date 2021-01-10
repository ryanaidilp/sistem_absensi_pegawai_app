import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPassScreen extends StatelessWidget {
  final double getSmallDiameter = Get.width * 2 / 3;

  final double getBigDiameter = Get.width * 7 / 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: -getSmallDiameter / 3,
            top: -getSmallDiameter / 3,
            child: Container(
              width: getSmallDiameter,
              height: getSmallDiameter,
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
            left: -getBigDiameter / 4,
            top: -getBigDiameter / 4,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 200,
                  ),
                  Text(
                    'Sistem Absensi Pegawai',
                    style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                ],
              ),
              width: getBigDiameter,
              height: getBigDiameter,
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
                    margin:
                        EdgeInsets.fromLTRB(5.0, Get.height * 0.35, 5.0, 10),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 25),
                    child: Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 15.0),
                            Text(
                              'Fajrian Aidil Pratama',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Administrator\nFounder of @BanuaCoders',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2.0),
                            Divider(
                              color: Colors.black26,
                              thickness: 1,
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Tekan tombol dibawah untuk menghubungi administrator sistem dan melaporkan masalah anda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    launch('tel:ADMIN_PHONE_NUMBER');
                                  },
                                  color: Colors.blueAccent,
                                  icon: Icon(Icons.phone),
                                  enableFeedback: true,
                                  tooltip: 'Hubungi via Telpon',
                                ),
                                IconButton(
                                  onPressed: () async {
                                    var whatsappUrl =
                                        "whatsapp://send?phone=ADMIN_PHONE_NUMBER";
                                    await canLaunch(whatsappUrl)
                                        ? launch(whatsappUrl)
                                        : Get.defaultDialog(
                                            title: 'Gagal',
                                            content: Text(
                                                'WhatsApp tidak ditemukan!'));
                                  },
                                  color: Colors.green[600],
                                  icon: FaIcon(FontAwesomeIcons.whatsapp),
                                  enableFeedback: true,
                                  tooltip: 'Hubungi via WA',
                                ),
                              ],
                            )
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
