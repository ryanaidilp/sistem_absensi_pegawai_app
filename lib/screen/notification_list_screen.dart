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
  List<UserNotification> notifications = List<UserNotification>();
  bool _isLoading = false;
  DataRepository dataRepo;
  Set<String> choices = {'Tandai Semua Dibaca', 'Hapus Semua'};
  User _user;

  Future<void> getUser() async {
    var sp = await SharedPreferences.getInstance();
    var _data = sp.get(PREFS_USER_KEY);
    Map<String, dynamic> _json = jsonDecode(_data);

    setState(() {
      _user = User.fromJson(_json);
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchNotificationsData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> _result = await dataRepo.getAllNotifications();
      List<dynamic> _notifications = _result['data'];
      List<UserNotification> _data = _notifications
          .map((json) => UserNotification.fromJson(json))
          .toList();
      setState(() {
        notifications = _data;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readNotification(String id) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      Map<String, dynamic> data = {'notification_id': id};
      http.Response response = await dataRepo.readNotification(data);
      Map<String, dynamic> _res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'], true);
        _fetchNotificationsData();
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      print(e);
      pd.hide();
    }
  }

  Future<void> _readAllNotifications() async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      Map<String, dynamic> _res = await dataRepo.readAllNotifications();
      if (_res['success']) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'], true);
        _fetchNotificationsData();
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      print(e);
      pd.hide();
    }
  }

  Future<void> _deleteAllNotifications() async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      Map<String, dynamic> _res = await dataRepo.deleteAllNotifications();
      if (_res['success']) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'], true);
        _fetchNotificationsData();
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      print(e);
      pd.hide();
    }
  }

  Widget _buildBody() {
    if (_isLoading)
      return Center(
          child: SpinKitChasingDots(
        size: 45,
        color: Colors.blueAccent,
      ));
    if (notifications.isEmpty)
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: Get.width * 0.5,
                height: Get.height * 0.3,
                child: FlareActor(
                  'assets/flare/not_found.flr',
                  fit: BoxFit.contain,
                  animation: 'empty',
                  alignment: Alignment.center,
                ),
              ),
              Text('Belum ada pemberitahuan!')
            ]),
      );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          UserNotification notification = notifications[index];
          return Container(
            margin: EdgeInsets.only(bottom: 8.0),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            notification.isRead
                                ? SizedBox()
                                : Container(
                                    child: Text(
                                      '',
                                      style: TextStyle(fontSize: 10.0),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: Colors.red,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 1.0),
                                  )
                          ],
                        ),
                        Divider(thickness: 1.0),
                        Text(notification.data['body'])
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
        actions: notifications.length > 0
            ? <Widget>[
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) {
                    return choices
                        .map((String choice) => PopupMenuItem<String>(
                              child: Text(choice),
                              value: choice,
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
                  offset: Offset(0, 100),
                )
              ]
            : [],
        title: Text(
          'Pemberitahuan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
      floatingActionButton: _user?.position == 'Camat'
          ? FloatingActionButton(
              onPressed: () {
                Get.to(CreateNotificationScreen());
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blueAccent,
            )
          : null,
    );
  }
}
