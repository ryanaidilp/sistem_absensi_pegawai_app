import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/absent_permission.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/create_permission_screen.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

class PermissionListScreen extends StatefulWidget {
  @override
  _PermissionListScreenState createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
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
    if (_isLoading)
      return Center(
          child: SpinKitFadingFour(
        size: 45,
        color: Colors.blueAccent,
      ));

    if (_permissions.isEmpty)
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          AbsentPermission permission = _permissions[index];
          DateTime dueDate = _permissions[index].dueDate;
          DateTime startDate = _permissions[index].startDate;
          return EmployeeProposalWidget(
            photo: permission.photo,
            heroTag: permission.id.toString(),
            isApproved: permission.isApproved,
            startDate: startDate,
            dueDate: dueDate,
            description: permission.description,
            title: permission.title,
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
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            Get.to(CreatePermissionScreen());
          },
          child: Icon(Icons.add),
        ),
        body: _buildBody());
  }
}
