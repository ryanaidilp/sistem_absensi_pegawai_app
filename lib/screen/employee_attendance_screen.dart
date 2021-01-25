import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/holiday.dart';
import 'package:spo_balaesang/repositories/data_repository.dart';
import 'package:spo_balaesang/screen/presence_list_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  @override
  _EmployeeAttendanceScreenState createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  final CalendarController _calendarController = CalendarController();
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<dynamic>> _holidays = new Map();
  List<Employee> _employees;
  List<Holiday> _selectedHolidays = List();

  _onDaySelected(DateTime value, List events, List holidays) {
    setState(() {
      _selectedDate = value;
      if (holidays is List<Holiday>) {
        _selectedHolidays = holidays;
      } else {
        _selectedHolidays = [];
      }

      if (_selectedDate.weekday == 6 || _selectedDate.weekday == 7) {
        return;
      }

      if (_selectedHolidays.isNotEmpty) {
        return;
      }

      _fetchPresenceData();
    });
  }

  Future<void> _fetchPresenceData() async {
    ProgressDialog pd = ProgressDialog(context, isDismissible: false);
    try {
      pd.show();
      setState(() {
        _isLoading = true;
      });
      var dataRepo = Provider.of<DataRepository>(context, listen: false);
      Map<String, dynamic> _result =
          await dataRepo.getEmployeePresence(_selectedDate);
      if (_result.isNotEmpty) {
        List<dynamic> holidays = _result['data']['holidays'];
        List<dynamic> employees = _result['data']['employees'];
        List<Holiday> _dataHoliday =
            holidays.map((element) => Holiday.fromJson(element)).toList();
        List<Employee> _dataEmployee =
            employees.map((json) => Employee.fromJson(json)).toList();
        if (_dataHoliday.isNotEmpty && _holidays.isEmpty) {
          setState(() {
            _holidays.addEntries(_dataHoliday
                .map((holiday) => MapEntry(holiday.date, <Holiday>[holiday])));
            _selectedHolidays = _holidays.entries
                .firstWhere(
                    (element) => element.key.isAtSameMomentAs(DateTime.now()))
                .value;
          });
        }
        if (_dataEmployee != null) {
          _employees = _dataEmployee;
        }
      }
    } catch (e) {
      print(e.toString());
    } finally {
      if (pd.isShowing()) {
        await pd.hide();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTableCalendar() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: TableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarController: _calendarController,
        availableCalendarFormats: <CalendarFormat, String>{
          CalendarFormat.month: '1 minggu',
          CalendarFormat.twoWeeks: '1 bulan',
          CalendarFormat.week: '2 minggu'
        },
        startDay: DateTime(2021),
        initialCalendarFormat: CalendarFormat.month,
        onDaySelected: _onDaySelected,
        availableGestures: AvailableGestures.horizontalSwipe,
        holidays: _holidays,
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _fetchPresenceData();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Widget _buildPnsSection(Employee employee) {
    if (employee.status != 'PNS') {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Golongan',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text('${employee.group}')
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'NIP',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(employee.nip)
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeListSection() {
    if (_isLoading) {
      return Container(
        height: Get.height * 0.7,
        child: Center(
          child: SpinKitFadingCircle(
            size: 45,
            color: Colors.blueAccent,
          ),
        ),
      );
    }

    if (_selectedHolidays.isNotEmpty) {
      return Column(
        children: _selectedHolidays
            .map((holiday) => Container(
                  width: Get.width,
                  child: Card(
                    child: ListTile(
                      title: Text('Libur ${_selectedHolidays.first.name}'),
                      subtitle: Text(_selectedHolidays.first.description),
                    ),
                  ),
                ))
            .toList(),
      );
    }

    if ((_selectedDate.weekday == 6 || _selectedDate.weekday == 7)) {
      return Center(
        child: Column(
          children: <Widget>[
            Container(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor(
                'assets/flare/not_found.flr',
                animation: 'empty',
              ),
            ),
            const Text('Akhir Pekan'),
            const SizedBox(height: 20.0)
          ],
        ),
      );
    }

    if (_employees == null) {
      return Center(
        child: Column(
          children: <Widget>[
            Container(
              width: Get.width * 0.6,
              height: 200,
              child: const FlareActor(
                'assets/flare/failure.flr',
                animation: 'failure',
                fit: BoxFit.cover,
              ),
            ),
            const Text('Gagal memuat data'),
            const SizedBox(height: 20.0),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: _fetchPresenceData,
              child: Text('Coba Lagi'),
            )
          ],
        ),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          children: <Widget>[
            Container(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor('assets/flare/not_found.flr',
                  animation: 'empty'),
            ),
            const Text('Tidak ada data presensi'),
            const SizedBox(height: 20.0)
          ],
        ),
      );
    }

    return Center(
      child: Column(
        children: _employees
            .map((employee) => Container(
                  width: Get.width,
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            employee.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Divider(thickness: 1.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Jabatan',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(employee.position)
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Bagian ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(employee.department)
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Status',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(employee.status)
                            ],
                          ),
                          _buildPnsSection(employee),
                          SizedBox(height: 4.0),
                          Divider(thickness: 1.0),
                          Center(
                            child: SizedBox(
                              width: Get.width * 0.9,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                textColor: Colors.white,
                                color: Colors.blueAccent,
                                onPressed: () {
                                  Get.to(PresenceListScreen(
                                      employee: employee, date: _selectedDate));
                                },
                                child: Text('Lihat data kehadiran'),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Presensi Pegawai'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Pilih Tanggal : ',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(height: 4.0),
              _buildTableCalendar(),
              Divider(thickness: 1.0),
              Text(
                'Daftar Hadir Pegawai : ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate)}',
              ),
              SizedBox(height: 20.0),
              _buildEmployeeListSection()
            ],
          ),
        ),
      ),
    );
  }
}
