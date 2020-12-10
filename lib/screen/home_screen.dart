import 'dart:async';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/change_pass_screen.dart';
import 'package:spo_balaesang/screen/employee_list_screen.dart';
import 'package:spo_balaesang/screen/employee_outstation.dart';
import 'package:spo_balaesang/screen/employee_permission.dart';
import 'package:spo_balaesang/screen/login_screen.dart';
import 'package:spo_balaesang/screen/notification_list_screen.dart';
import 'package:spo_balaesang/screen/outstation_list_screen.dart';
import 'package:spo_balaesang/screen/permission_list_screen.dart';
import 'package:spo_balaesang/screen/presence_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double getBigDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width;

  List<String> _images = new List();
  User user;
  List<Employee> _users;
  bool isLoading = false;

  Widget _buildImageStack() {
    if (_images.isNotEmpty) {
      var widgets = _images
          .sublist(0, 5)
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(right: 4.0, top: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  e,
                  height: 55.0,
                ),
              ),
            ),
          )
          .toList();
      widgets.add(Padding(
        padding: const EdgeInsets.only(right: 4.0, top: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Material(
            color: Colors.grey[300],
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        EmployeeListScreen(employees: this._users)));
              },
              splashColor: Colors.white,
              borderRadius: BorderRadius.circular(100),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ));
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgets,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(
            7,
            (index) => Shimmer.fromColors(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0, top: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Material(
                        color: Colors.grey[300],
                        child: InkWell(
                          onTap: () {},
                          splashColor: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  baseColor: Colors.grey[400],
                  highlightColor: Colors.white,
                )),
      ),
    );
  }

  Future<void> _getAllEmployee({ProgressDialog pd}) async {
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      List<Employee> users = await dataRepo.getAllEmployee();
      setState(() {
        _users = users;
        _images = users
            .map((e) =>
                "https://ui-avatars.com/api/?name=${e.name.replaceAll(' ', '+')}&size=248"
                    .toString())
            .toList();
        if (pd != null && pd.isShowing()) pd?.hide();
      });
    } catch (e) {
      print(e.toString());
    }
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
                        prefs.remove('token');
                        prefs.remove('user');
                        pd.hide();
                        OneSignal.shared.removeExternalUserId();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                            (route) => false);
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

  Future<void> _getUser() async {
    try {
      setState(() {
        isLoading = true;
      });
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      User _user = await dataRepo.getMyData();
      OneSignal.shared.setExternalUserId(_user.id.toString());
      setState(() {
        user = _user;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildShimmerSection(double width, double height) {
    return Shimmer.fromColors(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.blueAccent),
          width: width,
          height: height,
        ),
        baseColor: Colors.grey[300],
        highlightColor: Colors.white);
  }

  Widget _buildUserNameSection() {
    return user == null
        ? _buildShimmerSection(200, 20)
        : Text(
            '${user.name}',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w600),
          );
  }

  Widget _buildPositionSection() {
    if (user != null) {
      var text = user.position == 'Camat' || user.position == 'Sekcam'
          ? user.position
          : "${user.position} - ${user.department}";
      return AutoSizeText(
        '($text)',
        style: TextStyle(color: Colors.white),
        maxFontSize: 14.0,
        minFontSize: 12.0,
      );
    }
    return _buildShimmerSection(60, 15);
  }

  Color _checkStatusColor(String status) {
    switch (status) {
      case 'Tidak Hadir':
        return Colors.red;
      case 'Tepat Waktu':
        return Colors.green;
      case 'Terlambat':
        return Colors.orange;
      case 'Dinas Luar':
      case 'Izin':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  List<Widget> _buildPresenceSection() {
    if (isLoading) {
      return [
        _buildShimmerSection(MediaQuery.of(context).size.width * 0.9, 60),
        SizedBox(height: 10.0),
        _buildShimmerSection(MediaQuery.of(context).size.width * 0.9, 60),
        SizedBox(height: 10.0),
        _buildShimmerSection(MediaQuery.of(context).size.width * 0.9, 60),
        SizedBox(height: 10.0),
        _buildShimmerSection(MediaQuery.of(context).size.width * 0.9, 60),
        SizedBox(height: 10.0),
      ];
    }
    if (user != null && user.presences.isNotEmpty) {
      return user.presences.map((presence) {
        var color = _checkStatusColor(presence.status);
        return Card(
          child: ListTile(
            title: Text(
              '${presence.codeType} : ${presence.attendTime.isEmpty ? '-' : presence.attendTime}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${presence.status}',
              style: TextStyle(color: color),
            ),
            dense: true,
            trailing: Text(
              '${DateFormat.yMMMd().format(presence.date)}',
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ),
        );
      }).toList();
    }
    return [
      Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Container(
              width: 150,
              height: 150,
              child: FlareActor(
                'assets/flare/empty.flr',
                fit: BoxFit.contain,
                animation: 'empty',
                alignment: Alignment.center,
              ),
            ),
            Text('Tidak ada absen hari ini!')
          ]))
    ];
  }

  int checkTime() {
    if (user != null &&
        user.nextPresence != null &&
        user.nextPresence.startTime.isAfter(DateTime.now())) {
      return user?.nextPresence?.startTime?.millisecondsSinceEpoch;
    }
    return user?.nextPresence?.endTime?.millisecondsSinceEpoch;
  }

  String _checkTimeLabel() {
    if (user != null &&
        user.nextPresence != null &&
        user.nextPresence.startTime.isAfter(DateTime.now())) {
      return "MULAI DALAM :";
    }
    return "SELESAI DALAM :";
  }

  Widget _checkStatusIcon(String status) {
    switch (status) {
      case 'Tepat Waktu':
        return Column(
          children: <Widget>[
            Icon(Icons.check, color: _checkStatusColor(status), size: 54),
            Text(
              status,
              style: TextStyle(color: Colors.blueGrey),
            )
          ],
        );
      case 'Tidak Hadir':
      case 'Terlambat':
        return Column(
          children: <Widget>[
            Icon(Icons.warning, color: _checkStatusColor(status), size: 54),
            Text(
              status,
              style: TextStyle(color: Colors.blueGrey),
            )
          ],
        );
      case 'Dinas Luar':
      case 'Izin':
        return Column(
          children: <Widget>[
            Icon(Icons.calendar_today,
                size: 54, color: _checkStatusColor(status)),
            Text(
              status,
              style: TextStyle(color: Colors.blueGrey),
            )
          ],
        );
      default:
        return Column(
          children: <Widget>[
            Icon(Icons.warning, color: _checkStatusColor(status), size: 54),
            Text(
              status,
              style: TextStyle(color: Colors.blueGrey),
            )
          ],
        );
    }
  }

  Widget _buildTimerSection() {
    if (isLoading) {
      return _buildShimmerSection(MediaQuery.of(context).size.width * 0.8, 60);
    }

    if (user?.nextPresence != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    DateFormat.EEEE().format(user.nextPresence.date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('|'),
                  const SizedBox(width: 5.0),
                  Text(
                    DateFormat.yMMMd().format(user.nextPresence.date),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('|'),
                  const SizedBox(width: 5.0),
                  Text(
                    user.nextPresence.attendTime.isEmpty
                        ? '-'
                        : '${user.nextPresence.attendTime} WITA',
                  ),
                ],
              ),
              Divider(
                thickness: 1.0,
                color: Colors.black26,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'SKEMA ABSENSI :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(user.nextPresence.codeType),
                      const SizedBox(height: 10.0),
                      const Text(
                        'JADWAL ABSENSI :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('hh:mm:ss')
                            .format(user.nextPresence.startTime),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'STATUS KEHADIRAN :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.nextPresence.status,
                        style: TextStyle(
                            color: _checkStatusColor(user.nextPresence.status)),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        _checkTimeLabel(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      CountdownTimer(
                        onEnd: () {
                          _getUser();
                        },
                        endTime: checkTime(),
                        emptyWidget: Text(
                          'Semua absen hari ini telah selesai',
                        ),
                      ),
                    ],
                  ),
                  user.nextPresence.attendTime.isNotEmpty
                      ? _checkStatusIcon(user.nextPresence.status)
                      : user.nextPresence.startTime.isAfter(DateTime.now())
                          ? _checkStatusIcon(user.nextPresence.status)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Card(
                                color: Colors.green[300],
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => PresenceScreen()))
                                        .then((value) {
                                      _getUser();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.qr_code_rounded,
                                          size: 84,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          'Mulai Absen',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (user?.holiday != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Libur Nasional. ${DateFormat('EEEE, d MMMM Y').format(user.holiday['date'])}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text('${user.holiday['name']}'),
              ],
            ),
          ),
        ),
      );
    }

    if (user.isWeekend) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: const <Widget>[
                Text(
                  'Akhir Pekan',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                Text('Tidak Ada Absen hari ini'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: const <Widget>[
              Text(
                'Selesai',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              SizedBox(height: 10.0),
              Text('Semua presensi hari ini telah selesai!'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPNSHonorerSection() {
    var pns = _countUserByStatus('PNS');
    var honorer = _countUserByStatus('Honorer');
    return Text(
      '$pns PNS/$honorer Honorer',
      style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 12.0, color: Colors.grey),
    );
  }

  int _countUserByStatus(String status) {
    var count = 0;

    if (_users == null) {
      return count;
    }
    count = _users.where((element) => element.status == status).length +
        (this.user?.status == status ? 1 : 0);
    return count;
  }

  @override
  void initState() {
    super.initState();
    _getUser();
    _getAllEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0.0,
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  (user != null && user.unreadNotification > 0)
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) => NotificationListScreen()))
                      .then((value) => _getUser());
                },
              ),
              (user != null && user.unreadNotification > 0)
                  ? Positioned(
                      right: 8,
                      top: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        child: Text(
                          user?.unreadNotification.toString(),
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                logout();
              })
        ],
        title: Image.asset(
          'assets/logo/logo.png',
          width: MediaQuery.of(context).size.width * 0.3,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: RotatedBox(
          quarterTurns: 0,
          child: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          ProgressDialog pd = ProgressDialog(context, isDismissible: false);
          pd.show();
          _getUser();
          _getAllEmployee(pd: pd);
        },
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Stack(
            overflow: Overflow.clip,
            children: <Widget>[
              Positioned(
                top: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 200),
                  painter: RPSCustomPainter(),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Selamat Datang',
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                    ),
                    SizedBox(height: 10.0),
                    _buildUserNameSection(),
                    SizedBox(height: 5.0),
                    _buildPositionSection(),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: ClipRRect(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '${_users == null ? 0 : (_users.length + 1)} Pegawai',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 10.0),
                                _buildPNSHonorerSection()
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildImageStack(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Absen Selanjutnya',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                    Center(
                      child: _buildTimerSection(),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Menu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Center(
                      child: Column(
                        children: <Widget>[
                          Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => PermissionListScreen()));
                              },
                              child: ListTile(
                                leading: Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.green,
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
                          Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => OutstationListScreen()));
                              },
                              child: ListTile(
                                leading: Icon(
                                  Icons.card_travel_rounded,
                                  color: Colors.deepOrange,
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
                          Card(
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
                          user?.position == 'Camat'
                              ? Card(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  EmployeePermissionScreen()));
                                    },
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 32.0,
                                      ),
                                      title: Text(
                                        'Persetujuan Izin',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Setujui Izin yang diajukan',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          user?.position == 'Camat'
                              ? Card(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  EmployeeOutstationScreen()));
                                    },
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 32.0,
                                      ),
                                      title: Text(
                                        'Persetujuan Dinas Luar',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Setujui Dinas Luar yang diajukan',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Absen Hari Ini',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                    Center(
                      child: Column(
                        children: _buildPresenceSection(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
    paint_0.shader = ui.Gradient.linear(
        Offset(size.width * 0.50, 0),
        Offset(size.width * 0.50, size.height * 0.95),
        [Colors.blueAccent, Colors.blueAccent, Colors.blueAccent],
        [0.00, 0.49, 1.00]);

    Path path_0 = Path();
    path_0.moveTo(0, 0);
    path_0.quadraticBezierTo(size.width * -0.01, size.height * 0.57,
        size.width * 0.06, size.height * 0.75);
    path_0.cubicTo(size.width * 0.14, size.height * 0.97, size.width * 0.29,
        size.height * 0.86, size.width * 0.50, size.height * 0.95);
    path_0.cubicTo(size.width * 0.71, size.height * 0.87, size.width * 0.87,
        size.height * 0.97, size.width * 0.94, size.height * 0.75);
    path_0.quadraticBezierTo(
        size.width * 1.01, size.height * 0.57, size.width, 0);
    path_0.lineTo(0, 0);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
