import 'dart:async';
import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/absent_permission.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeePermissionScreen extends StatefulWidget {
  @override
  _EmployeePermissionScreenState createState() =>
      _EmployeePermissionScreenState();
}

class _EmployeePermissionScreenState extends State<EmployeePermissionScreen> {
  List<AbsentPermission> _permissions = <AbsentPermission>[];
  bool _isLoading = false;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  List<AbsentPermission> _filteredPermission = <AbsentPermission>[];
  Set<String> choices = {'Semua', 'Disetujui', 'Belum Disetujui'};
  String _selectedChoice = 'Semua';
  DateTime _selectedDate = DateTime.now();

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
          await dataRepo.getAllEmployeePermissions(_selectedDate);
      final List<dynamic> permissions = _result['data'] as List<dynamic>;

      final List<AbsentPermission> _data = permissions
          .map(
              (json) => AbsentPermission.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _permissions = _data;
        _filteredPermission = _data;
      });
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
    } finally {
      _isLoading = false;
    }
  }

  void _rejectPermission(AbsentPermission permission) {
    Get.defaultDialog(
        title: 'Alasan Pembatalan!',
        content: Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: Get.width * 0.9,
            child: TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Alasan',
                  focusColor: Colors.blueAccent,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent))),
              controller: _reasonController,
            ),
          ),
        ),
        confirm: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            primary: Colors.blueAccent,
            onPrimary: Colors.white,
          ),
          onPressed: () {
            Get.back();
            _sendData(permission, false);
          },
          child: const Text('OK'),
        ));
  }

  void _approvePermission(AbsentPermission permission) {
    _sendData(permission, true);
  }

  SizedBox _cancelButton(String label, AbsentPermission permission) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          primary: Colors.red,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _rejectPermission(permission);
        },
        child: Text(label),
      ),
    );
  }

  SizedBox _approveButton(AbsentPermission permission) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          primary: Colors.blueAccent,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _approvePermission(permission);
        },
        child: const Text('Setujui'),
      ),
    );
  }

  Widget _buildButtonSection(AbsentPermission permission) {
    switch (permission.approvalStatus) {
      case 'Menunggu Persetujuan':
        return Column(
          children: <Widget>[
            _approveButton(permission),
            _cancelButton('Tolak', permission)
          ],
        );
      case 'Disetujui':
        return _cancelButton('Batal Setujui', permission);
      case 'Ditolak':
        return _approveButton(permission);
      default:
        return sizedBox;
    }
  }

  Future<void> _sendData(AbsentPermission permission, bool isApproved) async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> data = {
        'user_id': permission.user.id,
        'is_approved': isApproved,
        'permission_id': permission.id,
        'reason': _reasonController.value.text
      };
      final http.Response response = await dataRepo.approvePermission(data);
      final Map<String, dynamic> _res =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: false);
        _fetchPermissionData();
      } else {
        if (pd.isShowing()) pd.hide();
        showErrorDialog(_res);
      }
    } catch (e) {
      pd.hide();
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _fetchPermissionData();
    super.initState();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: Get.height * 0.8,
        child: const Center(
            child: SpinKitFadingCircle(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    }
    if (_filteredPermission.isEmpty) {
      return SizedBox(
        height: Get.height * 0.6,
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
      children: _filteredPermission.map((permission) {
        final DateTime dueDate = permission.dueDate;
        final DateTime startDate = permission.startDate;
        return EmployeeProposalWidget(
          title: permission.title,
          description: permission.description,
          startDate: startDate,
          dueDate: dueDate,
          employeeName: permission.user.name,
          isApproved: permission.isApproved,
          approvalStatus: permission.approvalStatus,
          heroTag: permission.id.toString(),
          photo: permission.photo,
          isApprovalCard: true,
          button: _buildButtonSection(permission),
        );
      }).toList(),
    );
  }

  List<AbsentPermission> _setFilter(String value) {
    if (value == 'Disetujui') {
      return _permissions
          .where((element) => element.isApproved == true)
          .toList();
    }

    if (value == 'Belum Disetujui') {
      return _permissions
          .where((element) => element.isApproved == false)
          .toList();
    }

    return _permissions;
  }

  void _selectDate() {
    Get.defaultDialog(
        title: 'Pilih Tanggal',
        content: Flexible(
          child: SizedBox(
            height: Get.height * 0.4,
            width: Get.width * 0.9,
            child: TableCalendar(
              availableCalendarFormats: const <CalendarFormat, String>{
                CalendarFormat.month: '1 bulan',
              },
              calendarStyle: const CalendarStyle(
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
              calendarBuilders: const CalendarBuilders(
                dowBuilder: dowBuilder,
              ),
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.horizontalSwipe,
              shouldFillViewport: true,
              headerStyle: const HeaderStyle(titleCentered: true),
              startingDayOfWeek: StartingDayOfWeek.monday,
              firstDay: DateTime(2021),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              lastDay: DateTime(DateTime.now().year + 5),
              locale: 'in_ID',
              onDaySelected: (day, focusedDay) {
                Get.back();
                setState(() {
                  _selectedDate = day;
                  _fetchPermissionData();
                });
              },
            ),
          ),
        ));
  }

  void _searchByName(String value) {
    setState(() {
      if (value.isNotEmpty) {
        if (_filteredPermission.isNotEmpty) {
          _filteredPermission = _filteredPermission
              .where((element) =>
                  element.user.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
        }
      } else {
        _filteredPermission = _setFilter(_selectedChoice);
      }
    });
  }

  Widget _buildLabelSection() {
    if (_selectedChoice == 'Tanggal') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hasil      : ${_filteredPermission.length} izin'),
          Text(
              'Tanggal : ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate)}')
        ],
      );
    }
    return Text('Hasil : ${_filteredPermission.length} izin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Daftar Izin Pegawai'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Cari dengan nama pegawai',
                ),
                onChanged: _searchByName,
              ),
              sizedBoxH10,
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Filter : ',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16.0),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey[600])),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            isExpanded: true,
                            value: _selectedChoice,
                            items: choices
                                .map(
                                  (choice) => DropdownMenuItem(
                                    value: choice,
                                    child: Text(
                                      choice,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedChoice = value.toString();
                                _filteredPermission =
                                    _setFilter(value.toString());
                                if (_nameController.value.text.isNotEmpty) {
                                  _searchByName(_nameController.value.text);
                                }
                              });
                            }),
                      ),
                    ),
                  )
                ],
              ),
              sizedBoxH10,
              const Text(
                'Pilih Tahun & Bulan : ',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.blueAccent[400],
                      ),
                      onPressed: () {
                        _selectDate();
                      })
                ],
              ),
              dividerT1,
              sizedBoxH4,
              _buildLabelSection(),
              sizedBoxH8,
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }
}
