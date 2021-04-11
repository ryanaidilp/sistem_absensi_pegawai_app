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
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/extensions.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  @override
  _EmployeeAttendanceScreenState createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<dynamic>> _holidays = {};
  List<Employee> _employees;
  List<Holiday> _selectedHolidays = [];

  void _onDaySelected(DateTime value, DateTime focusedDay) {
    final List<dynamic> _holiday = _getHolidayForDay(value);
    setState(() {
      _selectedDate = value;

      if (_holiday is List<Holiday>) {
        _selectedHolidays = _holiday;
      } else {
        _selectedHolidays = [];
      }

      if (_selectedDate.isWeekend()) {
        return;
      }

      if (_selectedHolidays.isNotEmpty) {
        return;
      }

      _fetchPresenceData();
    });
  }

  Future<void> _fetchPresenceData() async {
    final ProgressDialog pd = ProgressDialog(context, isDismissible: true);
    final isShowing = await pd.show();
    try {
      setState(() {
        _isLoading = true;
      });
      final dataRepo = Provider.of<DataRepository>(context, listen: false);
      final Map<String, dynamic> _result =
          await dataRepo.getEmployeePresence(_selectedDate);
      if (_result.isNotEmpty) {
        final List<dynamic> holidays =
            _result['data']['holidays'] as List<dynamic>;
        final List<dynamic> employees =
            _result['data']['employees'] as List<dynamic>;
        final List<Holiday> _dataHoliday = holidays
            .map((element) => Holiday.fromJson(element as Map<String, dynamic>))
            .toList();
        final List<Employee> _dataEmployee = employees
            .map((json) => Employee.fromJson(json as Map<String, dynamic>))
            .toList();
        if (_dataHoliday.isNotEmpty && _holidays.isEmpty) {
          setState(() {
            _holidays.addEntries(_dataHoliday
                .map((holiday) => MapEntry(holiday.date, <Holiday>[holiday])));
            _selectedHolidays = _holidays.entries
                .firstWhere(
                    (element) => element.key.isAtSameMomentAs(DateTime.now()))
                .value as List<Holiday>;
          });
        }
        if (_dataEmployee != null) {
          _employees = _dataEmployee;
        }
      }
    } catch (e) {
      showErrorDialog({
        'message': 'Kesalahan',
        'errors': {
          'exception': ['Terjadi kesalahan!']
        }
      });
    } finally {
      if (isShowing) {
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
        availableCalendarFormats: const <CalendarFormat, String>{
          CalendarFormat.month: '1 bulan',
        },
        calendarStyle: const CalendarStyle(
          weekendTextStyle: TextStyle(color: Colors.red),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (_, date, focusedDay) {
            return calendarBuilder(date,
                isNotEmpty: _getHolidayForDay(date).isNotEmpty);
          },
          dowBuilder: dowBuilder,
        ),
        calendarFormat: CalendarFormat.month,
        firstDay: DateTime(2021),
        onDaySelected: _onDaySelected,
        focusedDay: _selectedDate,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDate, day);
        },
        headerStyle: const HeaderStyle(titleCentered: true),
        lastDay: DateTime(DateTime.now().year + 5),
        availableGestures: AvailableGestures.horizontalSwipe,
        // holidayPredicate: _getHolidayForDay,
      ),
    );
  }

  List<dynamic> _getHolidayForDay(DateTime day) {
    List<dynamic> _holiday;
    try {
      _holiday = _holidays.entries
          .firstWhere((element) => isSameDay(day, element.key))
          .value;
    } catch (e) {
      printError(info: e.toString());
    }
    return _holiday ?? [];
  }

  @override
  void setState(void Function() fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _fetchPresenceData();
    super.initState();
  }

  Widget _buildPnsSection(Employee employee) {
    if (employee.status != 'PNS') {
      return sizedBox;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        sizedBoxH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Golongan',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(employee.group ?? '')
          ],
        ),
        sizedBoxH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'NIP',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(employee.nip ?? '')
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeeListSection() {
    if (_isLoading) {
      return SizedBox(
        height: Get.height * 0.7,
        child: const Center(
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
            .map((holiday) => SizedBox(
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

    if ((_selectedDate.weekday == 6) || (_selectedDate.weekday == 7)) {
      return Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor(
                'assets/flare/not_found.flr',
                animation: 'empty',
              ),
            ),
            const Text('Akhir Pekan'),
            sizedBoxH20
          ],
        ),
      );
    }

    if (_employees == null) {
      return Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: Get.width * 0.6,
              height: 200,
              child: const FlareActor(
                'assets/flare/failure.flr',
                animation: 'failure',
                fit: BoxFit.cover,
              ),
            ),
            const Text('Gagal memuat data'),
            sizedBoxH20,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                onPrimary: Colors.white,
                primary: Colors.blueAccent,
              ),
              onPressed: _fetchPresenceData,
              child: const Text('Coba Lagi'),
            )
          ],
        ),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: Get.width * 0.6,
              height: 300,
              child: const FlareActor('assets/flare/not_found.flr',
                  animation: 'empty'),
            ),
            const Text('Tidak ada data presensi'),
            sizedBoxH20
          ],
        ),
      );
    }

    return Center(
      child: Column(
        children: _employees
            .map((employee) => Container(
                  width: Get.width,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            employee.name ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          dividerT1,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Jabatan',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(employee.position ?? '')
                            ],
                          ),
                          sizedBoxH4,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Bagian ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(employee.department ?? '')
                            ],
                          ),
                          sizedBoxH4,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Status',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(employee.status ?? '')
                            ],
                          ),
                          _buildPnsSection(employee),
                          sizedBoxH4,
                          dividerT1,
                          Center(
                            child: SizedBox(
                              width: Get.width * 0.9,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  onPrimary: Colors.white,
                                  primary: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  Get.to(() => PresenceListScreen(
                                      employee: employee, date: _selectedDate));
                                },
                                child: const Text('Lihat data kehadiran'),
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
        title: const Text('Presensi Pegawai'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Pilih Tanggal : ',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  )),
              sizedBoxH4,
              _buildTableCalendar(),
              dividerT1,
              Text(
                'Daftar Hadir Pegawai : ${DateFormat.yMMMMEEEEd('id_ID').format(_selectedDate)}',
              ),
              sizedBoxH20,
              _buildEmployeeListSection()
            ],
          ),
        ),
      ),
    );
  }
}
