import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/outstation.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class EmployeeOutstationScreen extends StatefulWidget {
  @override
  _EmployeeOutstationScreenState createState() =>
      _EmployeeOutstationScreenState();
}

class _EmployeeOutstationScreenState extends State<EmployeeOutstationScreen> {
  List<Outstation> _outstations = List<Outstation>();
  bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchOutstationData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> _result = await dataRepo.getAllEmployeeOutstation();
      List<dynamic> outstations = _result['data'];

      List<Outstation> _data =
          outstations.map((json) => Outstation.fromJson(json)).toList();
      setState(() {
        _outstations = _data;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> approveOutstation(Outstation outstation) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'user_id': outstation.user.id,
        'is_approved': !outstation.isApproved,
        'outstation_id': outstation.id
      };
      Response response = await dataRepo.approveOutstation(data);
      Map<String, dynamic> _res = jsonDecode(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'], false);
        Timer(
            Duration(seconds: 5),
            () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => BottomNavScreen()),
                (route) => false));
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
    _fetchOutstationData();
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_outstations.isEmpty) {
      return Center(
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
              Text('Belum ada Dinas Luar yang diajukan!')
            ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          Outstation outstation = _outstations[index];
          DateTime dueDate = _outstations[index].dueDate;
          DateTime startDate = _outstations[index].startDate;
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
                        '${outstation.title}',
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
                            '${outstation.isApproved ? 'Disetujui' : 'Belum Disetujui'}',
                            style: TextStyle(
                                fontSize: 12.0,
                                color: outstation.isApproved
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
                            '${outstation.user.name}',
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
                        '${outstation.description}',
                        maxFontSize: 12.0,
                        minFontSize: 10.0,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Surat Tugas : ',
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
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ImageDetailScreen(
                                    imageUrl: outstation.photo,
                                  )));
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
                                        child: CircularProgressIndicator(),
                                        width: 25.0,
                                        height: 25.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              imageUrl: outstation.photo,
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
                            approveOutstation(outstation);
                          },
                          child: Text(outstation.isApproved
                              ? 'Batal Setujui'
                              : 'Setujui'),
                        ),
                      )
                    ],
                  )),
            ),
          );
        },
        itemCount: _outstations.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Daftar Dinas Luar Pegawai'),
      ),
      body: _buildBody(),
    );
  }
}
