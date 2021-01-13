import 'dart:async';
import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/presence.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_presence_card_widget.dart';
import 'package:spo_balaesang/widgets/user_info_card_widget.dart';

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
        Color color = checkStatusColor(presence.status);
        String status = presence.status;
        if (presence.status == 'Terlambat') {
          var duration =
              calculateLateTime(presence.startTime, presence.attendTime);
          status += ' $duration';
        }
        return EmployeePresenceCardWidget(
          isApprovalCard: true,
          photo: presence.photo,
          heroTag: presence.id.toString(),
          status: status,
          color: color,
          address: presence.location.address,
          attendTime: presence.attendTime,
          point: formatPercentage(checkPresencePercentage(presence.status)),
          presenceType: presence.codeType,
          buttonWidget: SizedBox(
            width: Get.width * 0.9,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.blueAccent,
              textColor: Colors.white,
              child: Text('Batalkan'),
              onPressed: () {
                _cancelAttendance(presence);
              },
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
                child: UserInfoCardWidget(
                  name: employee.name,
                  position: employee.position,
                  nip: employee.nip,
                  department: employee.department,
                  rank: employee.rank,
                  group: employee.group,
                  status: employee.status,
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
