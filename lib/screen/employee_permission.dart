import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/absent_permission.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class EmployeePermissionScreen extends StatefulWidget {
  @override
  _EmployeePermissionScreenState createState() =>
      _EmployeePermissionScreenState();
}

class _EmployeePermissionScreenState extends State<EmployeePermissionScreen> {
  List<AbsentPermission> _permissions = List<AbsentPermission>();
  bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchPermissionData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> _result = await dataRepo.getAllEmployeePermissions();
      List<dynamic> permissions = _result['data'];

      List<AbsentPermission> _data =
          permissions.map((json) => AbsentPermission.fromJson(json)).toList();
      setState(() {
        _permissions = _data;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  Future<void> approvePermission(AbsentPermission permission) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'user_id': permission.user.id,
        'is_approved': !permission.isApproved,
        'permission_id': permission.id
      };
      http.Response response = await dataRepo.approvePermission(data);
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

  @override
  void initState() {
    super.initState();
    _fetchPermissionData();
  }

  Widget _buildBody() {
    if (_isLoading)
      return Center(
          child: SpinKitFadingCircle(
        size: 45,
        color: Colors.blueAccent,
      ));
    if (_permissions.isEmpty) {
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
              Text('Belum ada izin yang diajukan!')
            ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          AbsentPermission permission = _permissions[index];
          DateTime dueDate = _permissions[index].dueDate;
          DateTime startDate = _permissions[index].startDate;
          return Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${permission.title}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16.0),
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: <Widget>[
                          Text(
                            'Status : ',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Text(
                            '${permission.isApproved ? 'Disetujui' : 'Belum Disetujui'}',
                            style: TextStyle(
                                fontSize: 12.0,
                                color: permission.isApproved
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: <Widget>[
                          Text(
                            'Diajukan oleh : ',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Text(
                            '${permission.user.name}',
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Divider(height: 2.0),
                      SizedBox(height: 5.0),
                      Text(
                        'Masa Berlaku : ',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16.0,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            '${startDate.day}/${startDate.month}/${startDate.year} - ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Deskripsi : ',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      AutoSizeText(
                        '${permission.description}',
                        maxFontSize: 12.0,
                        minFontSize: 10.0,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Bukti Izin : ',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      Text(
                        '*tekan untuk memperbesar',
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 5.0),
                      InkWell(
                        onTap: () {
                          Get.to(ImageDetailScreen(
                            imageUrl: permission.photo,
                          ));
                        },
                        child: Hero(
                          tag: 'image',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              placeholder: (_, __) => Container(
                                child: Stack(
                                  children: <Widget>[
                                    Image.asset(
                                        'assets/images/upload_placeholder.png'),
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
                              imageUrl: permission.photo,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Center(child: Icon(Icons.error)),
                              width: MediaQuery.of(context).size.width,
                              height: 250.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      SizedBox(
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.blueAccent,
                          onPressed: () {
                            approvePermission(permission);
                          },
                          child: Text(permission.isApproved
                              ? 'Batal Setujui'
                              : 'Setujui'),
                        ),
                      )
                    ],
                  )),
            ),
          );
        },
        itemCount: _permissions.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Daftar Izin Pegawai'),
      ),
      body: _buildBody(),
    );
  }
}
