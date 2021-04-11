import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPassScreen extends StatelessWidget {
  final double getSmallDiameter = Get.width * 2 / 3;

  final double getBigDiameter = Get.width * 7 / 8;

  final String adminPhoneNumber =
      FlutterConfig.get("ADMIN_PHONE_NUMBER").toString();

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
              width: getBigDiameter,
              height: getBigDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Colors.blueAccent[700], Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 200,
                  ),
                  const Text(
                    'Sistem Absensi Pegawai',
                    style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListView(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    margin:
                        EdgeInsets.fromLTRB(5.0, Get.height * 0.35, 5.0, 10),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 25),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            sizedBoxH16,
                            const Text(
                              'Fajrian Aidil Pratama',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Administrator\nFounder of @BanuaCoders',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            sizedBoxH2,
                            const Divider(
                              color: Colors.black26,
                              thickness: 1,
                            ),
                            sizedBoxH2,
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
                                    launch('tel:$adminPhoneNumber');
                                  },
                                  color: Colors.blueAccent,
                                  icon: const Icon(Icons.phone),
                                  tooltip: 'Hubungi via Telpon',
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final String whatsappUrl =
                                        'whatsapp://send?phone=$adminPhoneNumber';
                                    await canLaunch(whatsappUrl)
                                        ? launch(whatsappUrl)
                                        : Get.defaultDialog(
                                            title: 'Gagal',
                                            content: const Text(
                                                'WhatsApp tidak ditemukan!'));
                                  },
                                  color: Colors.green[600],
                                  icon: const FaIcon(FontAwesomeIcons.whatsapp),
                                  tooltip: 'Hubungi via WA',
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
