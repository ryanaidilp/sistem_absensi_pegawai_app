import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/main.dart';
import 'package:spo_balaesang/models/presence.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/change_pass_screen.dart';
import 'package:spo_balaesang/screen/employee_outstation.dart';
import 'package:spo_balaesang/screen/employee_permission.dart';
import 'package:spo_balaesang/screen/login_screen.dart';
import 'package:spo_balaesang/screen/outstation_list_screen.dart';
import 'package:spo_balaesang/screen/permission_list_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class ApplicationScreen extends StatefulWidget {
  @override
  _ApplicationScreenState createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  User user;
  bool _isAlarmActive = false;
  List<Presence> _presences;

  Future<void> getUser() async {
    var sp = await SharedPreferences.getInstance();
    var _data = sp.get(PREFS_USER_KEY);
    var _alarm = false;
    if (sp.containsKey(PREFS_ALARM_KEY)) {
      _alarm = sp.get(PREFS_ALARM_KEY);
    } else {
      sp.setBool(PREFS_ALARM_KEY, _alarm);
    }
    Map<String, dynamic> _json = jsonDecode(_data);
    if (_alarm) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
    setState(() {
      user = User.fromJson(_json);
      _presences = user.presences;
      _isAlarmActive = _alarm;
      if (_isAlarmActive) {
        _presences.forEach(_setAlarm);
      }
    });
  }

  Future<void> logout() async {
    try {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Column(
                children: <Widget>[
                  Icon(
                    Icons.dangerous,
                    color: Colors.red,
                    size: 72,
                  ),
                  Text('Keluar'),
                ],
              ),
              content: Text('Apakah anda yakin ingin keluar dari aplikasi?'),
              actions: [
                FlatButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final ProgressDialog pd =
                          ProgressDialog(context, isDismissible: false);
                      pd.show();
                      final dataRepo =
                          Provider.of<DataRepository>(context, listen: false);
                      final Map<String, dynamic> _response =
                          await dataRepo.logout();
                      if (_response['success']) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove(PREFS_TOKEN_KEY);
                        prefs.remove(PREFS_USER_KEY);
                        prefs.remove(PREFS_ALARM_KEY);
                        pd.hide();
                        OneSignal.shared.removeExternalUserId();
                        Get.off(LoginScreen());
                      }
                    },
                    child: Text('Ya')),
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Tidak')),
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _handleSelected(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    prefs.setBool(PREFS_ALARM_KEY, value);
    setState(() {
      _isAlarmActive = value;
    });
    if (value) {
      _presences.forEach(_setAlarm);
      showAlertDialog(
          'success', 'Sukses', 'Berhasil mengaktifkan alarm!', context, true);
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
      showAlertDialog(
          'success', 'Sukses', 'Berhasil menonaktifkan alarm!', context, true);
    }
  }

  void _setAlarm(Presence presence) {
    if (presence.startTime.isAfter(DateTime.now())) {
      scheduleAlarm(presence.startTime.subtract(Duration(minutes: 10)),
          '${presence.codeType} akan dimulai dalam 10 menit!');
    } else {
      if (presence.startTime.weekday < DateTime.friday) {
        scheduleAlarm(presence.startTime.add(Duration(days: 1)),
            '${presence.codeType} akan dimulai dalam 10 menit!');
      }
    }

    if (presence.endTime.isAfter(DateTime.now())) {
      scheduleAlarm(presence.endTime.subtract(Duration(minutes: 10)),
          '${presence.codeType} akan selesai dalam 10 menit!');
    } else {
      if (presence.endTime.weekday < DateTime.friday) {
        scheduleAlarm(presence.endTime.add(Duration(days: 1)),
            '${presence.codeType} akan selesai dalam 10 menit!');
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Widget _buildStakeholderMenu() {
    if (user?.position != 'Camat') {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Atasan',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
              color: Colors.blueAccent),
        ),
        Divider(thickness: 1.0),
        SizedBox(height: 10.0),
        Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EmployeePermissionScreen()));
            },
            child: ListTile(
              leading: Icon(
                Icons.check,
                color: Colors.green,
                size: 32.0,
              ),
              title: Text(
                'Persetujuan Izin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Setujui Izin yang diajukan',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EmployeeOutstationScreen()));
            },
            child: ListTile(
              leading: Icon(
                Icons.check,
                color: Colors.green,
                size: 32.0,
              ),
              title: Text(
                'Persetujuan Dinas Luar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Setujui Dinas Luar yang diajukan',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ),
        SizedBox(height: 30.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: Image.asset('assets/logo/logo.png'),
        leadingWidth: MediaQuery.of(context).size.width * 0.25,
        title: const Text('Aplikasi'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pengaturan & Personalisasi',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.blueAccent),
              ),
              Divider(thickness: 1.0),
              SizedBox(height: 10.0),
              Card(
                elevation: 2.0,
                child: SwitchListTile(
                  onChanged: _handleSelected,
                  activeColor: Colors.blueAccent,
                  value: _isAlarmActive,
                  secondary: Icon(
                    Icons.alarm,
                    color: Colors.indigo,
                    size: 32.0,
                  ),
                  title: Text(
                    'Aktifkan Alarm Absensi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Pengingat waktu absen',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Text(
                'Presensi',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.blueAccent),
              ),
              Divider(thickness: 1.0),
              SizedBox(height: 10.0),
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PermissionListScreen()));
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.purple,
                      size: 32.0,
                    ),
                    title: Text(
                      'Izin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Pengajuan dan riwayat Izin',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => OutstationListScreen()));
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.card_travel_rounded,
                      color: Colors.yellow[800],
                      size: 32.0,
                    ),
                    title: Text(
                      'Dinas Luar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Pengajuan dan riwayat Dinas Luar',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              _buildStakeholderMenu(),
              Text(
                'Akun',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.blueAccent),
              ),
              Divider(thickness: 1.0),
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChangePasswordScreen()));
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.lock_outline,
                      color: Colors.blueAccent,
                      size: 32.0,
                    ),
                    title: Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Ubah password akun',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    logout();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.red,
                        size: 32.0,
                      ),
                      title: Text(
                        'Keluar Dari Aplikasi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Keluar dari aplikasi dan menghapus sesi saat ini. Gunakan ini jika aplikasi terasa berat atau anda ingin mengganti akun.',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
