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
import 'package:spo_balaesang/models/paid_leave.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeePaidLeaveScreen extends StatefulWidget {
  @override
  _EmployeePaidLeaveScreenState createState() =>
      _EmployeePaidLeaveScreenState();
}

class _EmployeePaidLeaveScreenState extends State<EmployeePaidLeaveScreen> {
  List<PaidLeave> _paidLeaves = <PaidLeave>[];
  bool _isLoading = false;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  List<PaidLeave> _filteredPaidLeave = <PaidLeave>[];
  Set<String> choices = {'Semua', 'Disetujui', 'Belum Disetujui'};
  String _selectedChoice = 'Semua';
  DateTime _selectedDate = DateTime.now();

  Future<void> _fetchPaidLeaveData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> _result =
          await dataRepo.getAllEmployeePaidLeave(_selectedDate);
      final List<dynamic> paidLeaves = _result['data'] as List<dynamic>;

      final List<PaidLeave> _data = paidLeaves
          .map((json) => PaidLeave.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _paidLeaves = _data;
        _filteredPaidLeave = _data;
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

  void _approvePaidLeave(PaidLeave paidLeave) {
    _sendData(paidLeave, true);
  }

  Future<void> _sendData(PaidLeave paidLeave, bool isApproved) async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> data = {
        'user_id': paidLeave.user.id,
        'is_approved': isApproved,
        'paid_leave_id': paidLeave.id,
        'reason': _reasonController.value.text
      };
      final http.Response response = await dataRepo.approvePaidLeave(data);
      final Map<String, dynamic> _res =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: true);
        _fetchPaidLeaveData();
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
    _fetchPaidLeaveData();
    super.initState();
  }

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: Get.height * 0.8,
        child: const Center(
            child: SpinKitFadingGrid(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    }

    if (_paidLeaves.isEmpty) {
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
                const Text('Belum ada Cuti yang diajukan!')
              ]),
        ),
      );
    }
    return Column(
      children: _filteredPaidLeave
          .map((paidLeave) => _buildPaidLeaveItem(paidLeave))
          .toList(),
    );
  }

  void _rejectPaidLeave(PaidLeave paidLeave) {
    Get.defaultDialog(
        title: 'Alasan Pembatalan!',
        content: Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: Get.width * 0.9,
            child: TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                  labelText: 'Alasan',
                  focusColor: Colors.blueAccent,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent))),
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
            _sendData(paidLeave, false);
          },
          child: const Text('OK'),
        ));
  }

  SizedBox _cancelButton(String label, PaidLeave paidLeave) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          primary: Colors.red,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _rejectPaidLeave(paidLeave);
        },
        child: Text(label),
      ),
    );
  }

  SizedBox _approveButton(PaidLeave paidLeave) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          primary: Colors.blueAccent,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _approvePaidLeave(paidLeave);
        },
        child: const Text('Setujui'),
      ),
    );
  }

  Widget _buildButtonSection(PaidLeave paidLeave) {
    switch (paidLeave.approvalStatus) {
      case 'Menunggu Persetujuan':
        return Column(
          children: <Widget>[
            _approveButton(paidLeave),
            _cancelButton('Tolak', paidLeave)
          ],
        );
      case 'Disetujui':
        return _cancelButton('Batal Setujui', paidLeave);
      case 'Ditolak':
        return _approveButton(paidLeave);
      default:
        return sizedBox;
    }
  }

  Widget _buildPaidLeaveItem(PaidLeave paidLeave) {
    final startDate = paidLeave.startDate;
    final dueDate = paidLeave.dueDate;
    return EmployeeProposalWidget(
      isApprovalCard: true,
      isPaidLeave: true,
      description: paidLeave.description,
      dueDate: dueDate,
      category: paidLeave.category,
      startDate: startDate,
      heroTag: paidLeave.id.toString(),
      photo: paidLeave.photo,
      approvalStatus: paidLeave.approvalStatus,
      employeeName: paidLeave.user.name,
      button: _buildButtonSection(paidLeave),
      isApproved: paidLeave.isApproved,
      title: paidLeave.title,
    );
  }

  List<PaidLeave> _setFilter(String value) {
    if (value == 'Disetujui') {
      return _paidLeaves
          .where((element) => element.isApproved == true)
          .toList();
    }

    if (value == 'Belum Disetujui') {
      return _paidLeaves
          .where((element) => element.isApproved == false)
          .toList();
    }

    return _paidLeaves;
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
                  _fetchPaidLeaveData();
                });
              },
            ),
          ),
        ));
  }

  void _searchByName(String value) {
    setState(() {
      if (value.isNotEmpty) {
        if (_filteredPaidLeave.isNotEmpty) {
          _filteredPaidLeave = _filteredPaidLeave
              .where((element) =>
                  element.user.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
        }
      } else {
        _filteredPaidLeave = _setFilter(_selectedChoice);
      }
    });
  }

  Widget _buildLabelSection() {
    if (_selectedChoice == 'Tanggal') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hasil      : ${_filteredPaidLeave.length} cuti'),
          Text(
              'Tanggal : ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate)}')
        ],
      );
    }
    return Text('Hasil : ${_filteredPaidLeave.length} cuti');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Daftar Cuti Pegawai'),
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
                                _filteredPaidLeave =
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
