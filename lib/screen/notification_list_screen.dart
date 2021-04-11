import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/models/notification.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/create_notification_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class NotificationListScreen extends StatefulWidget {
  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<UserNotification> notifications = [];
  bool _isLoading = false;
  DataRepository dataRepo;
  Set<String> choices = {'Tandai Semua Dibaca', 'Hapus Semua'};
  User _user;

  Future<void> getUser() async {
    final sp = await SharedPreferences.getInstance();
    final _data = sp.get(prefsUserKey);
    final Map<String, dynamic> _json =
        jsonDecode(_data.toString()) as Map<String, dynamic>;

    setState(() {
      _user = User.fromJson(_json);
    });
  }

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchNotificationsData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final Map<String, dynamic> _result = await dataRepo.getAllNotifications();
      final List<dynamic> _notifications = _result['data'] as List<dynamic>;
      final List<UserNotification> _data = _notifications
          .map(
              (json) => UserNotification.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        notifications = _data;
      });
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readNotification(String id) async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final Map<String, dynamic> data = {'notification_id': id};
      final http.Response response = await dataRepo.readNotification(data);
      final Map<String, dynamic> _res =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: true);
        _fetchNotificationsData();
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
      pd.hide();
    }
  }

  Future<void> _readAllNotifications() async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final Map<String, dynamic> _res = await dataRepo.readAllNotifications();
      if (_res['success'] as bool) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: true);
        _fetchNotificationsData();
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
      pd.hide();
    }
  }

  Future<void> _deleteAllNotifications() async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      final Map<String, dynamic> _res = await dataRepo.deleteAllNotifications();
      if (_res['success'] as bool) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: true);
        _fetchNotificationsData();
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
      pd.hide();
    }
  }

  Widget _buildMarker(bool isRead) {
    return isRead
        ? const SizedBox()
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.red,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
            child: const Text(
              '',
              style: TextStyle(fontSize: 10.0),
            ),
          );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: SpinKitChasingDots(
        size: 45,
        color: Colors.blueAccent,
      ));
    }
    if (notifications.isEmpty) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: Get.width * 0.5,
                height: Get.height * 0.3,
                child: const FlareActor(
                  'assets/flare/not_found.flr',
                  animation: 'empty',
                ),
              ),
              const Text('Belum ada pemberitahuan!')
            ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          final UserNotification notification = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              elevation: 2.0,
              child: InkWell(
                onTap: () {
                  _readNotification(notification.id);
                },
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${notification.data['heading']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildMarker(notification.isRead)
                          ],
                        ),
                        dividerT1,
                        Text(notification.data['body'].toString())
                      ],
                    )),
              ),
            ),
          );
        },
        itemCount: notifications.length,
      ),
    );
  }

  List<Widget> _buildActionMenu() {
    return notifications.isNotEmpty
        ? <Widget>[
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return choices
                    .map((String choice) => PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        ))
                    .toList();
              },
              onSelected: (value) {
                if (value == choices.first) {
                  _readAllNotifications();
                }
                if (value == choices.last) {
                  _deleteAllNotifications();
                }
              },
              offset: const Offset(0, 100),
            )
          ]
        : [];
  }

  @override
  void initState() {
    super.initState();
    dataRepo = Provider.of<DataRepository>(context, listen: false);
    getUser();
    _fetchNotificationsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _buildActionMenu(),
        title: const Text(
          'Pemberitahuan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
      floatingActionButton: _user?.position == 'Camat'
          ? FloatingActionButton(
              onPressed: () {
                Get.to(() => CreateNotificationScreen());
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
