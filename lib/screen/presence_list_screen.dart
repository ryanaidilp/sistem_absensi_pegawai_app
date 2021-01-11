import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/presence.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/image_error_widget.dart';

class PresenceListScreen extends StatefulWidget {
  PresenceListScreen({this.employee, this.date});

  final Employee employee;
  final DateTime date;

  @override
  _PresenceListScreenState createState() => _PresenceListScreenState();
}

class _PresenceListScreenState extends State<PresenceListScreen> {
  Employee employee;
  DateTime date;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    employee = widget.employee;
    date = widget.date;
    super.initState();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  _cancelAttendance(Presence outstation) {
    Get.defaultDialog(
        title: 'Alasan Pembatalan!',
        content: Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: Get.width * 0.9,
            child: TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                  labelText: 'Alasan',
                  focusColor: Colors.blueAccent,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent))),
            ),
          ),
        ),
        confirm: RaisedButton(
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: () {
            Get.back();
            _sendData(outstation);
          },
          child: Text('OK'),
        ));
  }

  Future<void> _sendData(Presence presence) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'presence_id': presence.id,
        'reason': _reasonController.value.text
      };
      http.Response response = await dataRepo.cancelAttendance(data);
      Map<String, dynamic> _res = jsonDecode(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'], false);
        Timer(Duration(seconds: 5), () => Get.off(BottomNavScreen()));
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      pd.hide();
      print(e.toString());
    }
  }

  final TextStyle labelTextStyle = TextStyle(color: Colors.grey[600]);

  Widget _showImage(Presence presence) {
    if (presence.photo.isEmpty) {
      return Image.asset(
        'assets/images/upload_placeholder.png',
      );
    }
    return InkWell(
      onTap: () {
        Get.to(ImageDetailScreen(
          tag: presence.id.toString(),
          imageUrl: presence.photo,
        ));
      },
      child: Hero(
        tag: presence.id.toString(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: CachedNetworkImage(
            placeholder: (_, __) => Container(
              child: Stack(
                children: <Widget>[
                  Image.asset('assets/images/upload_placeholder.png'),
                  Center(
                    child: SizedBox(
                      child: SpinKitFadingGrid(
                        size: 25,
                        color: Colors.blueAccent,
                      ),
                      width: 25.0,
                      height: 25.0,
                    ),
                  ),
                ],
              ),
            ),
            imageUrl: presence.photo,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => ImageErrorWidget(),
            width: Get.width,
            height: 250.0,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(Presence presence) {
    if (presence.status != 'Tepat Waktu' && presence.status != 'Terlambat') {
      return SizedBox();
    }
    return Column(
      children: <Widget>[
        Divider(),
        SizedBox(
          width: Get.width * 0.9,
          child: RaisedButton(
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: Text('Batalkan'),
            onPressed: () {
              _cancelAttendance(presence);
            },
          ),
        )
      ],
    );
  }

  Widget _buildPresenceSection() {
    if (employee.presences.isEmpty) {
      return Center(
        child: Column(
          children: <Widget>[
            Container(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor(
                'assets/flare/not_found.flr',
                animation: 'empty',
              ),
            ),
            const Text('Tidak ada presensi'),
          ],
        ),
      );
    }

    return Column(
      children: employee.presences.map((presence) {
        String status = presence.status;
        if (presence.status == 'Terlambat') {
          var duration =
              calculateLateInMinutes(presence.startTime, presence.attendTime);
          status += ' $duration';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          width: Get.width,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    presence.codeType,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Divider(thickness: 1.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Jam Absen',
                        style: labelTextStyle,
                      ),
                      Text(
                        presence.attendTime.isEmpty ? '-' : presence.attendTime,
                      )
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Poin Kehadiran',
                        style: labelTextStyle,
                      ),
                      Text(
                        '${formatPercentage(checkPresencePercentage(presence.status))}',
                        style: TextStyle(
                          color: checkStatusColor(presence.status),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Status Kehadiran',
                        style: labelTextStyle,
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          color: checkStatusColor(presence.status),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Divider(thickness: 1),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      SizedBox(width: 4.0),
                      Text('Lokasi', style: labelTextStyle)
                    ],
                  ),
                  SizedBox(height: 4.0),
                  AutoSizeText(
                    presence.location.address.isEmpty
                        ? '-'
                        : presence.location.address,
                    maxLines: 3,
                    minFontSize: 10.0,
                    maxFontSize: 12.0,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Divider(thickness: 1),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.photo,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      SizedBox(width: 4.0),
                      Text('Foto Wajah', style: labelTextStyle)
                    ],
                  ),
                  SizedBox(height: 4.0),
                  _showImage(presence),
                  SizedBox(height: 8.0),
                  _buildCancelButton(presence)
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presensi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: Get.width,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Info Pegawai',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Nama    : ',
                              style: labelTextStyle,
                            ),
                            Text(employee.name)
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Bagian : ',
                              style: labelTextStyle,
                            ),
                            Text(employee.department)
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Jabatan : ',
                              style: labelTextStyle,
                            ),
                            Text(employee.position)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Daftar Kehadiran',
                style: labelTextStyle.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                  'Tanggal Presensi: ${DateFormat.yMMMMEEEEd('id_ID').format(date)}'),
              SizedBox(height: 8.0),
              _buildPresenceSection()
            ],
          ),
        ),
      ),
    );
  }
}
