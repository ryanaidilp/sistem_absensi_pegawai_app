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
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/utils/extensions.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeePaidLeaveScreen extends StatefulWidget {
  @override
  _EmployeePaidLeaveScreenState createState() =>
      _EmployeePaidLeaveScreenState();
}

class _EmployeePaidLeaveScreenState extends State<EmployeePaidLeaveScreen> {
  List<PaidLeave> _paidLeaves = List<PaidLeave>();
  bool _isLoading = false;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final CalendarController _calendarController = CalendarController();
  List<PaidLeave> _filteredPaidLeave = List<PaidLeave>();
  Set<String> choices = {'Semua', 'Disetujui', 'Belum Disetujui', 'Tanggal'};
  String _selectedChoice = 'Semua';
  DateTime _selectedDate = DateTime.now();
  bool _isDateChange = false;

  Future<void> _fetchPaidLeaveData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> _result = await dataRepo.getAllEmployeePaidLeave();
      List<dynamic> paidLeaves = _result['data'];

      List<PaidLeave> _data =
          paidLeaves.map((json) => PaidLeave.fromJson(json)).toList();
      if (_data.isNotEmpty) {
        _paidLeaves = _data;
        _filteredPaidLeave = _data;
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _approvePaidLeave(PaidLeave paidLeave) {
    _sendData(paidLeave, true);
  }

  Future<void> _sendData(PaidLeave paidLeave, bool isApproved) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'user_id': paidLeave.user.id,
        'is_approved': isApproved,
        'paid_leave_id': paidLeave.id,
        'reason': _reasonController.value.text
      };
      http.Response response = await dataRepo.approvePaidLeave(data);
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
  void dispose() {
    _reasonController.dispose();
    _nameController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _fetchPaidLeaveData();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Container(
        height: Get.height * 0.8,
        child: Center(
            child: SpinKitFadingGrid(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    }

    if (_paidLeaves.isEmpty) {
      return Container(
        height: Get.height * 0.6,
        child: Center(
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
                Text('Belum ada Cuti yang diajukan!')
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

  _rejectPaidLeave(PaidLeave paidLeave) {
    Get.defaultDialog(
        title: 'Alasan Pembatalan!',
        content: Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: Get.width * 0.9,
            child: TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                  labelText: 'Alasan',
                  focusColor: Colors.blueAccent,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent))),
            ),
          ),
        ),
        confirm: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: () {
            Get.back();
            _sendData(paidLeave, false);
          },
          child: Text('OK'),
        ));
  }

  _cancelButton(String label, PaidLeave paidLeave) {
    return SizedBox(
      width: Get.width,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textColor: Colors.white,
        color: Colors.red[600],
        onPressed: () {
          _rejectPaidLeave(paidLeave);
        },
        child: Text(label),
      ),
    );
  }

  _approveButton(PaidLeave paidLeave) {
    return SizedBox(
      width: Get.width,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textColor: Colors.white,
        color: Colors.blueAccent,
        onPressed: () {
          _approvePaidLeave(paidLeave);
        },
        child: Text('Setujui'),
      ),
    );
  }

  _buildButtonSection(PaidLeave paidLeave) {
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
    }
  }

  Widget _buildPaidLeaveItem(PaidLeave paidLeave) {
    var startDate = paidLeave.startDate;
    var dueDate = paidLeave.dueDate;
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

    if (value == 'Tanggal') {
      if (!_isDateChange) {
        _selectDate();
      }
      return _paidLeaves.where((element) {
        setState(() {
          _isDateChange = false;
        });
        return element.startDate.isSameDate(_selectedDate) ||
            element.dueDate.isSameDate(_selectedDate);
      }).toList();
    }

    return _paidLeaves;
  }

  _selectDate() {
    Get.defaultDialog(
        title: 'Pilih Tanggal Selesai',
        content: Flexible(
          child: Container(
            width: Get.width * 0.9,
            child: TableCalendar(
              availableCalendarFormats: <CalendarFormat, String>{
                CalendarFormat.month: '1 minggu',
                CalendarFormat.twoWeeks: '1 bulan',
                CalendarFormat.week: '2 minggu'
              },
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle:
                  HeaderStyle(formatButtonTextStyle: TextStyle(fontSize: 12.0)),
              calendarController: _calendarController,
              startingDayOfWeek: StartingDayOfWeek.monday,
              startDay: DateTime(2021),
              endDay: DateTime(DateTime.now().year + 5),
              initialSelectedDay: _selectedDate,
              locale: 'in_ID',
              initialCalendarFormat: CalendarFormat.month,
              onDaySelected: (day, events, holidays) {
                Get.back();
                setState(() {
                  _selectedDate = day;
                  if (!_isDateChange) {
                    _isDateChange = true;
                  }
                  _filteredPaidLeave = _setFilter(_selectedChoice);
                  if (_nameController.value.text.isNotEmpty) {
                    _searchByName(_nameController.value.text);
                  }
                });
              },
            ),
          ),
        ));
  }

  void _searchByName(String value) {
    setState(() {
      if (value.length > 0) {
        _filteredPaidLeave = _filteredPaidLeave
            .where((element) =>
                element.user.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
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
        title: Text('Daftar Cuti Pegawai'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Cari dengan nama pegawai',
                ),
                onChanged: _searchByName,
              ),
              SizedBox(height: 10.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Filter : ',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16.0),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4),
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
                                    child: Text(
                                      choice,
                                    ),
                                    value: choice,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedChoice = value;
                                _filteredPaidLeave = _setFilter(value);
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
              Divider(),
              _buildLabelSection(),
              SizedBox(height: 8.0),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }
}
