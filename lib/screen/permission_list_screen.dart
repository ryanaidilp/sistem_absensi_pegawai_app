import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/absent_permission.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/create_permission_screen.dart';

class PermissionListScreen extends StatefulWidget {
  @override
  _PermissionListScreenState createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  List<AbsentPermission> _permissions = List<AbsentPermission>();
  bool _isLoading = false;

  Future<void> _fetchPermissionData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> _result = await dataRepo.getAllPermissions();
      List<dynamic> permissions = _result['data'];
      List<AbsentPermission> _data =
          permissions.map((json) => AbsentPermission.fromJson(json)).toList();
      setState(() {
        _permissions = _data;
        _isLoading = false;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _fetchPermissionData();
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: CircularProgressIndicator());

    if (_permissions.isEmpty)
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
              Text('Belum ada izin yang diajukan!')
            ]),
      );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          AbsentPermission permission = _permissions[index];
          DateTime dueDate = _permissions[index].dueDate;
          DateTime startDate = _permissions[index].startDate;
          return Card(
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
                    Divider(height: 1.0),
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
                    SizedBox(height: 5.0),
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
                  ],
                )),
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
          title: Text('Daftar Izin'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CreatePermissionScreen()));
          },
          child: Icon(Icons.add),
        ),
        body: _buildBody());
  }
}
