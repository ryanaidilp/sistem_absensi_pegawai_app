import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/absent_permission.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/change_absent_permission_photo_screen.dart';
import 'package:spo_balaesang/screen/create_permission_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

class PermissionListScreen extends StatefulWidget {
  @override
  _PermissionListScreenState createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  List<AbsentPermission> _permissions = <AbsentPermission>[];
  bool _isLoading = false;

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchPermissionData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> _result = await dataRepo.getAllPermissions();
      final List<dynamic> permissions = _result['data'] as List<dynamic>;
      final List<AbsentPermission> _data = permissions
          .map(
              (json) => AbsentPermission.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _permissions = _data;
        _isLoading = false;
      });
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPermissionData();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: SpinKitFadingFour(
        size: 45,
        color: Colors.blueAccent,
      ));
    }

    if (_permissions.isEmpty) {
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
              const Text('Belum ada izin yang diajukan!')
            ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (_, index) {
          final AbsentPermission permission = _permissions[index];
          final DateTime dueDate = _permissions[index].dueDate;
          final DateTime startDate = _permissions[index].startDate;
          return EmployeeProposalWidget(
            photo: permission.photo,
            heroTag: permission.id.toString(),
            isApproved: permission.isApproved,
            startDate: startDate,
            dueDate: dueDate,
            approvalStatus: permission.approvalStatus,
            description: permission.description,
            title: permission.title,
            updateWidget: ChangePermissionPhotoScreen(permission: permission),
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
          title: const Text('Daftar Izin'),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            Get.to(CreatePermissionScreen());
          },
          child: const Icon(Icons.add),
        ),
        body: _buildBody());
  }
}
