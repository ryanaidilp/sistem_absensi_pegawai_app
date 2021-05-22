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
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/employee_proposal_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeeOutstationScreen extends StatefulWidget {
  @override
  _EmployeeOutstationScreenState createState() =>
      _EmployeeOutstationScreenState();
}

class _EmployeeOutstationScreenState extends State<EmployeeOutstationScreen> {
  List<Outstation> _outstations = <Outstation>[];
  bool _isLoading = false;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  List<Outstation> _filteredOutstation = <Outstation>[];
  Set<String> choices = {'Semua', 'Disetujui', 'Belum Disetujui'};
  String _selectedChoice = 'Semua';
  DateTime _selectedDate = DateTime.now();

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _fetchOutstationData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> _result =
          await dataRepo.getAllEmployeeOutstation(_selectedDate);
      final List<dynamic> outstations = _result['data'] as List<dynamic>;

      final _data = outstations
          .map((json) => Outstation.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {
        _outstations = _data;
        _filteredOutstation = _outstations;
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

  void _rejectOutstation(Outstation outstation) {
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
            _sendData(outstation, false);
          },
          child: const Text('OK'),
        ));
  }

  // ignore: always_declare_return_types
  _approveOutstation(Outstation outstation) {
    _sendData(outstation, true);
  }

  SizedBox _cancelButton(String label, Outstation outstation) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          primary: Colors.red,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _rejectOutstation(outstation);
        },
        child: Text(label),
      ),
    );
  }

  SizedBox _approveButton(Outstation outstation) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          primary: Colors.blueAccent,
          onPrimary: Colors.white,
        ),
        onPressed: () {
          _approveOutstation(outstation);
        },
        child: const Text('Setujui'),
      ),
    );
  }

  Widget _buildButtonSection(Outstation outstation) {
    switch (outstation.approvalStatus) {
      case 'Menunggu Persetujuan':
        return Column(
          children: <Widget>[
            _approveButton(outstation),
            _cancelButton('Tolak', outstation)
          ],
        );
      case 'Disetujui':
        return _cancelButton('Batal Setujui', outstation);
      case 'Ditolak':
        return _approveButton(outstation);
      default:
        return sizedBox;
    }
  }

  Future<void> _sendData(Outstation outstation, bool isApproved) async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    pd.show();
    try {
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> data = {
        'user_id': outstation.user.id,
        'is_approved': isApproved,
        'outstation_id': outstation.id,
        'reason': _reasonController.value.text
      };
      final http.Response response = await dataRepo.approveOutstation(data);
      final Map<String, dynamic> _res =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        pd.hide();
        showAlertDialog("success", "Sukses", _res['message'].toString(),
            dismissible: false);
        _fetchOutstationData();
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
    super.initState();
    _fetchOutstationData();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        height: Get.height * 0.8,
        child: const Center(
            child: SpinKitFadingFour(
          size: 45,
          color: Colors.blueAccent,
        )),
      );
    }
    if (_filteredOutstation.isEmpty) {
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
                const Text('Belum ada Dinas Luar yang diajukan!')
              ]),
        ),
      );
    }
    return Column(
      children: _filteredOutstation.map((outstation) {
        final DateTime dueDate = outstation.dueDate;
        final DateTime startDate = outstation.startDate;
        return EmployeeProposalWidget(
          isApprovalCard: true,
          employeeName: outstation.user.name,
          button: _buildButtonSection(outstation),
          photo: outstation.photo,
          heroTag: outstation.id.toString(),
          isApproved: outstation.isApproved,
          approvalStatus: outstation.approvalStatus,
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

    return _outstations;
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
                  _fetchOutstationData();
                });
              },
            ),
          ),
        ));
  }

  void _searchByName(String value) {
    setState(() {
      if (value.isNotEmpty) {
        if (_filteredOutstation.isNotEmpty) {
          _filteredOutstation = _filteredOutstation
              .where((element) =>
                  element.user.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
        }
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
        title: const Text('Daftar Dinas Luar Pegawai'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                onChanged: _searchByName,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Cari dengan nama pegawai'),
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
                                _filteredOutstation =
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
