import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/absent_permission.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/change_absent_permission_photo_screen.dart';
import 'package:spo_balaesang/screen/create_permission_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';

class PermissionListScreen extends StatefulWidget {
  @override
  _PermissionListScreenState createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  List<AbsentPermission> _permissions = <AbsentPermission>[];
  bool _isLoading = false;
  DateTime _date;

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
      final Map<String, dynamic> _result =
          await dataRepo.getAllPermissions(_date);
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
    _date = DateTime.now();
    _fetchPermissionData();
  }

  Future<void> _selectDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        initialDateTime: _date,
        minDateTime: DateTime(2021),
        maxDateTime: DateTime(DateTime.now().year + 5), onConfirm: (picked, _) {
      if (picked != null) {
        setState(() {
          _date = picked;
        });
        _fetchPermissionData();
      }
    }, locale: DateTimePickerLocale.id, dateFormat: 'MMMM-y');
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: Get.height * 0.7,
        child: const Center(
            child: SpinKitFadingFour(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    }

    if (_permissions.isEmpty) {
      return SizedBox(
        height: Get.height * 0.7,
        child: Center(
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
        ),
      );
    }

    return Column(
      children: _permissions.map((AbsentPermission permission) {
        final DateTime dueDate = permission.dueDate;
        final DateTime startDate = permission.startDate;
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
      }).toList(),
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
            Get.to(() => CreatePermissionScreen());
          },
          child: const Icon(Icons.add),
        ),
        body: Container(
          height: Get.height,
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Pilih Tahun & Bulan : ',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      DateFormat.yMMMM('id_ID').format(_date),
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.blueAccent[400],
                        ),
                        onPressed: () {
                          _selectDate(context);
                        })
                  ],
                ),
                sizedBoxH4,
                dividerT1,
                sizedBoxH4,
                _buildBody()
              ],
            ),
          ),
        ));
  }
}
