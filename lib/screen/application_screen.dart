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
import 'package:spo_balaesang/screen/employee_attendance_screen.dart';
import 'package:spo_balaesang/screen/employee_outstation.dart';
import 'package:spo_balaesang/screen/employee_paid_leave_screen.dart';
import 'package:spo_balaesang/screen/employee_permission.dart';
import 'package:spo_balaesang/screen/forgot_pass_screen.dart';
import 'package:spo_balaesang/screen/login_screen.dart';
import 'package:spo_balaesang/screen/outstation_list_screen.dart';
import 'package:spo_balaesang/screen/paid_leave_list_screen.dart';
import 'package:spo_balaesang/screen/permission_list_screen.dart';
import 'package:spo_balaesang/screen/regulation_screen.dart';
import 'package:spo_balaesang/screen/report_screen.dart';
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

  Future<void> loadData() async {
    final sp = await SharedPreferences.getInstance();
    final _data = sp.get(prefsUserKey);
    bool _alarm = false;

    if (sp.containsKey(prefsAlarmKey)) {
      _alarm = sp.get(prefsAlarmKey) as bool;
    } else {
      sp.setBool(prefsAlarmKey, _alarm);
    }

    final Map<String, dynamic> _json =
        jsonDecode(_data.toString()) as Map<String, dynamic>;

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
      Get.defaultDialog(
          title: 'Keluar',
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: const <Widget>[
                Icon(
                  Icons.dangerous,
                  color: Colors.red,
                  size: 72,
                ),
                sizedBoxH10,
                Text('Apakah anda yakin ingin keluar dari aplikasi?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () async {
                  Get.back();
                  final ProgressDialog pd =
                      ProgressDialog(context, isDismissible: false);
                  pd.show();
                  final dataRepo =
                      Provider.of<DataRepository>(context, listen: false);
                  final Map<String, dynamic> _response =
                      await dataRepo.logout();
                  if (_response['success'] as bool) {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove(prefsTokenKey);
                    prefs.remove(prefsUserKey);
                    prefs.remove(prefsAlarmKey);
                    pd.hide();
                    OneSignal.shared.removeExternalUserId();
                    Get.off(() => LoginScreen());
                  }
                },
                child: const Text('Ya',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ))),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Tidak',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ))),
          ]);
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
    }
  }

  Future<void> _handleSelected(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    prefs.setBool(prefsAlarmKey, value);
    setState(() {
      _isAlarmActive = value;
    });
    if (value) {
      _presences.forEach(_setAlarm);
      showAlertDialog('success', 'Sukses', 'Berhasil mengaktifkan alarm!',
          dismissible: true);
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
      showAlertDialog('success', 'Sukses', 'Berhasil menonaktifkan alarm!',
          dismissible: true);
    }
  }

  void _setAlarm(Presence presence) {
    const dur10Min = Duration(minutes: 10);
    const dur1Day = Duration(days: 1);
    if (presence.startTime.isAfter(DateTime.now())) {
      scheduleAlarm(presence.startTime.subtract(dur10Min),
          '${presence.codeType} akan dimulai dalam 10 menit!');
    } else {
      if (presence.startTime.weekday < DateTime.friday) {
        scheduleAlarm(presence.startTime.add(dur1Day),
            '${presence.codeType} akan dimulai dalam 10 menit!');
      }
    }

    if (presence.endTime.isAfter(DateTime.now())) {
      scheduleAlarm(presence.endTime.subtract(dur10Min),
          '${presence.codeType} akan selesai dalam 10 menit!');
    } else {
      if (presence.endTime.weekday < DateTime.friday) {
        scheduleAlarm(presence.endTime.add(dur1Day),
            '${presence.codeType} akan selesai dalam 10 menit!');
      }
    }
  }

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget _buildStakeholderMenu() {
    if (user?.position != 'Camat') {
      return sizedBox;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Atasan',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
              color: Colors.blueAccent),
        ),
        dividerT1,
        sizedBoxH10,
        Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              Get.to(() => EmployeeAttendanceScreen());
            },
            child: const ListTile(
              dense: false,
              leading: Icon(
                Icons.playlist_add_check_rounded,
                color: Colors.green,
                size: 32.0,
              ),
              title: Text(
                'Presensi Pegawai',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Lihat & konfirmasi kehadiran pegawai',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ),
        sizedBoxH10,
        Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              Get.to(() => EmployeePermissionScreen());
            },
            child: const ListTile(
              leading: Icon(
                Icons.playlist_add_check_rounded,
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
        sizedBoxH10,
        Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              Get.to(() => EmployeeOutstationScreen());
            },
            child: const ListTile(
              leading: Icon(
                Icons.playlist_add_check_rounded,
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
        sizedBoxH10,
        Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              Get.to(() => EmployeePaidLeaveScreen());
            },
            child: const ListTile(
              leading: Icon(
                Icons.playlist_add_check_rounded,
                color: Colors.green,
                size: 32.0,
              ),
              title: Text(
                'Persetujuan Cuti',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Setujui Cuti yang diajukan',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ),
        sizedBoxH30,
      ],
    );
  }

  Widget _buildCutiSection() {
    if (user?.status == 'Honorer') {
      return sizedBox;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        sizedBoxH10,
        Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              Get.to(() => PaidLeaveListScreen());
            },
            child: const ListTile(
              leading: Icon(
                Icons.card_giftcard_rounded,
                color: Colors.red,
                size: 32.0,
              ),
              title: Text(
                'Cuti',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Pengajuan dan riwayat Cuti',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ),
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
        leadingWidth: Get.width * 0.25,
        title: const Text('Aplikasi'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Pengaturan & Personalisasi',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.blueAccent),
              ),
              dividerT1,
              sizedBoxH10,
              Card(
                elevation: 2.0,
                child: SwitchListTile(
                  onChanged: _handleSelected,
                  activeColor: Colors.blueAccent,
                  value: _isAlarmActive,
                  secondary: const Icon(
                    Icons.alarm,
                    color: Colors.indigo,
                    size: 32.0,
                  ),
                  title: const Text(
                    'Aktifkan Alarm Absensi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Pengingat waktu absen',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              sizedBoxH30,
              const Text(
                'Presensi',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.blueAccent),
              ),
              dividerT1,
              sizedBoxH10,
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Get.to(() => ReportScreen(user: user));
                  },
                  child: const ListTile(
                    leading: Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.deepOrangeAccent,
                      size: 32.0,
                    ),
                    title: Text(
                      'Statistik',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Lihat statistik presensi anda',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              sizedBoxH10,
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Get.to(() => PermissionListScreen());
                  },
                  child: const ListTile(
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
              sizedBoxH10,
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Get.to(() => OutstationListScreen());
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.card_travel_rounded,
                      color: Colors.yellow[800],
                      size: 32.0,
                    ),
                    title: const Text(
                      'Dinas Luar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Pengajuan dan riwayat Dinas Luar',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              _buildCutiSection(),
              sizedBoxH30,
              _buildStakeholderMenu(),
              const Text(
                'Bantuan',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.blueAccent),
              ),
              dividerT1,
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Get.to(() => ForgotPassScreen());
                  },
                  child: const ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: Colors.pink,
                      size: 32.0,
                    ),
                    title: Text(
                      'Lapor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Lapor kendala & pelanggaran',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              sizedBoxH10,
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Get.to(() => RegulationScreen());
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.room_preferences,
                      color: Colors.lime[800],
                      size: 32.0,
                    ),
                    title: const Text(
                      'Rujukan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Daftar aturan yang menjadi rujukan SiAP Balaesang',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              sizedBoxH30,
              const Text(
                'Akun',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.blueAccent),
              ),
              dividerT1,
              Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: () {
                    Get.to(() => ChangePasswordScreen());
                  },
                  child: const ListTile(
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
              sizedBoxH10,
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
                        color: Colors.red[800],
                        size: 32.0,
                      ),
                      title: const Text(
                        'Keluar Dari Aplikasi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
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
