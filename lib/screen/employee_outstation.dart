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
import 'package:spo_balaesang/models/outstation.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/bottom_nav_screen.dart';
import 'package:spo_balaesang/utils/extensions.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeeOutstationScreen extends StatefulWidget {
  @override
  _EmployeeOutstationScreenState createState() =>
      _EmployeeOutstationScreenState();
}

class _EmployeeOutstationScreenState extends State<EmployeeOutstationScreen> {
  List<Outstation> _outstations = List<Outstation>();
  bool _isLoading = false;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final CalendarController _calendarController = CalendarController();
  List<Outstation> _filteredOutstation = List<Outstation>();
  Set<String> choices = {'Semua', 'Disetujui', 'Belum Disetujui', 'Tanggal'};
  String _selectedChoice = 'Semua';
  DateTime _selectedDate = DateTime.now();
  bool _isDateChange = false;

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
        _filteredOutstation = _outstations;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _approveOutstation(Outstation outstation) {
    if (outstation.isApproved) {
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
            color: Colors.blueAccent,
            textColor: Colors.white,
            onPressed: () {
              Get.back();
              _sendData(outstation);
            },
            child: Text('OK'),
          ));
    } else {
      _sendData(outstation);
    }
  }

  Future<void> _sendData(Outstation outstation) async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> data = {
        'user_id': outstation.user.id,
        'is_approved': !outstation.isApproved,
        'outstation_id': outstation.id,
        'reason': _reasonController.value.text
      };
      http.Response response = await dataRepo.approveOutstation(data);
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
    super.initState();
    _fetchOutstationData();
  }

  Widget _buildBody() {
    if (_isLoading)
      return Container(
        height: Get.height * 0.8,
        child: Center(
            child: SpinKitFadingFour(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    if (_filteredOutstation.isEmpty) {
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
                Text('Belum ada Dinas Luar yang diajukan!')
              ]),
        ),
      );
    }
    return Column(
      children: _filteredOutstation.map((outstation) {
        DateTime dueDate = outstation.dueDate;
        DateTime startDate = outstation.startDate;
        return EmployeeProposalWidget(
          isApprovalCard: true,
          employeeName: outstation.user.name,
          button: SizedBox(
            width: Get.width,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              textColor: Colors.white,
              color: Colors.blueAccent,
              onPressed: () {
                _approveOutstation(outstation);
              },
              child: Text(outstation.isApproved ? 'Batal Setujui' : 'Setujui'),
            ),
          ),
          photo: outstation.photo,
          heroTag: outstation.id.toString(),
          isApproved: outstation.isApproved,
          startDate: startDate,
          dueDate: dueDate,
          description: outstation.description,
          title: outstation.title,
        );
      }).toList(),
    );
  }

  List<Outstation> _setFilter(String value) {
    if (value == 'Disetujui') {
      return _outstations
          .where((element) => element.isApproved == true)
          .toList();
    }

    if (value == 'Belum Disetujui') {
      return _outstations
          .where((element) => element.isApproved == false)
          .toList();
    }

    if (value == 'Tanggal') {
      if (!_isDateChange) {
        _selectDate();
      }
      return _outstations.where((element) {
        setState(() {
          _isDateChange = false;
        });
        return element.startDate.isSameDate(_selectedDate) ||
            element.dueDate.isSameDate(_selectedDate);
      }).toList();
    }

    return _outstations;
  }

  _selectDate() {
    Get.defaultDialog(
        title: 'Pilih Tanggal',
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
                  _filteredOutstation = _setFilter(_selectedChoice);
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
        _filteredOutstation = _filteredOutstation
            .where((element) =>
                element.user.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
      } else {
        _filteredOutstation = _setFilter(_selectedChoice);
      }
    });
  }

  Widget _buildLabelSection() {
    if (_selectedChoice == 'Tanggal') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hasil      : ${_filteredOutstation.length} dinas luar'),
          Text(
              'Tanggal : ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate)}')
        ],
      );
    }
    return Text('Hasil : ${_filteredOutstation.length} dinas luar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Daftar Dinas Luar Pegawai'),
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
                    labelText: 'Cari dengan nama pegawai'),
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
                                _filteredOutstation = _setFilter(value);
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
