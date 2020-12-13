import 'dart:async';

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
import 'package:shimmer/shimmer.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/employee_list_screen.dart';
import 'package:spo_balaesang/screen/notification_list_screen.dart';
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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
    if (isLoading) {
      return _buildShimmerSection(200, 20);
    }

    if (user == null) {
      Text(
        'Gagal memuat data',
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
      );
    }

    return Column(
      children: <Widget>[
        Text(
          '${user.name}',
          style: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5.0),
        user.status == 'PNS'
            ? Text(
                'NIP : ${user.nip}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              )
            : SizedBox()
      ],
    );
  }

  Widget _buildPositionSection() {
    if (isLoading) {
      return _buildShimmerSection(60, 15);
    }
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
    return Text(
      'Coba untuk memuat kembali data!',
      style: TextStyle(
          color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
    );
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
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
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
      ])
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
              'Hadir',
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

  Widget _buildStatusSection() {
    if (user.nextPresence.attendTime.isNotEmpty ||
        user.nextPresence.startTime.isAfter(DateTime.now()))
      return _checkStatusIcon(user.nextPresence.status);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Card(
          color: Colors.green[300],
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => PresenceScreen()))
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
    );
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
                      const SizedBox(height: 2.0),
                      Text(user.nextPresence.codeType),
                      const SizedBox(height: 10.0),
                      const Text(
                        'JADWAL ABSENSI :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        children: <Widget>[
                          Text(
                            DateFormat('HH:mm')
                                .format(user.nextPresence.startTime),
                          ),
                          const Text(' - '),
                          Text(
                            DateFormat('HH:mm')
                                .format(user.nextPresence.endTime),
                          )
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'STATUS KEHADIRAN :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
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
                      const SizedBox(height: 2.0),
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
                  Expanded(child: _buildStatusSection()),
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
    Future.wait([_getUser(), _getAllEmployee()]);
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
          ],
          leadingWidth: MediaQuery.of(context).size.width * 0.25,
          leading: Image.asset(
            'assets/logo/logo.png',
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          onPressed: () {
            ProgressDialog pd = ProgressDialog(context, isDismissible: false);
            pd.show();
            _getUser();
            _getAllEmployee(pd: pd);
          },
        ),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[_buildHeader(), _buildNextPresence()],
        ));
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 80),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0))),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Selamat Datang',
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      _buildUserNameSection(),
                      SizedBox(height: 10),
                      _buildPositionSection(),
                      SizedBox(height: 10),
                    ],
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(top: 100.0, left: 20.0, right: 20.0),
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
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildNextPresence() {
    return SliverToBoxAdapter(
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
            SizedBox(height: 30.0),
            Text(
              'Absen Hari Ini',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPresenceSection(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
